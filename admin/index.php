<?php
declare(strict_types=1);

error_reporting(E_ALL);
ini_set('display_errors', '0');

session_start();

const API_BASE = 'http://localhost/delivery-mvp-api/public/api';

function api_call(string $method, string $path, array $payload = [], ?string $token = null): array
{
    $opts = ['http' => [
        'method' => $method,
        'ignore_errors' => true,
        'header' => 'Content-Type: application/json',
        'timeout' => 10,
    ]];
    if ($token !== null) {
        $opts['http']['header'] .= "\r\nAuthorization: Bearer " . $token;
    }
    if ($payload) {
        $opts['http']['content'] = json_encode($payload, JSON_UNESCAPED_UNICODE);
    }
    $raw = @file_get_contents(API_BASE . $path, false, stream_context_create($opts));
    if ($raw === false) {
        return ['success' => false, 'message' => 'API connection failed'];
    }
    return json_decode($raw, true) ?: ['success' => false, 'message' => 'Bad API response'];
}

function admin_token(): ?string
{
    return $_SESSION['admin_token'] ?? null;
}

function logout(): void
{
    unset($_SESSION['admin_token']);
}

$action = $_GET['action'] ?? '';
$msg = '';

if ($action === 'logout') {
    logout();
    header('Location: index.php');
    exit;
}

if (!admin_token()) {
    if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['form'] ?? '') === 'login') {
        $res = api_call('POST', '/auth/login', ['phone' => trim($_POST['phone'] ?? ''), 'password' => $_POST['password'] ?? '']);
        if (($res['success'] ?? false) && ($res['data']['user']['role'] ?? '') === 'admin') {
            $_SESSION['admin_token'] = $res['data']['token'];
            header('Location: index.php');
            exit;
        }
        $msg = 'بيانات الدخول غير صحيحة أو ليس لديك صلاحية الأدمن';
    }
    ?>
    <!DOCTYPE html>
    <html lang="ar" dir="rtl">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>لوحة التحكم - دخول</title>
        <style>
            body{font-family:'Segoe UI',Tahoma,sans-serif;background:#f1f4f9;display:flex;align-items:center;justify-content:center;min-height:100vh;margin:0}
            .card{background:#fff;padding:32px;border-radius:14px;box-shadow:0 10px 30px rgba(0,0,0,.08);width:340px}
            h1{font-size:20px;margin:0 0 18px;color:#1e293b}
            input{width:100%;padding:11px 12px;margin-bottom:12px;border:1px solid #e2e8f0;border-radius:8px;box-sizing:border-box;font-size:14px}
            button{width:100%;padding:12px;background:#2563eb;color:#fff;border:0;border-radius:8px;font-size:15px;cursor:pointer;font-weight:600}
            .err{background:#fee2e2;color:#b91c1c;padding:10px;border-radius:8px;margin-bottom:12px;font-size:13px}
        </style>
    </head>
    <body>
        <form class="card" method="post">
            <h1>لوحة التحكم</h1>
            <?php if ($msg) echo '<div class="err">' . htmlspecialchars($msg) . '</div>'; ?>
            <input type="hidden" name="form" value="login">
            <input type="text" name="phone" placeholder="رقم الهاتف" required>
            <input type="password" name="password" placeholder="كلمة المرور" required>
            <button type="submit">دخول</button>
        </form>
    </body>
    </html>
    <?php
    exit;
}

$token = admin_token();

if (($_POST['form'] ?? '') === 'status') {
    $orderId = (int)($_POST['order_id'] ?? 0);
    $status = (string)($_POST['status'] ?? '');
    $allowed = ['pending', 'accepted', 'on_the_way', 'in_service', 'completed', 'canceled'];
    if ($orderId > 0 && in_array($status, $allowed, true)) {
        api_call('POST', "/orders/$orderId/status", ['status' => $status], $token);
    }
    header('Location: index.php');
    exit;
}

$stats = api_call('GET', '/admin/stats', [], $token);
$orders = api_call('GET', '/orders', [], $token);
$providers = api_call('GET', '/providers', [], $token);
$services = api_call('GET', '/services', [], $token);

$statusFilter = $_GET['status'] ?? '';
$ordersList = ($orders['data'] ?? []);
if ($statusFilter !== '') {
    $ordersList = array_values(array_filter($ordersList, fn($o) => $o['status'] === $statusFilter));
}

$statusLabels = [
    'pending' => 'قيد الانتظار', 'accepted' => 'تم القبول', 'on_the_way' => 'في الطريق',
    'in_service' => 'جارِ التنفيذ', 'completed' => 'مكتمل', 'rejected' => 'مرفوض', 'canceled' => 'ملغي',
];
$statusColors = [
    'pending' => '#d97706', 'accepted' => '#2563eb', 'on_the_way' => '#0891b2',
    'in_service' => '#7c3aed', 'completed' => '#16a34a', 'rejected' => '#b91c1c', 'canceled' => '#64748b',
];
$servicesById = [];
foreach (($services['data'] ?? []) as $s) {
    $servicesById[$s['id']] = $s['name_ar'];
}
?>
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>لوحة التحكم - التوصيل</title>
    <style>
        body{font-family:'Segoe UI',Tahoma,sans-serif;background:#f1f4f9;margin:0;color:#0f172a}
        header{background:#0f172a;color:#fff;padding:16px 24px;display:flex;justify-content:space-between;align-items:center}
        header h1{font-size:18px;margin:0}
        header a{color:#93c5fd;text-decoration:none;font-size:14px}
        main{max-width:1200px;margin:24px auto;padding:0 16px}
        .cards{display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:16px;margin-bottom:24px}
        .card{background:#fff;border-radius:12px;padding:18px;box-shadow:0 4px 14px rgba(0,0,0,.06)}
        .card .n{font-size:28px;font-weight:700;color:#2563eb}
        .card .l{font-size:13px;color:#64748b}
        .panel{background:#fff;border-radius:12px;padding:20px;box-shadow:0 4px 14px rgba(0,0,0,.06);margin-bottom:24px}
        .panel h2{font-size:16px;margin:0 0 14px}
        table{width:100%;border-collapse:collapse;font-size:13px}
        th,td{padding:10px 8px;text-align:right;border-bottom:1px solid #e2e8f0}
        th{color:#64748b;font-weight:600}
        .badge{display:inline-block;padding:3px 10px;border-radius:20px;color:#fff;font-size:12px}
        .filters{display:flex;gap:8px;flex-wrap:wrap;margin-bottom:14px}
        .filters a{padding:6px 14px;border-radius:20px;background:#e2e8f0;color:#0f172a;text-decoration:none;font-size:13px}
        .filters a.on{background:#2563eb;color:#fff}
        select,button{padding:7px 10px;border-radius:8px;border:1px solid #e2e8f0;font-size:13px}
        button{background:#2563eb;color:#fff;border:0;cursor:pointer}
        .muted{color:#94a3b8;font-size:12px}
        .grid2{display:grid;grid-template-columns:1fr 1fr;gap:16px}
        @media(max-width:800px){.grid2{grid-template-columns:1fr}}
    </style>
</head>
<body>
<header>
    <h1>لوحة تحكم السيطرة — منصة التوصيل</h1>
    <a href="?action=logout">تسجيل الخروج</a>
</header>
<main>
    <div class="cards">
        <div class="card"><div class="n"><?= htmlspecialchars((string)($stats['data']['orders'] ?? 0)) ?></div><div class="l">إجمالي الطلبات</div></div>
        <div class="card"><div class="n"><?= htmlspecialchars((string)($stats['data']['users'] ?? 0)) ?></div><div class="l">المستخدمون</div></div>
        <div class="card"><div class="n"><?= htmlspecialchars((string)($stats['data']['providers'] ?? 0)) ?></div><div class="l">مقدمو الخدمة</div></div>
        <div class="card"><div class="n"><?= htmlspecialchars((string)($stats['data']['completed'] ?? 0)) ?></div><div class="l">مكتملة</div></div>
    </div>

    <div class="panel">
        <h2>الطلبات</h2>
        <div class="filters">
            <a href="index.php" class="<?= $statusFilter === '' ? 'on' : '' ?>">الكل</a>
            <?php foreach ($statusLabels as $k => $v): ?>
                <a href="?status=<?= htmlspecialchars($k) ?>" class="<?= $statusFilter === $k ? 'on' : '' ?>"><?= $v ?></a>
            <?php endforeach; ?>
        </div>
        <table>
            <tr><th>#</th><th>رقم الطلب</th><th>الخدمة</th><th>العنوان</th><th>الحالة</th><th>العميل</th><th>مقدم الخدمة</th><th>تغيير الحالة</th></tr>
            <?php foreach ($ordersList as $o): ?>
                <tr>
                    <td><?= (int)$o['id'] ?></td>
                    <td><?= htmlspecialchars($o['order_no']) ?></td>
                    <td><?= htmlspecialchars($servicesById[$o['service_id']] ?? '?') ?></td>
                    <td><?= htmlspecialchars((string)$o['address'] ?: '—') ?></td>
                    <td><span class="badge" style="background:<?= $statusColors[$o['status']] ?? '#64748b' ?>"><?= $statusLabels[$o['status']] ?? $o['status'] ?></span></td>
                    <td>#<?= (int)$o['customer_id'] ?></td>
                    <td><?= $o['provider_id'] ? '#' . (int)$o['provider_id'] : '<span class="muted">غير مخصص</span>' ?></td>
                    <td>
                        <form method="post" style="display:flex;gap:6px">
                            <input type="hidden" name="form" value="status">
                            <input type="hidden" name="order_id" value="<?= (int)$o['id'] ?>">
                            <select name="status">
                                <?php foreach ($statusLabels as $k => $v): ?>
                                    <option value="<?= $k ?>" <?= $o['status'] === $k ? 'selected' : '' ?>><?= $v ?></option>
                                <?php endforeach; ?>
                            </select>
                            <button type="submit">حفظ</button>
                        </form>
                    </td>
                </tr>
            <?php endforeach; ?>
            <?php if (!$ordersList): ?><tr><td colspan="8" class="muted">لا توجد طلبات</td></tr><?php endif; ?>
        </table>
    </div>

    <div class="grid2">
        <div class="panel">
            <h2>مقدمو الخدمة</h2>
            <table>
                <tr><th>الاسم</th><th>التقييم</th><th>الوظائف</th><th>الحالة</th></tr>
                <?php foreach (($providers['data'] ?? []) as $p): ?>
                    <tr>
                        <td><?= htmlspecialchars((string)$p['name']) ?></td>
                        <td><?= htmlspecialchars((string)$p['rating']) ?: '—' ?></td>
                        <td><?= (int)$p['jobs_count'] ?></td>
                        <td><span class="badge" style="background:<?= (int)$p['is_online'] ? '#16a34a' : '#64748b' ?>"><?= (int)$p['is_online'] ? 'متصل' : 'غير متصل' ?></span></td>
                    </tr>
                <?php endforeach; ?>
            </table>
        </div>
        <div class="panel">
            <h2>الخدمات</h2>
            <table>
                <tr><th>#</th><th>العربية</th><th>الإنجليزية</th></tr>
                <?php foreach (($services['data'] ?? []) as $s): ?>
                    <tr><td><?= (int)$s['id'] ?></td><td><?= htmlspecialchars($s['name_ar']) ?></td><td><?= htmlspecialchars($s['name_en']) ?></td></tr>
                <?php endforeach; ?>
            </table>
        </div>
    </div>
</main>
</body>
</html>