<?php
declare(strict_types=1);

require_once __DIR__ . '/../core/helpers.php';
require_once __DIR__ . '/../core/auth.php';
require_once __DIR__ . '/../core/orders.php';
require_once __DIR__ . '/../core/misc.php';

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
if ($method === 'OPTIONS') {
    json_out(['success' => true]);
}

$path = rtrim(parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH), '/');
$scriptBase = rtrim(str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'] ?? '')), '/');
if ($scriptBase !== '' && $scriptBase !== '/' && strpos($path, $scriptBase) === 0) {
    $path = substr($path, strlen($scriptBase));
}
$path = rtrim($path, '/');
if (strpos($path, '/api/') !== 0) {
    json_err('Not found', 404);
}

$segments = array_values(array_filter(explode('/', $path)));
array_shift($segments);

$GLOBALS['route_params'] = [];

function route_param(string $key): ?string
{
    return $GLOBALS['route_params'][$key] ?? null;
}

function resolve_id(array $segments, int $idx): void
{
    if (isset($segments[$idx]) && ctype_digit((string)$segments[$idx])) {
        $GLOBALS['route_params']['id'] = $segments[$idx];
    }
}

$head = $segments[0] ?? '';

try {
    if ($head === 'auth') {
        $sub = $segments[1] ?? '';
        if ($method === 'POST' && $sub === 'register') api_register();
        if ($method === 'POST' && $sub === 'login') api_login();
        if ($method === 'POST' && $sub === 'logout') api_logout();
    }

    if ($head === 'profile') {
        if ($method === 'GET') api_profile();
        if ($method === 'PUT' || $method === 'POST') api_update_profile();
    }

    if ($head === 'services' && $method === 'GET') api_services();

    if ($head === 'providers' && $method === 'GET') api_list_providers();

    if ($head === 'provider' && ($segments[1] ?? '') === 'status' && $method === 'POST') api_provider_status();

    if ($head === 'orders') {
        if ($method === 'GET' && !isset($segments[1])) api_list_orders();
        if ($method === 'POST' && !isset($segments[1])) api_create_order();
        if (isset($segments[1]) && ctype_digit((string)$segments[1])) {
            $GLOBALS['route_params']['id'] = $segments[1];
            $action = $segments[2] ?? '';
            if ($action === 'accept' && $method === 'POST') api_accept_order();
            if ($action === 'status' && $method === 'POST') api_set_status();
            if ($action === 'cancel' && $method === 'POST') api_cancel_order();
            if ($action === 'rate' && $method === 'POST') api_rate_order();
        }
    }

    if ($head === 'location' && $method === 'POST' && !isset($segments[1])) api_put_location();

    if ($head === 'locations' && isset($segments[1]) && ctype_digit((string)$segments[1]) && $method === 'GET') {
        $GLOBALS['route_params']['id'] = $segments[1];
        api_get_provider_location();
    }

    if ($head === 'notifications') {
        if ($method === 'GET') api_notifications();
        if ($method === 'POST') api_mark_notifications_read();
    }

    if ($head === 'admin' && ($segments[1] ?? '') === 'stats' && $method === 'GET') api_admin_stats();

    json_err('Not found', 404);
} catch (PDOException $e) {
    json_err('Database error: ' . $e->getMessage(), 500);
} catch (Throwable $e) {
    json_err('Server error: ' . $e->getMessage(), 500);
}