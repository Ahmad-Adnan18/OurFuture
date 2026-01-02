import '../config/api_config.dart';
import '../models/storage_account.dart';
import 'api_service.dart';

/// Wallet Service for CRUD operations on storage accounts
class WalletService {
  final ApiService _api = ApiService();

  /// Get all wallets
  Future<List<StorageAccount>> getWallets() async {
    final response = await _api.get(ApiConfig.wallets);
    
    final List<dynamic> data = response.data['data'] ?? response.data;
    return data.map((json) => StorageAccount.fromJson(json)).toList();
  }

  /// Get single wallet by ID
  Future<StorageAccount> getWallet(int id) async {
    final response = await _api.get(ApiConfig.wallet(id));
    return StorageAccount.fromJson(response.data['data'] ?? response.data);
  }

  /// Create new wallet
  Future<StorageAccount> createWallet({
    required String name,
    required String type,
    required double balance,
  }) async {
    final response = await _api.post(
      ApiConfig.wallets,
      data: {
        'name': name,
        'type': type,
        'balance': balance,
      },
    );
    
    return StorageAccount.fromJson(response.data['wallet']);
  }

  /// Update existing wallet
  Future<StorageAccount> updateWallet(
    int id, {
    required String name,
    required String type,
    required double balance,
  }) async {
    final response = await _api.put(
      ApiConfig.wallet(id),
      data: {
        'name': name,
        'type': type,
        'balance': balance,
      },
    );
    
    return StorageAccount.fromJson(response.data['wallet']);
  }

  /// Delete wallet
  Future<void> deleteWallet(int id) async {
    await _api.delete(ApiConfig.wallet(id));
  }
}
