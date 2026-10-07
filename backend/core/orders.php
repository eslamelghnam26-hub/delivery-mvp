<?php
declare(strict_types=1);

require_once __DIR__ . '/helpers.php';

function api_services(): void
{
    $st = db()->query('SELECT id, name_ar, name_en, icon FROM services WHERE is_active = 1 ORDER BY id');
    json_ok($st->fetchAll());
}

function api_list_orders(): void
{
    $u = require_auth();
    $role = $u['role'];

    if ($role === 'admin') {
        $status = $_GET['status'] ?? null;
        $sql = 'SELECT * FROM orders';
        $params = [];
        if ($status) {
            $sql .= ' WHERE status = ?';
            $params[] = $status;
        }
        $sql .= ' ORDER BY id DESC LIMIT 200';
        $st = db()->prepare($sql);
        $st->execute($params);
        json_ok($st->fetchAll());
    }

    if ($role === 'customer') {
        $st = db()->prepare('SELECT * FROM orders WHERE customer_id = ? ORDER BY id DESC LIMIT 100');
        $st->execute([$u['id']]);
        json_ok($st->fetchAll());
    }

    $status = $_GET['status'] ?? null;
    if ($status === 'available') {
        $st = db()->prepare(
            'SELECT o.* FROM orders o
             WHERE o.status = "pending" AND (o.provider_id IS NULL OR o.provider_id = ?)
             ORDER BY o.id DESC LIMIT 100'
        );
        $st->execute([$u['id']]);
        json_ok($st->fetchAll());
    }

    $st = db()->prepare(
        'SELECT * FROM orders WHERE provider_id = ? ORDER BY id DESC LIMIT 100'
    );
    $st->execute([$u['id']]);
    json_ok($st->fetchAll());
}

function api_create_order(): void
{
    $u = require_role(['customer', 'admin']);
    $b = body();

    $svc = (int)($b['service_id'] ?? 0);
    $lat = (float)($b['lat'] ?? 0);
    $lng = (float)($b['lng'] ?? 0);

    if ($svc <= 0 || $lat === 0.0 || $lng === 0.0) {
        json_err('service_id, lat and lng are required', 422);
    }

    $ordNo = strtoupper(substr(bin2hex(random_bytes(4)), 0, 6)) . substr((string)time(), -4);
    $st = db()->prepare(
        'INSERT INTO orders (order_no, customer_id, service_id, lat, lng, address, description)
         VALUES (?, ?, ?, ?, ?, ?, ?)'
    );
    $st->execute([
        $ordNo,
        $u['id'],
        $svc,
        $lat,
        $lng,
        trim((string)($b['address'] ?? '')) ?: null,
        trim((string)($b['description'] ?? '')) ?: null,
    ]);

    $orderId = (int)db()->lastInsertId();
    $st = db()->prepare('SELECT * FROM orders WHERE id = ?');
    $st->execute([$orderId]);
    json_ok($st->fetch());
}

function api_accept_order(): void
{
    $u = require_role(['provider']);
    $orderId = (int)route_param('id');
    $o = fetch_order($orderId);

    if (!$o) {
        json_err('Order not found', 404);
    }
    if ($o['status'] !== 'pending') {
        json_err('Order already assigned', 409);
    }

    db()->beginTransaction();
    db()->prepare(
        'UPDATE orders SET provider_id = ?, status = "accepted", accepted_at = NOW()
         WHERE id = ? AND status = "pending"'
    )->execute([$u['id'], $orderId]);
    $taken = db()->query('SELECT ROW_COUNT() AS n')->fetch()['n'];
    if ((int)$taken === 0) {
        db()->rollBack();
        json_err('Order taken by another provider', 409);
    }
    db()->commit();

    notif((int)$o['customer_id'], 'Order accepted', 'Your order #' . $o['order_no'] . ' is being handled', 'order', $orderId);
    json_ok(fetch_order($orderId));
}

function api_set_status(): void
{
    $u = require_role(['provider', 'admin']);
    $orderId = (int)route_param('id');
    $o = fetch_order($orderId);

    if (!$o) {
        json_err('Order not found', 404);
    }

    $status = $_POST['status'] ?? body()['status'] ?? null;
    $allowed = ['on_the_way', 'in_service', 'completed'];
    if ($u['role'] === 'admin') {
        $allowed[] = 'pending';
        $allowed[] = 'accepted';
        $allowed[] = 'canceled';
    }
    if (!in_array($status, $allowed, true)) {
        json_err('Invalid status', 422);
    }
    if ($u['role'] === 'provider' && (int)$o['provider_id'] !== (int)$u['id']) {
        json_err('Not your order', 403);
    }

    $set = 'status = ?, updated_at = NOW()';
    $params = [$status];
    if ($status === 'completed') {
        $set .= ', completed_at = NOW()';
        db()->prepare('UPDATE provider_profiles SET jobs_count = jobs_count + 1 WHERE user_id = ?')
            ->execute([$o['provider_id']]);
    }

    $params[] = $orderId;
    db()->prepare("UPDATE orders SET $set WHERE id = ?")->execute($params);

    $to = (int)$o['customer_id'];
    $title = 'Order ' . ucfirst($status);
    notif($to, $title, 'Order #' . $o['order_no'] . ' is now ' . $status, 'order', $orderId);

    json_ok(fetch_order($orderId));
}

function api_cancel_order(): void
{
    $u = require_auth();
    $orderId = (int)route_param('id');
    $o = fetch_order($orderId);

    if (!$o) {
        json_err('Order not found', 404);
    }
    $isCustomer = $u['role'] === 'customer' && (int)$o['customer_id'] === (int)$u['id'];
    $isProvider = $u['role'] === 'provider' && (int)$o['provider_id'] === (int)$u['id'];
    if (!$isCustomer && !$isProvider && $u['role'] !== 'admin') {
        json_err('Forbidden', 403);
    }
    if (in_array($o['status'], ['completed', 'canceled'], true)) {
        json_err('Order cannot be canceled', 409);
    }

    db()->prepare('UPDATE orders SET status = "canceled" WHERE id = ?')->execute([$orderId]);

    $other = $u['role'] === 'customer' ? 'provider' : 'customer';
    if ($other === 'provider' && $o['provider_id']) {
        notif((int)$o['provider_id'], 'Order canceled', 'Order #' . $o['order_no'] . ' was canceled', 'order', $orderId);
    } elseif ($other === 'customer') {
        notif((int)$o['customer_id'], 'Order canceled', 'Order #' . $o['order_no'] . ' was canceled', 'order', $orderId);
    }

    json_ok(fetch_order($orderId));
}

function api_rate_order(): void
{
    $u = require_role(['customer', 'provider', 'admin']);
    $orderId = (int)route_param('id');
    $o = fetch_order($orderId);

    if (!$o) {
        json_err('Order not found', 404);
    }
    if ($o['status'] !== 'completed') {
        json_err('Only completed orders can be rated', 409);
    }

    $b = body();
    $rate = (int)($b['stars'] ?? 0);
    if ($rate < 1 || $rate > 5) {
        json_err('stars must be 1..5', 422);
    }

    if ($u['role'] === 'customer' && (int)$o['customer_id'] === (int)$u['id']) {
        db()->prepare('UPDATE orders SET customer_rating = ? WHERE id = ?')->execute([$rate, $orderId]);
        $st = db()->prepare(
            'SELECT AVG(r.customer_rating) a, COUNT(*) c FROM orders r WHERE r.provider_id = ? AND r.customer_rating IS NOT NULL'
        );
        $st->execute([$o['provider_id']]);
        $agg = $st->fetch();
        db()->prepare('UPDATE provider_profiles SET rating = ? WHERE user_id = ?')
            ->execute([round((float)$agg['a'], 2), $o['provider_id']]);
    } elseif ($u['role'] === 'provider' && (int)$o['provider_id'] === (int)$u['id']) {
        db()->prepare('UPDATE orders SET provider_rating = ? WHERE id = ?')->execute([$rate, $orderId]);
    } else {
        json_err('Forbidden', 403);
    }

    json_ok(fetch_order($orderId));
}

function fetch_order(int $id): ?array
{
    $st = db()->prepare('SELECT * FROM orders WHERE id = ?');
    $st->execute([$id]);
    $o = $st->fetch();
    return $o ?: null;
}