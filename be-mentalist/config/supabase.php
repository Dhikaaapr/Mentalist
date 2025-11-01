<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Supabase Configuration
    |--------------------------------------------------------------------------
    |
    | This configuration is for connecting to Supabase.
    | You can set your Supabase URL and anonymous key here.
    |
    */
    
    'url' => env('SUPABASE_URL', ''),
    'anonymous_key' => env('SUPABASE_ANON_KEY', ''),
    'service_role_key' => env('SUPABASE_SERVICE_ROLE_KEY', ''),
    
    /*
    |--------------------------------------------------------------------------
    | Google OAuth Configuration
    |--------------------------------------------------------------------------
    |
    | These are the credentials for Google OAuth.
    |
    */
    
    'google' => [
        'client_id' => env('GOOGLE_CLIENT_ID'),
        'client_secret' => env('GOOGLE_CLIENT_SECRET'),
        'redirect' => env('GOOGLE_REDIRECT_URI'),
    ],
];