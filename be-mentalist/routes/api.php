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
        Route::get('/today', [BookingController::class, 'today']);
        Route::post('/', [BookingController::class, 'store']);
        Route::get('/{id}', [BookingController::class, 'show']);
        Route::post('/{id}/cancel', [BookingController::class, 'cancel']);
        Route::post('/{id}/confirm', [BookingController::class, 'confirm']);
        Route::post('/{id}/reject', [BookingController::class, 'reject']);
        Route::post('/{id}/reschedule', [BookingController::class, 'reschedule']);
        Route::post('/{id}/complete', [BookingController::class, 'complete']);
    });

    // Admin routes (admin role only)
    Route::middleware(\App\Http\Middleware\IsAdmin::class)->prefix('admin')->group(function () {
        Route::get('/counselors', [\App\Http\Controllers\AdminController::class, 'getAllCounselors']);
        Route::post('/counselors/{id}/toggle-status', [\App\Http\Controllers\AdminController::class, 'toggleCounselorStatus']);
        
        Route::get('/users', [\App\Http\Controllers\AdminController::class, 'getAllUsers']);
        Route::post('/users/{id}/toggle-status', [\App\Http\Controllers\AdminController::class, 'toggleUserStatus']);
        
        Route::get('/reports/stats', [\App\Http\Controllers\AdminController::class, 'getReportStats']);

        // Admin Notifications
        Route::get('/notifications', [\App\Http\Controllers\AdminController::class, 'getNotifications']);
        Route::post('/notifications/{id}/read', [\App\Http\Controllers\AdminController::class, 'markAsRead']);

        // Admin Schedule Approval
        Route::get('/schedules/pending', [\App\Http\Controllers\CounselorScheduleController::class, 'getPendingSchedules']);
        Route::post('/schedules/{id}/approve', [\App\Http\Controllers\CounselorScheduleController::class, 'approve']);
        Route::post('/schedules/{id}/reject', [\App\Http\Controllers\CounselorScheduleController::class, 'reject']);

        // Admin Weekly Schedule Approval
        Route::get('/schedules/weekly/pending', [\App\Http\Controllers\CounselorScheduleController::class, 'getPendingWeeklySchedules']);
        Route::post('/schedules/weekly/{id}/approve', [\App\Http\Controllers\CounselorScheduleController::class, 'approveWeekly']);
        Route::post('/schedules/weekly/{id}/reject', [\App\Http\Controllers\CounselorScheduleController::class, 'rejectWeekly']);
    });

    // Counselor routes
    Route::prefix('counselor')->group(function () {
        Route::post('/schedules', [\App\Http\Controllers\CounselorScheduleController::class, 'store']);
        Route::get('/schedules', [\App\Http\Controllers\CounselorScheduleController::class, 'index']);
        
        // Counselor Weekly Schedules
        Route::post('/schedules/weekly', [\App\Http\Controllers\CounselorScheduleController::class, 'storeWeekly']);
        Route::get('/schedules/weekly', [\App\Http\Controllers\CounselorScheduleController::class, 'indexWeekly']);

        // Counselor Notifications
        Route::get('/notifications', [\App\Http\Controllers\CounselorController::class, 'getNotifications']);
        Route::post('/notifications/{id}/read', [\App\Http\Controllers\CounselorController::class, 'markAsRead']);
    });
});
