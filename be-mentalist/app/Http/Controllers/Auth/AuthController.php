<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;
use App\Services\AuthService;
use App\Services\RoleService;

class AuthController extends Controller
{
    protected AuthService $authService;
    protected RoleService $roleService;

    public function __construct(
        AuthService $authService,
        RoleService $roleService
    ) {
        $this->authService = $authService;
        $this->roleService = $roleService;
    }

    /**
     * Handle manual login with email and password.
     * Controller only handles request/response, business logic is in service.
     */
    public function login(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        $result = $this->authService->authenticate(
            $request->email,
            $request->password
        );

        $status = $result['success'] ? 200 : 401;
        $message = $result['message'] ?? ($result['success'] ? 'Login berhasil' : 'Login gagal');

        return response()->json(
            array_merge($result, ['message' => $message]),
            $status
        );
    }

    /**
     * Handle user registration.
     * Controller only handles request/response, business logic is in service.
     */
    public function register(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:6|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        // Get default role
        $defaultRole = $this->roleService->getDefaultUserRole();

        if (!$defaultRole) {
            return response()->json([
                'success' => false,
                'message' => 'Role default tidak ditemukan',
            ], 500);
        }

        $userData = [
            'name' => $request->name,
            'email' => $request->email,
            'password' => $request->password,
            'role_id' => $defaultRole['id'],
        ];

        $result = $this->authService->register($userData);

        $status = $result['success'] ? 200 : 422;

        return response()->json($result, $status);
    }

    /**
     * Get authenticated user profile.
     * Controller only handles request/response, business logic is in service.
     */
    public function profile(Request $request): JsonResponse
    {
        $user = $request->user();

        $result = $this->authService->getProfile($user->id);

        $status = $result['success'] ? 200 : 404;

        return response()->json($result, $status);
    }

    /**
     * Logout user.
     * Controller only handles request/response, business logic is in service.
     */
    public function logout(Request $request): JsonResponse
    {
        $token = $request->bearerToken();

        $result = $this->authService->logout($token);

        return response()->json($result);
    }
}