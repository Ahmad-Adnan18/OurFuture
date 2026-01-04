import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/transaction.dart';
import '../../services/transaction_service.dart';
import '../../services/api_service.dart';
import '../../widgets/transaction_tile.dart';
import '../../config/api_config.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _transactionService = TransactionService();
  final _scrollController = ScrollController();
  
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isExporting = false;
  String? _error;
  String? _selectedType;
  int _currentPage = 1;
  bool _hasMorePages = false;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreTransactions();
    }
  }

  Future<void> _loadTransactions({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
    }
    // Don't access AppLocalizations here as it might be called from initState
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _transactionService.getTransactions(
        page: _currentPage,
        type: _selectedType,
      );
      
      if (mounted) {
        setState(() {
          _transactions = response.data;
          _hasMorePages = response.hasMorePages;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _error = l10n.failedToLoadTransactions;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreTransactions() async {
    if (_isLoadingMore || !_hasMorePages) return;

    setState(() => _isLoadingMore = true);

    try {
      final response = await _transactionService.getTransactions(
        page: _currentPage + 1,
        type: _selectedType,
      );
      
      setState(() {
        _currentPage++;
        _transactions.addAll(response.data);
        _hasMorePages = response.hasMorePages;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _deleteTransaction(Transaction transaction) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTransaction),
        content: Text(l10n.deleteTransactionConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _transactionService.deleteTransaction(transaction.id);
        _loadTransactions(refresh: true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.transactionDeleted)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.failedToDeleteTransaction),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _showExportDialog() async {
    final l10n = AppLocalizations.of(context)!;
    DateTime? startDate;
    DateTime? endDate;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.exportTransactions),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(l10n.startDate),
                subtitle: Text(startDate?.toString().split(' ')[0] ?? l10n.optional),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: startDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setDialogState(() => startDate = picked);
                  }
                },
              ),
              ListTile(
                title: Text(l10n.endDate),
                subtitle: Text(endDate?.toString().split(' ')[0] ?? l10n.optional),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: endDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setDialogState(() => endDate = picked);
                  }
                },
              ),
              const SizedBox(height: 8),
              Text(
                l10n.leaveEmptyForAll,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                await _exportTransactions(startDate, endDate);
              },
              child: Text(l10n.downloadCsv),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportTransactions(DateTime? startDate, DateTime? endDate) async {
    if (_isExporting) return;
    
    setState(() => _isExporting = true);
    
    final l10n = AppLocalizations.of(context)!;

    try {
      final params = <String, String>{};
      if (startDate != null) {
        params['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        params['end_date'] = endDate.toIso8601String().split('T')[0];
      }

      final queryString = params.entries.map((e) => '${e.key}=${e.value}').join('&');
      final url = '/transactions/export${queryString.isNotEmpty ? '?$queryString' : ''}';

      // Download PDF using API service
      final response = await ApiService().dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      // Save to temp directory first
      final directory = await getApplicationDocumentsDirectory();
      final filename = 'OurFuture_Transactions_${DateTime.now().toString().split(' ')[0]}.pdf';
      final filePath = '${directory.path}/$filename';

      // Save file
      final file = File(filePath);
      await file.writeAsBytes(response.data);

      if (mounted) {
        setState(() => _isExporting = false);
        
        if (Platform.isAndroid || Platform.isIOS) {
          // Mobile: Share the file
          await Share.shareXFiles(
            [XFile(filePath)],
            subject: 'OurFuture Transaction Report',
          );
        } else {
          // Desktop: Show success message with path
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ PDF saved: $filePath'),
              duration: const Duration(seconds: 10),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isExporting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.exportFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transactions),
        actions: [
          _isExporting
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.file_download_outlined),
                  tooltip: l10n.export,
                  onPressed: _showExportDialog,
                ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/transactions/create')
                .then((_) => _loadTransactions(refresh: true)),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip(null, l10n.all),
                const SizedBox(width: 8),
                _buildFilterChip('deposit', l10n.deposit),
                const SizedBox(width: 8),
                _buildFilterChip('expense', l10n.expense),
                const SizedBox(width: 8),
                _buildFilterChip('withdrawal', l10n.withdrawal),
                const SizedBox(width: 8),
                _buildFilterChip('adjustment', l10n.adjustment),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: TextStyle(color: colorScheme.error)),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => _loadTransactions(refresh: true),
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => _loadTransactions(refresh: true),
                  child: _transactions.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.receipt_long_outlined,
                                      size: 64,
                                      color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      l10n.noTransactionsYet,
                                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _transactions.length + (_hasMorePages ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _transactions.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final transaction = _transactions[index];
                            return Dismissible(
                              key: Key('transaction_${transaction.id}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 16),
                                color: colorScheme.error,
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              confirmDismiss: (_) async {
                                await _deleteTransaction(transaction);
                                return false; // We handle deletion manually
                              },
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: TransactionTile(transaction: transaction),
                              ),
                            );
                          },
                        ),
                ),
    );
  }

  Widget _buildFilterChip(String? type, String label) {
    final isSelected = _selectedType == type;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedType = selected ? type : null;
        });
        _loadTransactions(refresh: true);
      },
    );
  }
}
