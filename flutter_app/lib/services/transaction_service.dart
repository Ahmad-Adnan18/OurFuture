import '../config/api_config.dart';
import '../models/transaction.dart';
import 'api_service.dart';

/// Transaction Service for CRUD operations on transactions
class TransactionService {
  final ApiService _api = ApiService();

  /// Get all transactions with pagination
  Future<TransactionPaginatedResponse> getTransactions({
    int page = 1,
    int perPage = 20,
    String? type,
    String? month,
  }) async {
    final response = await _api.get(
      ApiConfig.transactions,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (type != null) 'type': type,
        if (month != null) 'month': month,
      },
    );
    
    return TransactionPaginatedResponse.fromJson(response.data);
  }

  /// Get single transaction by ID
  Future<Transaction> getTransaction(int id) async {
    final response = await _api.get(ApiConfig.transaction(id));
    return Transaction.fromJson(response.data['data'] ?? response.data);
  }

  /// Create new transaction
  Future<Transaction> createTransaction({
    required String date,
    required String type,
    required int storageAccountId,
    required double amount,
    int? goalId,
    String? notes,
  }) async {
    final response = await _api.post(
      ApiConfig.transactions,
      data: {
        'date': date,
        'type': type,
        'storage_account_id': storageAccountId,
        'amount': amount,
        if (goalId != null) 'goal_id': goalId,
        if (notes != null) 'notes': notes,
      },
    );
    
    return Transaction.fromJson(response.data['transaction']);
  }

  /// Delete transaction
  Future<void> deleteTransaction(int id) async {
    await _api.delete(ApiConfig.transaction(id));
  }
}

/// Paginated response for transactions
class TransactionPaginatedResponse {
  final List<Transaction> data;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  TransactionPaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
  });

  factory TransactionPaginatedResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> dataList = json['data'] ?? [];
    return TransactionPaginatedResponse(
      data: dataList.map((item) => Transaction.fromJson(item)).toList(),
      currentPage: json['meta']?['current_page'] ?? json['current_page'] ?? 1,
      lastPage: json['meta']?['last_page'] ?? json['last_page'] ?? 1,
      total: json['meta']?['total'] ?? json['total'] ?? 0,
      perPage: json['meta']?['per_page'] ?? json['per_page'] ?? 20,
    );
  }

  bool get hasMorePages => currentPage < lastPage;
}
