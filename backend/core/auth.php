<?php
declare(strict_types=1);

require_once __DIR__ . '/helpers.php';

function api_register(): void
{
    $b = body();
    $name = trim((string)($b['name'] ?? ''));
    $identifier = trim((string)($b['phone'] ?? ''));
    $email = trim((string)($b['email'] ?? ''));
    $pass = (string)($b['password'] ?? '');
    $role = in_array($b['role'] ?? '', ['customer', 'provider'], true) ? $b['role'] : 'customer';
    $lang = ($b['lang'] ?? 'ar') === 'en' ? 'en' : 'ar';

    if ($name === '' || $identifier === '' || strlen($pass) < 6) {
        json_err('Name, phone and password (min 6 chars) are required', 422);
    }
    if ($email !== '' && !filter_var($email, FILTER_VALIDATE_EMAIL)) {
        json_err('Invalid email', 422);
    }

    $st = db()->prepare('SELECT id FROM users WHERE phone = ? OR email = ?');
    $st->execute([$identifier, $email]);
    if ($st->fetch()) {
        json_err('Phone or email already registered', 409);
    }

    $hash = password_hash($pass, PASSWORD_BCRYPT);
    $st = db()->prepare(
        'INSERT INTO users (name, phone, email, password_hash, role, lang) VALUES (?, ?, ?, ?, ?, ?)'
    );
    $st->execute([$name, $identifier, $email !== '' ? $email : null, $hash, $role, $lang]);
    $userId = (int)db()->lastInsertId();

    if ($role === 'provider') {
        db()->prepare('INSERT INTO provider_profiles (user_id) VALUES (?)')->execute([$userId]);
    }

    $token = gen_token();
    db()->prepare('INSERT INTO api_tokens (user_id, token) VALUES (?, ?)')->execute([$userId, $token]);

    json_ok(['token' => $token, 'user' => user_public($userId)]);
}

function api_login(): void
{
    $b = body();
    $identifier = trim((string)($b['phone'] ?? $b['email'] ?? ''));
    $pass = (string)($b['password'] ?? '');

    if ($identifier === '' || $pass === '') {
        json_err('Phone/email and password are required', 422);
    }

    $st = db()->prepare('SELECT * FROM users WHERE (phone = ? OR email = ?) AND is_active = 1');
    $st->execute([$identifier, $identifier]);
    $u = $st->fetch();

    if (!$u || !password_verify($pass, $u['password_hash'])) {
        json_err('Invalid credentials', 401);
    }

    $token = gen_token();
    db()->prepare('INSERT INTO api_tokens (user_id, token) VALUES (?, ?)')->execute([$u['id'], $token]);

    json_ok(['token' => $token, 'user' => user_public((int)$u['id'])]);
}

function api_logout(): void
{
    $u = require_auth();
    $tok = bearer_token();
    if ($tok) {
        db()->prepare('DELETE FROM api_tokens WHERE token = ?')->execute([$tok]);
    }
    json_ok();
}

function user_public(int $userId): array
{
    $st = db()->prepare(
        'SELECT u.id, u.name, u.phone, u.email, u.role, u.lang, u.is_active,
                pp.service_id, pp.bio, pp.rating, pp.jobs_count, pp.is_online
         FROM users u
         LEFT JOIN provider_profiles pp ON pp.user_id = u.id
         WHERE u.id = ?'
    );
    $st->execute([$userId]);
    return $st->fetch() ?: [];
}

function api_profile(): void
{
    $u = require_auth();
    json_ok(user_public((int)$u['id']));
}

function api_update_profile(): void
{
    $u = require_auth();
    $b = body();
    $sql = [];
    $params = [];

    if (isset($b['name'])) {
        $sql[] = 'name = ?';
        $params[] = trim((string)$b['name']);
    }
    if (isset($b['email'])) {
        $sql[] = 'email = ?';
        $params[] = trim((string)$b['email']) ?: null;
    }
    if (isset($b['lang'])) {
        $sql[] = 'lang = ?';
        $params[] = $b['lang'] === 'en' ? 'en' : 'ar';
    }

    if ($sql) {
        $params[] = $u['id'];
        db()->prepare('UPDATE users SET ' . implode(', ', $sql) . ' WHERE id = ?')->execute($params);
    }

    if ($u['role'] === 'provider') {
        $p = [];
        $pv = [];
        if (isset($b['service_id']) && $b['service_id'] !== '') {
            $p[] = 'service_id = ?';
            $pv[] = (int)$b['service_id'];
        }
        if (isset($b['bio'])) {
            $p[] = 'bio = ?';
            $pv[] = trim((string)$b['bio']);
        }
        if ($p) {
            $pv[] = $u['id'];
            db()->prepare('UPDATE provider_profiles SET ' . implode(', ', $p) . ' WHERE user_id = ?')->execute($pv);
        }
    }

    json_ok(user_public((int)$u['id']));
}

function api_provider_status(): void
{
    $u = require_role(['provider', 'admin']);
    $b = body();
    $isOnline = isset($b['is_online']) && (int)$b['is_online'] === 1 ? 1 : 0;
    db()->prepare('UPDATE provider_profiles SET is_online = ? WHERE user_id = ?')->execute([$isOnline, $u['id']]);
    json_ok(['is_online' => (bool)$isOnline]);
}