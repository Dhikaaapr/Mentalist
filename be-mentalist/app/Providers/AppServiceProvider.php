<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use App\Services\SupabaseService;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        // Bind SupabaseService to the container
        $this->app->singleton(SupabaseService::class, function ($app) {
            return new SupabaseService();
        });
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        //
    }
}
