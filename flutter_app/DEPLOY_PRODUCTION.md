# 🚀 Panduan Deploy API ke Production (hPanel)

## Masalah Saat Ini
Error: `no such table: personal_access_tokens`

Ini karena migrasi Sanctum belum jalan di production.

---

## ✅ Langkah Deploy

### Step 1: Upload File API (via Git atau File Manager)

**File Baru yang Perlu Di-Upload:**

```
app/Http/Controllers/Api/
├── AuthController.php
├── DashboardController.php
├── GoalController.php
├── StorageAccountController.php
├── TransactionController.php
└── TeamController.php

app/Http/Resources/
├── UserResource.php
├── TeamResource.php
├── GoalResource.php
├── StorageAccountResource.php
└── TransactionResource.php
```

**File yang Di-Update:**
```
routes/api.php
```

---

### Step 2: Run Sanctum Migration

Di SSH/Terminal Hostinger, jalankan:

```bash
cd public_html
php artisan migrate --path=vendor/laravel/sanctum/database/migrations
```

Atau jika tidak bisa, buat migration manual:

```bash
php artisan make:migration create_personal_access_tokens_table
```

Lalu isi dengan:
```php
Schema::create('personal_access_tokens', function (Blueprint $table) {
    $table->id();
    $table->morphs('tokenable');
    $table->string('name');
    $table->string('token', 64)->unique();
    $table->text('abilities')->nullable();
    $table->timestamp('last_used_at')->nullable();
    $table->timestamp('expires_at')->nullable();
    $table->timestamps();
});
```

Jalankan:
```bash
php artisan migrate
```

---

### Step 3: Clear Cache

```bash
php artisan config:clear
php artisan route:clear
php artisan cache:clear
```

---

### Step 4: Test API

Buka browser:
```
https://app.nandevv.com/api/auth/login
```

Jika muncul `405 Method Not Allowed`, berarti API sudah aktif!

---

## 📱 Setelah Deploy, Update Flutter

Di `lib/config/api_config.dart`, uncomment production URL:

```dart
// static const String baseUrl = 'http://127.0.0.1:8000/api';
static const String baseUrl = 'https://app.nandevv.com/api';
```

Lalu:
```bash
flutter run -d windows
```

---

## 🎤 Tips Presentasi

Jika APK belum siap, demo bisa pakai:

1. **Windows App** - Run `flutter run -d windows`
2. **Web Browser** - Run `flutter run -d chrome` (jika web support enabled)
3. **Android Emulator** - Jika ada Android Studio emulator

Untuk presentasi, **Windows app sudah cukup** karena menunjukkan cross-platform capability Flutter.
