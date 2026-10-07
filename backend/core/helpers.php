<?php
declare(strict_types=1);

require_once __DIR__ . '/../config/db.php';

function json_out(array $data, int $code = 200): void
{
    http_response_code($code);
    header('Content-Type: application/json; charset=utf-8');
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Authorization');
    echo json_encode($data, JSON_UNESCAPED_UNICODE);
    exit;
}

function json_ok($data = null): void
{
    json_out(['success' => true, 'data' => $data]);
}

function json_err(string $msg, int $code = 400): void
{
    json_out(['success' => false, 'message' => $msg], $code);
}

function body(): array
{
    $raw = file_get_contents('php://input');
    $j = json_decode($raw, true);
    return is_array($j) ? $j : [];
}

function bearer_token(): ?string
{
    $h = $_SERVER['HTTP_AUTHORIZATION'] ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] ?? '';
    if (preg_match('/Bearer\s+(\S+)/i', $h, $m)) {
        return $m[1];
    }
    return null;
}

function gen_token(int $len = 64): string
{
    return bin2hex(random_bytes((int)ceil($len / 2)));
}

function current_user(): ?array
{
    $tok = bearer_token();
    if (!$tok) {
        return null;
    }
    $st = db()->prepare(
        'SELECT u.* FROM api_tokens t JOIN users u ON u.id = t.user_id
         WHERE t.token = ? AND (t.expires_at IS NULL OR t.expires_at > NOW())'
    );
    $st->execute([$tok]);
    $u = $st->fetch();
    return $u ?: null;
}

function require_auth(): array
{
    $u = current_user();
    if (!$u) {
        json_err('Unauthenticated', 401);
    }
    return $u;
}

function require_role(array $roles): array
{
    $u = require_auth();
    if (!in_array($u['role'], $roles, true)) {
        json_err('Forbidden', 403);
    }
    return $u;
}

function notif(int $userId, string $title, string $body = '', ?string $refType = null, ?int $refId = null): void
{
    $st = db()->prepare(
        'INSERT INTO notifications (user_id, title, body, ref_type, ref_id)
         VALUES (?, ?, ?, ?, ?)'
    );
    $st->execute([$userId, $title, $body, $refType, $refId]);
}