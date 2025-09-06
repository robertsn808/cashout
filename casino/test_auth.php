<?php
require_once 'bootstrap/app.php';

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use VanguardLTE\User;

// Create Laravel application instance
$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);

// Create request
$request = Request::create('/', 'GET');
$response = $kernel->handle($request);

// Try to log in the demo user
$user = User::where('email', 'demo01@gmail.com')->first();

if ($user) {
    Auth::login($user);
    
    echo "Demo User Authentication Test\n";
    echo "=============================\n";
    echo "User ID: " . $user->id . "\n";
    echo "Username: " . $user->username . "\n";
    echo "Email: " . $user->email . "\n";
    echo "Balance: " . $user->balance . "\n";
    echo "Role ID: " . $user->role_id . "\n";
    echo "Auth Check: " . (Auth::check() ? "Yes" : "No") . "\n";
    echo "Logged User ID: " . (Auth::user() ? Auth::user()->id : "None") . "\n";
    
    if (Auth::check()) {
        echo "\nAuthentication is working! The demo user is logged in.\n";
        echo "Balance display should now work on the frontend.\n";
    } else {
        echo "\nAuthentication failed.\n";
    }
} else {
    echo "Demo user not found.\n";
}