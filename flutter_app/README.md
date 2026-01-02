# OurFuture - Flutter Mobile App

Mobile companion app for OurFuture Couple Finance Tracker, built with Flutter.

## Prerequisites

- Flutter SDK 3.0 or higher
- Android Studio / VS Code with Flutter extensions
- Laravel backend running (for API access)

## Getting Started

### 1. Install Dependencies

```bash
cd flutter_app
flutter pub get
```

### 2. Generate Model Files

The project uses `json_serializable` for JSON parsing. Generate the `.g.dart` files:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Configure API URL

Edit `lib/config/api_config.dart` and update the `baseUrl`:

```dart
// For Android Emulator connecting to localhost
static const String baseUrl = 'http://10.0.2.2:8000/api';

// For iOS Simulator
static const String baseUrl = 'http://localhost:8000/api';

// For Physical Device (use your computer's IP)
static const String baseUrl = 'http://192.168.1.x:8000/api';

// For Production
static const String baseUrl = 'https://your-domain.com/api';
```

### 4. Run the App

```bash
# Start Laravel backend first
cd ../
php artisan serve

# In another terminal, run Flutter app
cd flutter_app
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point with routing
├── config/
│   └── api_config.dart       # API endpoints configuration
├── models/
│   ├── user.dart            # User & Team models
│   ├── goal.dart            # Goal model
│   ├── storage_account.dart # Wallet model
│   ├── transaction.dart     # Transaction model
│   └── dashboard.dart       # Dashboard data model
├── services/
│   ├── api_service.dart     # HTTP client with auth
│   ├── auth_service.dart    # Authentication
│   ├── dashboard_service.dart
│   ├── goal_service.dart
│   ├── wallet_service.dart
│   └── transaction_service.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── dashboard_screen.dart
│   ├── goals/
│   │   ├── goals_screen.dart
│   │   └── goal_form_screen.dart
│   ├── wallets/
│   │   └── wallets_screen.dart
│   └── transactions/
│       ├── transactions_screen.dart
│       └── transaction_form_screen.dart
└── widgets/
    ├── goal_card.dart
    ├── transaction_tile.dart
    ├── progress_bar.dart
    └── money_input.dart
```

## Features

- ✅ User Authentication (Login/Register/Logout)
- ✅ Dashboard with summary cards
- ✅ Goals management (CRUD)
- ✅ Wallets/Storage accounts management (CRUD)
- ✅ Transaction creation and history
- ✅ Bottom navigation with FAB for quick transaction
- ✅ Pull-to-refresh on all screens
- ✅ Swipe to delete transactions
- ✅ Dark mode support

## API Endpoints

All API calls go through Laravel Sanctum authentication:

| Endpoint | Description |
|----------|-------------|
| `POST /api/auth/login` | Login with email/password |
| `POST /api/auth/register` | Register new user |
| `POST /api/auth/logout` | Logout |
| `GET /api/dashboard` | Dashboard summary |
| `GET/POST /api/goals` | Goals CRUD |
| `GET/POST /api/wallets` | Wallets CRUD |
| `GET/POST /api/transactions` | Transactions CRUD |
| `GET /api/teams` | Team management |

## Troubleshooting

### Network Error on Android Emulator

If you're getting network errors, make sure:
1. Laravel server is running on `0.0.0.0:8000` (not just localhost)
   ```bash
   php artisan serve --host=0.0.0.0
   ```
2. Android allows cleartext traffic (for development). Add to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <application android:usesCleartextTraffic="true" ...>
   ```

### Token Storage Issues

The app uses `flutter_secure_storage` for token storage. On iOS, this requires Keychain access. On Android, it uses EncryptedSharedPreferences.

## Building for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle

# iOS
flutter build ios --release
```

## License

This project is part of OurFuture SaaS application.
