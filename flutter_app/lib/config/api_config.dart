/// API Configuration for OurFuture Flutter App
class ApiConfig {
  // ============================================
  // PILIH SALAH SATU baseUrl SESUAI ENVIRONMENT:
  // ============================================
  
  // 🖥️ LOCAL DEVELOPMENT:
  //static const String baseUrl = 'http://127.0.0.1:8000/api';
  
  // 🚀 PRODUCTION (uncomment when API is deployed):
  static const String baseUrl = 'https://app.nandevv.com/api';
  
  // 🌐 UNTUK WEB (flutter run -d chrome):
  // static const String baseUrl = 'http://127.0.0.1:8000/api';
  
  // 📱 UNTUK ANDROID EMULATOR:
  // static const String baseUrl = 'http://10.0.2.2:8000/api';
  
  // 🍎 UNTUK iOS SIMULATOR:
  // static const String baseUrl = 'http://localhost:8000/api';
  
  // 📲 UNTUK PHYSICAL DEVICE (ganti dengan IP komputer):
  // static const String baseUrl = 'http://192.168.1.XXX:8000/api';
  
  // 🚀 UNTUK PRODUCTION:
  // static const String baseUrl = 'https://your-domain.com/api';
  
  // API Endpoints
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authLogout = '/auth/logout';
  static const String authUser = '/auth/user';
  
  static const String dashboard = '/dashboard';
  
  static const String goals = '/goals';
  static String goal(int id) => '/goals/$id';
  
  static const String wallets = '/wallets';
  static String wallet(int id) => '/wallets/$id';
  
  static const String transactions = '/transactions';
  static String transaction(int id) => '/transactions/$id';
  
  static const String teams = '/teams';
  static String team(int id) => '/teams/$id';
  static String switchTeam(int id) => '/teams/switch/$id';
  static String inviteToTeam(int id) => '/teams/$id/invite';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
