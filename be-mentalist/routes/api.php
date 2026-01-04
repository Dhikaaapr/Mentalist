<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\GoogleAuthController;
use App\Http\Controllers\Auth\AuthController;
use App\Http\Controllers\Auth\ForgotPasswordController;
use App\Http\Controllers\Auth\ResetPasswordController;
use App\Http\Controllers\CounselorProfileController;
use App\Http\Controllers\BookingController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// Auth routes (public)
Route::prefix('auth')->group(function () {
    Route::post('/google/login', [GoogleAuthController::class, 'handleGoogleLogin']);
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/forgot-password', [ForgotPasswordController::class, 'sendResetLink']);
    Route::post('/reset-password', [ResetPasswordController::class, 'reset']);
});

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    // User profile
    Route::get('/user', [AuthController::class, 'profile']);
    Route::post('/user', [AuthController::class, 'updateProfile']);
    Route::post('/logout', [AuthController::class, 'logout']);

    // Counselors
    Route::get('/counselors/available', [CounselorProfileController::class, 'getAvailableCounselors']);

    // Bookings
    Route::prefix('bookings')->group(function () {
        Route::get('/', [BookingController::class, 'index']);
        Route::post('/', [BookingController::class, 'store']);
        Route::get('/{id}', [BookingController::class, 'show']);
        Route::post('/{id}/cancel', [BookingController::class, 'cancel']);
        Route::post('/{id}/confirm', [BookingController::class, 'confirm']);
        Route::post('/{id}/reject', [BookingController::class, 'reject']);
        Route::post('/{id}/reschedule', [BookingController::class, 'reschedule']);
        Route::post('/{id}/complete', [BookingController::class, 'complete']);
    });
});
