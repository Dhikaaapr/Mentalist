<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Services\GoogleAuthService;

class GoogleAuthController extends Controller
{
    protected GoogleAuthService $googleAuthService;

    public function __construct(GoogleAuthService $googleAuthService)
    {
        $this->googleAuthService = $googleAuthService;
    }

    /**
     * Handle Google login with ID token from Flutter app.
     * Controller only handles request/response, business logic is in service.
     */
    public function handleGoogleLogin(Request $request): JsonResponse
    {
        $request->validate([
            'id_token' => 'required|string',
        ]);

        $result = $this->googleAuthService->handleGoogleLogin($request->id_token);

        $status = $result['success'] ? 200 : 400;

        return response()->json($result, $status);
    }
}
