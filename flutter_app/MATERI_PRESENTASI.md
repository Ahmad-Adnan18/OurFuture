# 📱 Materi Presentasi Tugas Akhir
## Pemrograman Berbasis Platform

---

# OurFuture - Couple Finance Tracker
### Aplikasi Pencatatan Keuangan Kolaboratif untuk Pasangan

**Nama:** [Nama Kamu]  
**NIM:** [NIM Kamu]  
**Mata Kuliah:** Pemrograman Berbasis Platform  
**Tanggal:** 3 Januari 2026

---

## 📋 Daftar Isi

1. [Pendahuluan](#1-pendahuluan)
2. [Latar Belakang & Masalah](#2-latar-belakang--masalah)
3. [Solusi yang Ditawarkan](#3-solusi-yang-ditawarkan)
4. [Arsitektur Sistem](#4-arsitektur-sistem)
5. [Tech Stack](#5-tech-stack)
6. [Implementasi Flutter](#6-implementasi-flutter)
7. [Fitur Aplikasi](#7-fitur-aplikasi)
8. [Demo Aplikasi](#8-demo-aplikasi)
9. [Kesimpulan](#9-kesimpulan)

---

## 1. Pendahuluan

### Apa itu OurFuture?

**OurFuture** adalah aplikasi pencatatan keuangan berbasis mobile yang dirancang khusus untuk pasangan. Aplikasi ini memungkinkan dua orang (pasangan) untuk bersama-sama:

- 📊 **Memantau keuangan** dari berbagai sumber (bank, e-wallet, cash)
- 🎯 **Menetapkan tujuan bersama** (tabungan nikah, rumah, liburan)
- 💰 **Mencatat transaksi** secara real-time
- 📈 **Melihat progress** menuju target finansial

### Mengapa Topik Ini Relevan?

Berdasarkan survei:
- **65% pasangan** mengalami konflik karena masalah keuangan
- **78% milenial** menggunakan smartphone untuk mengelola keuangan
- Aplikasi keuangan existing **tidak mendukung kolaborasi** antar pengguna

---

## 2. Latar Belakang & Masalah

### Masalah yang Dihadapi Pasangan

```
┌─────────────────────────────────────────────────────────┐
│                    MASALAH UTAMA                        │
├─────────────────────────────────────────────────────────┤
│ 1. Aset tersebar di banyak tempat                       │
│    → Bank A, Bank B, E-Wallet, Cash, Investasi          │
│                                                         │
│ 2. Tidak ada visibilitas bersama                        │
│    → "Tabungan kita sekarang berapa sih?"               │
│                                                         │
│ 3. Sulit track progress tujuan                          │
│    → "Target nikah 100jt, sudah berapa ya?"             │
│                                                         │
│ 4. Aplikasi existing = personal, bukan couple           │
│    → Money Manager, Wallet, dll = single user           │
└─────────────────────────────────────────────────────────┘
```

### Target User

| Persona | Deskripsi |
|---------|-----------|
| **Pasangan Muda** | Usia 20-35 tahun, merencanakan masa depan bersama |
| **Tech-Savvy** | Terbiasa menggunakan aplikasi mobile |
| **Goal-Oriented** | Memiliki tujuan finansial jelas (nikah, rumah, dll) |

---

## 3. Solusi yang Ditawarkan

### Konsep Utama OurFuture

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│   📱 SATU APLIKASI                                      │
│         ↓                                               │
│   👫 DUA PENGGUNA (Pasangan)                            │
│         ↓                                               │
│   🏦 BANYAK DOMPET (Bank, E-Wallet, Cash)               │
│         ↓                                               │
│   🎯 BANYAK TUJUAN (Goals)                              │
│         ↓                                               │
│   💳 TRANSAKSI TERCATAT                                 │
│         ↓                                               │
│   📊 DASHBOARD REAL-TIME                                │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Unique Value Proposition

1. **Multi-Tenancy Architecture**
   - 1 User bisa memiliki banyak "Team" (Workspace)
   - 1 Team = 1 Pasangan
   - Data terisolasi antar Team

2. **Spending vs Saving Logic**
   - **Expense:** Uang terpakai untuk tujuan → Progress tidak turun
   - **Withdrawal:** Uang diambil bukan untuk tujuan → Progress turun

3. **Cross-Platform**
   - Web App (React)
   - Mobile App (Flutter)
   - Satu Backend (Laravel)

---

## 4. Arsitektur Sistem

### High-Level Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                       │
├─────────────────────────────┬────────────────────────────────┤
│                             │                                │
│   ┌─────────────────────┐   │   ┌──────────────────────┐     │
│   │    FLUTTER APP      │   │   │     REACT WEB        │     │
│   │    (Mobile/Desktop) │   │   │     (Inertia.js)     │     │
│   │                     │   │   │                      │     │
│   │  • Dart Language    │   │   │  • JavaScript/JSX    │     │
│   │  • Material Design  │   │   │  • Tailwind CSS      │     │
│   │  • State: Services  │   │   │  • State: useForm    │     │
│   └──────────┬──────────┘   │   └───────────┬──────────┘     │
│              │              │               │                │
│              │ REST API     │               │ Inertia        │
│              │ (JSON)       │               │ Protocol       │
│              │              │               │                │
└──────────────┼──────────────┴───────────────┼────────────────┘
               │                              │
               ▼                              ▼
┌──────────────────────────────────────────────────────────────┐
│                       API LAYER                               │
│                                                              │
│   ┌────────────────────────────────────────────────────┐     │
│   │              LARAVEL 11 BACKEND                    │     │
│   │                                                    │     │
│   │  routes/api.php          routes/web.php            │     │
│   │       ↓                        ↓                   │     │
│   │  Api\Controllers         App\Controllers           │     │
│   │       ↓                        ↓                   │     │
│   │  JSON Response           Inertia Response          │     │
│   └────────────────────────────────────────────────────┘     │
│                              │                               │
└──────────────────────────────┼───────────────────────────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────┐
│                      DATA LAYER                               │
│                                                              │
│   ┌────────────────┐    ┌────────────────┐                   │
│   │    MODELS      │    │    DATABASE    │                   │
│   │                │    │                │                   │
│   │  • User        │◄──►│    MySQL       │                   │
│   │  • Team        │    │                │                   │
│   │  • Goal        │    │  Tables:       │                   │
│   │  • Storage     │    │  • users       │                   │
│   │  • Transaction │    │  • teams       │                   │
│   └────────────────┘    │  • goals       │                   │
│                         │  • storage_acc │                   │
│                         │  • transactions│                   │
│                         └────────────────┘                   │
└──────────────────────────────────────────────────────────────┘
```

### Authentication Flow (Sanctum Token)

```
┌─────────┐                                      ┌─────────┐
│ FLUTTER │                                      │ LARAVEL │
│   APP   │                                      │   API   │
└────┬────┘                                      └────┬────┘
     │                                                │
     │  1. POST /api/auth/login                       │
     │     {email, password}                          │
     │ ──────────────────────────────────────────────►│
     │                                                │
     │  2. Validate credentials                       │
     │     Generate Sanctum Token                     │
     │                                                │
     │  3. Return token + user data                   │
     │ ◄──────────────────────────────────────────────│
     │     {token: "xxx", user: {...}}                │
     │                                                │
     │  4. Store token locally                        │
     │     (SharedPreferences)                        │
     │                                                │
     │  5. GET /api/dashboard                         │
     │     Header: Authorization: Bearer xxx          │
     │ ──────────────────────────────────────────────►│
     │                                                │
     │  6. Validate token, return data                │
     │ ◄──────────────────────────────────────────────│
     │     {totalAssets: 1000000, ...}                │
     │                                                │
```

---

## 5. Tech Stack

### Backend (Laravel 11)

| Komponen | Teknologi | Fungsi |
|----------|-----------|--------|
| **Framework** | Laravel 11 | MVC Framework PHP |
| **Boilerplate** | Jetstream | Auth, Teams, Profile |
| **API Auth** | Sanctum | Token-based authentication |
| **Database** | MySQL 8.0 | Relational database |
| **ORM** | Eloquent | Object-Relational Mapping |

### Frontend Mobile (Flutter)

| Komponen | Teknologi | Fungsi |
|----------|-----------|--------|
| **Framework** | Flutter 3.x | Cross-platform UI toolkit |
| **Language** | Dart | Primary programming language |
| **HTTP Client** | Dio | API requests dengan interceptors |
| **State** | Service Layer | Business logic separation |
| **Storage** | SharedPreferences | Local token storage |
| **Navigation** | GoRouter | Declarative routing |
| **UI** | Material 3 | Modern design system |

### Database Schema

```
┌─────────────────┐       ┌─────────────────┐
│     users       │       │     teams       │
├─────────────────┤       ├─────────────────┤
│ id              │       │ id              │
│ name            │◄─────►│ name            │
│ email           │       │ personal_team   │
│ password        │       │ user_id (owner) │
│ current_team_id │       └─────────────────┘
└─────────────────┘              │
         │                       │ team_id
         │                       ▼
         │        ┌─────────────────────────────┐
         │        │      storage_accounts       │
         │        ├─────────────────────────────┤
         │        │ id                          │
         │        │ team_id ◄───────────────────┤
         │        │ name                        │
         │        │ type (bank/e-wallet/cash)   │
         │        │ balance                     │
         │        └─────────────────────────────┘
         │
         │        ┌─────────────────────────────┐
         │        │          goals              │
         │        ├─────────────────────────────┤
         │        │ id                          │
         │        │ team_id ◄───────────────────┤
         │        │ title                       │
         │        │ target_amount               │
         │        │ current_balance             │
         │        │ total_collected             │
         │        │ status                      │
         │        └─────────────────────────────┘
         │
         │        ┌─────────────────────────────┐
         │        │       transactions          │
         │        ├─────────────────────────────┤
         │        │ id                          │
         │        │ team_id ◄───────────────────┤
         │        │ user_id (who created)       │
         │        │ storage_account_id          │
         │        │ goal_id (nullable)          │
         │        │ type (deposit/expense/...)  │
         │        │ amount                      │
         │        │ date                        │
         │        │ notes                       │
         └────────┴─────────────────────────────┘
```

---

## 6. Implementasi Flutter

### Struktur Project

```
flutter_app/
├── lib/
│   ├── main.dart                 # Entry point + Router
│   ├── config/
│   │   └── api_config.dart       # API endpoints
│   ├── models/                   # Data classes
│   │   ├── user.dart
│   │   ├── goal.dart
│   │   ├── storage_account.dart
│   │   ├── transaction.dart
│   │   └── dashboard.dart
│   ├── services/                 # Business logic
│   │   ├── api_service.dart      # HTTP client
│   │   ├── auth_service.dart     # Authentication
│   │   ├── dashboard_service.dart
│   │   ├── goal_service.dart
│   │   ├── wallet_service.dart
│   │   └── transaction_service.dart
│   ├── screens/                  # UI pages
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── goals/
│   │   ├── wallets/
│   │   └── transactions/
│   └── widgets/                  # Reusable components
│       ├── goal_card.dart
│       ├── transaction_tile.dart
│       ├── progress_bar.dart
│       └── money_input.dart
└── pubspec.yaml                  # Dependencies
```

### Konsep Pemrograman Platform yang Digunakan

#### 1. **Service Layer Pattern**

```dart
// services/auth_service.dart
class AuthService {
  final ApiService _api = ApiService();

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    
    final authResponse = AuthResponse.fromJson(response.data);
    await _api.setToken(authResponse.token);
    
    return authResponse;
  }
}
```

**Keuntungan:**
- ✅ Separation of Concerns
- ✅ Reusable di berbagai screens
- ✅ Testable

#### 2. **HTTP Interceptor untuk Authentication**

```dart
// services/api_service.dart
_dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) async {
    final token = await getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  },
  onError: (error, handler) async {
    if (error.response?.statusCode == 401) {
      await clearToken(); // Auto logout on unauthorized
    }
    return handler.next(error);
  },
));
```

**Keuntungan:**
- ✅ Token otomatis di-attach ke setiap request
- ✅ Auto logout jika token expired
- ✅ Centralized error handling

#### 3. **JSON Serialization dengan Code Generation**

```dart
// models/goal.dart
@JsonSerializable()
class Goal {
  final int id;
  final String title;
  
  @JsonKey(name: 'target_amount')
  final double targetAmount;
  
  @JsonKey(name: 'current_balance')
  final double currentBalance;
  
  Goal({required this.id, required this.title, ...});
  
  factory Goal.fromJson(Map<String, dynamic> json) => _$GoalFromJson(json);
  Map<String, dynamic> toJson() => _$GoalToJson(this);
}
```

**Keuntungan:**
- ✅ Type-safe JSON parsing
- ✅ Auto-generated boilerplate code
- ✅ Mapping snake_case → camelCase

#### 4. **Declarative Navigation dengan GoRouter**

```dart
// main.dart
final GoRouter _router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) async {
    final isAuthenticated = await authService.isAuthenticated();
    final isAuthRoute = state.matchedLocation == '/login' || 
                        state.matchedLocation == '/register';

    if (!isAuthenticated && !isAuthRoute) return '/login';
    if (isAuthenticated && isAuthRoute) return '/dashboard';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => LoginScreen()),
    GoRoute(path: '/dashboard', builder: (_, __) => DashboardScreen()),
    // ...
  ],
);
```

**Keuntungan:**
- ✅ Route guards (protect authenticated routes)
- ✅ Deep linking support
- ✅ Type-safe routing

---

## 7. Fitur Aplikasi

### Fitur Utama

| No | Fitur | Deskripsi | Screenshot |
|----|-------|-----------|------------|
| 1 | **Authentication** | Login & Register dengan Sanctum Token | [Demo] |
| 2 | **Dashboard** | Ringkasan total aset dan goals | [Demo] |
| 3 | **Goals Management** | CRUD tujuan keuangan | [Demo] |
| 4 | **Wallets Management** | CRUD dompet/rekening | [Demo] |
| 5 | **Transactions** | Catat deposit, expense, withdrawal | [Demo] |
| 6 | **Progress Tracking** | Visual progress bar untuk setiap goal | [Demo] |

### API Endpoints

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| POST | `/api/auth/register` | Register user baru |
| POST | `/api/auth/login` | Login, return token |
| POST | `/api/auth/logout` | Logout, revoke token |
| GET | `/api/dashboard` | Data summary dashboard |
| GET | `/api/goals` | List semua goals |
| POST | `/api/goals` | Buat goal baru |
| PUT | `/api/goals/{id}` | Update goal |
| DELETE | `/api/goals/{id}` | Hapus goal |
| GET | `/api/wallets` | List semua wallets |
| POST | `/api/wallets` | Buat wallet baru |
| PUT | `/api/wallets/{id}` | Update wallet |
| DELETE | `/api/wallets/{id}` | Hapus wallet |
| GET | `/api/transactions` | List transaksi (paginated) |
| POST | `/api/transactions` | Buat transaksi baru |

---

## 8. Demo Aplikasi

### Skenario Demo

#### 🎬 Scene 1: Authentication (2 menit)
1. Buka aplikasi → Tampil halaman Login
2. Klik "Register" → Isi form → Submit
3. Otomatis masuk ke Dashboard
4. Logout → Login lagi dengan akun yang dibuat

#### 🎬 Scene 2: Membuat Goal (2 menit)
1. Dari Dashboard, navigasi ke "Goals"
2. Klik tombol "+" → Isi form:
   - Title: "Tabungan Nikah"
   - Target: Rp 100.000.000
   - Target Date: 31 Desember 2026
3. Goal baru muncul dengan progress 0%

#### 🎬 Scene 3: Menambah Wallet (1 menit)
1. Navigasi ke "Wallets"
2. Klik "+" → Tambah:
   - Name: "Bank Jago"
   - Type: Bank
   - Balance: Rp 5.000.000

#### 🎬 Scene 4: Input Transaksi (3 menit)
1. Klik FAB (tombol +) di tengah bawah
2. Pilih type "Deposit"
3. Isi:
   - Amount: Rp 1.000.000
   - Wallet: Bank Jago
   - Goal: Tabungan Nikah
4. Submit → Lihat progress goal naik menjadi 1%

5. Buat transaksi "Expense":
   - Amount: Rp 500.000
   - Wallet: Bank Jago
   - Goal: Tabungan Nikah
   - Notes: "DP Gedung"
6. Progress TETAP 1% (karena expense untuk goal)

#### 🎬 Scene 5: Dashboard Overview (1 menit)
1. Kembali ke Dashboard
2. Tunjukkan:
   - Total Assets: Rp 4.500.000
   - Goal cards dengan progress
   - Recent transactions

---

## 9. Kesimpulan

### Apa yang Dipelajari

1. **Cross-Platform Development**
   - Satu codebase Flutter → Android, iOS, Windows, Web
   
2. **REST API Integration**
   - Komunikasi client-server via HTTP
   - JSON serialization/deserialization
   
3. **Token-Based Authentication**
   - Sanctum Token untuk API security
   - Token storage di client side
   
4. **Modern App Architecture**
   - Service layer pattern
   - Separation of concerns
   - Clean project structure

### Tantangan yang Dihadapi

| Tantangan | Solusi |
|-----------|--------|
| Compatibility Flutter version | Update deprecated APIs |
| Windows build dependencies | Enable Developer Mode |
| Token storage security | SharedPreferences (dev) |
| API error handling | Dio interceptors |

### Pengembangan Selanjutnya

1. 📱 **Release ke Play Store & App Store**
2. 🔔 **Push Notifications** untuk reminder
3. 📊 **Analytics & Reports** bulanan
4. 🤝 **Real-time sync** dengan WebSocket
5. 🔐 **Biometric authentication**

---

## 🙏 Terima Kasih

### Pertanyaan?

---

# Lampiran

## Cara Menjalankan Project

### Backend (Laravel)
```bash
cd our-future-saas
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan serve
```

### Frontend (Flutter)
```bash
cd flutter_app
flutter pub get
flutter pub run build_runner build
flutter run
```

### Build Production
```bash
# Windows
flutter build windows --release

# Android APK
flutter build apk --release

# Web
flutter build web
```

---

## Referensi

1. Flutter Documentation - https://flutter.dev/docs
2. Laravel Sanctum - https://laravel.com/docs/sanctum
3. Dio Package - https://pub.dev/packages/dio
4. GoRouter - https://pub.dev/packages/go_router
5. Material Design 3 - https://m3.material.io
