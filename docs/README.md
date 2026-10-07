# منصة الخدمات عند الطلب — MVP (Delivery MVP)

منصة خدمات عند الطلب: تطبيق مستخدم، تطبيق مقدم خدمة، لوحة تحكم Web، وBackend كامل.
المرحلة الأولى بدون بوابة دفع — التوصيل والتتبع لحظي عبر تحديثات منتظمة (Polling).

## المكونات

| المكوّن | التقنية | المسار |
|---|---|---|
| Backend REST API | PHP 8.2 (PDO/MySQL) | `backend/` |
| قاعدة البيانات | MariaDB/MySQL | `backend/sql/schema.sql` |
| لوحة تحكم الأدمن | PHP + Bootstrap CSS خفيف | `admin/` |
| تطبيق المستخدم + مقدم الخدمة | Flutter (Android + iOS جاهز للتجميع) | `apps/delivery_app/` |

## قاعدة البيانات

7 جداول: `users`, `provider_profiles`, `services`, `orders`, `locations`, `notifications`, `api_tokens`.

حالات الطلب: `pending → accepted → on_the_way → in_service → completed` (+ `rejected`/`canceled`).

## تشغيل الـ Backend

```bash
# 1) إنشاء القاعدة (من مجلد المشروع)
mysql -u root < backend\sql\schema.sql

# 2) تشغيل الخادم المحلي (اختياري للاختبار)
php -S localhost:8000 -t backend\public backend\public\index.php
```

ملاحظة: لو استخدمت Apache/XAMPP، ضع مجلد `backend` تحت `htdocs` وصِل إلى API عبر
`http://localhost/delivery-mvp/backend/public/` (يوجد `.htaccess`).

## لوحة التحكم (الأدمن)

```bash
php -S localhost:8100 -t admin
```

- دخول مباشر برقم هاتف وكلمة مرور الأدمن.
- شاشات: إحصاءات، كل الطلبات مع فلترة، تغيير/تصحيح حالة أي طلب (إدارة الاستثناءات)،
  مقدمي الخدمة وتقييماتهم، الخدمات.

## تطبيقات Flutter

```bash
cd apps\delivery_app
flutter pub get

# بناء النسخة العامة (تحدد الدور تلقائياً من الحساب)
flutter build apk --debug

# بناء نسخة خاصة بمقدم الخدمة فقط
flutter build apk --debug -t lib/main_provider.dart

# نسخة خاصة بالعميل فقط
flutter build apk --debug -t lib/main_customer.dart
```

- رابط الـ API يُضبط من `lib/config.dart`؛ على Android محلياً يستخدم `10.0.2.2`,
  ولجهاز حقيقي:
  `flutter build apk --debug --dart-define=API_BASE=http://YOUR_PC_LAN_IP:8000/api`
- iOS: الكود جاهز للبناء على جهاز Mac (Xcode) — النشر يتطلب حساب Apple Developer.

## REST API (المسارات الرئيسية)

```
POST /api/auth/register         التسجيل (customer/provider)
POST /api/auth/login            تسجيل الدخول → يَرجع token
POST /api/auth/logout
GET  /api/profile               الملف الشخصي
PUT  /api/profile               تحديث (name/email/lang/خدمة مقدم)
POST /api/provider/status       إبدأ/أنهِ الخدمة (is_online)
GET  /api/services              قائمة الخدمات
GET  /api/orders?status=available   طلبات متاحة (مقدم الخدمة)
GET  /api/orders                قائمة حسب الدور (عميل/مقدم/أدمن)
POST /api/orders                إنشاء طلب (service_id + lat/lng + عنوان)
POST /api/orders/{id}/accept    قبول (مقدم، آمن ضد ازدواجية القبول)
POST /api/orders/{id}/status    on_the_way/in_service/completed
POST /api/orders/{id}/cancel    إلغاء
POST /api/orders/{id}/rate      تقييم (نجوم 1..5)
POST /api/location              بث موقع مقدم الخدمة
GET  /api/locations/{provider_id}  آخر موقع حي
GET  /api/notifications         الإشعارات
POST /api/notifications         تعليم الكل كمقروء
GET  /api/providers             قائمة مقدمي الخدمة
GET  /api/admin/stats           إحصاءات (أدمن)
```

المصادقة: `Authorization: Bearer <token>` — توكين عشوائي في جدول `api_tokens`.

## بيانات تجريبية

| الدور | الهاتف | كلمة المرور |
|---|---|---|
| أدمن | 01000000000 | 123456 |
| عميل | 01011111111 | 123456 |
| مقدم خدمة (سباكة) | 01022222222 | 123456 |

## ملاحظات الدورة القادمة (خارج MVP الحالي)

- **Push حقيقي**: تفعيل Firebase Cloud Messaging (تحتاج `google-services.json` من
  حساب Firebase لدى العميل).
- **خرائط حية**: حالياً عرض إحداثيات + رابط فتح في خرائط جوجل؛ لوحدة الخرائط داخل
  التطبيق تحتاج API key للـ Google Maps.
- **أتمتة اللحظية**: التحديث الحالي Polling (5 ثوانٍ) — استبداله بـ WebSocket/Pusher
  عند الحاجة.