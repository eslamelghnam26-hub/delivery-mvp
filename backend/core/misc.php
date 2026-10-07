<?php
declare(strict_types=1);

require_once __DIR__ . '/helpers.php';

function api_put_location(): void
{
    $u = require_role(['provider', 'admin']);
    $b = body();
    $lat = (float)($b['lat'] ?? 0);
    $lng = (float)($b['lng'] ?? 0);

    if ($lat === 0.0 || $lng === 0.0) {
        json_err('lat and lng are required', 422);
    }

    db()->prepare('INSERT INTO locations (user_id, lat, lng) VALUES (?, ?, ?)')->execute([$u['id'], $lat, $lng]);
    json_ok(['ok' => true]);
}

function api_get_provider_location(): void
{
    $providerId = (int)route_param('id');
    $st = db()->prepare(
        'SELECT lat, lng, recorded_at FROM locations WHERE user_id = ? ORDER BY id DESC LIMIT 1'
    );
    $st->execute([$providerId]);
    $loc = $st->fetch();
    if (!$loc) {
        json_err('No location yet', 404);
    }
    json_ok($loc);
}

function api_notifications(): void
{
    $u = require_auth();
    $st = db()->prepare(
        'SELECT * FROM notifications WHERE user_id = ? ORDER BY id DESC LIMIT 50'
    );
    $st->execute([$u['id']]);
    json_ok($st->fetchAll());
}

function api_mark_notifications_read(): void
{
    $u = require_auth();
    db()->prepare('UPDATE notifications SET is_read = 1 WHERE user_id = ?')->execute([$u['id']]);
    json_ok();
}

function api_list_providers(): void
{
    require_role(['customer', 'admin']);
    $st = db()->query(
        'SELECT u.id, u.name, pp.bio, pp.rating, pp.jobs_count, pp.is_online, pp.service_id
         FROM provider_profiles pp
         JOIN users u ON u.id = pp.user_id
         WHERE u.is_active = 1'
    );
    json_ok($st->fetchAll());
}

function api_admin_stats(): void
{
    require_role(['admin']);
    $o = (int)db()->query('SELECT COUNT(*) FROM orders')->fetchColumn();
    $u = (int)db()->query('SELECT COUNT(*) FROM users WHERE role != "admin"')->fetchColumn();
    $p = (int)db()->query('SELECT COUNT(*) FROM users WHERE role = "provider"')->fetchColumn();
    $done = (int)db()->query('SELECT COUNT(*) FROM orders WHERE status = "completed"')->fetchColumn();
    json_ok(['orders' => $o, 'users' => $u, 'providers' => $p, 'completed' => $done]);
}