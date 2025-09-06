<?php
// Simple router for PHP built-in server to serve Laravel from project root
$uri = urldecode(parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH));
$path = __DIR__ . $uri;

if ($uri !== '/' && file_exists($path) && is_file($path)) {
    // Serve the requested resource as-is.
    return false;
}

require __DIR__ . '/index.php';

