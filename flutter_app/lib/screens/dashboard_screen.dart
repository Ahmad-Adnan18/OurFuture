import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/dashboard.dart';
import '../services/dashboard_service.dart';
import '../widgets/goal_card.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/wallet_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _dashboardService = DashboardService();
  DashboardData? _data;
  bool _isLoading = true;
  String? _error;

  final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _dashboardService.getDashboard();
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load dashboard'; // Will be localized in build if possible, but state is string. 
          // Ideally store error type/code. For now keep simple.
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark 
          ? null 
          : const Color(0xFFF9FAFB), // Very light grey for light mode
      body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(l10n.failedToLoad, style: TextStyle(color: colorScheme.error)),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _loadDashboard,
                          child: Text(l10n.retry),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadDashboard,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome & Wallet Section
                          if (_data != null)
                            WalletCard(
                              totalAssets: _data!.totalAssets, 
                            ),
                          const SizedBox(height: 24),


                          // Unallocated Funds (Mini Card)
                          if (_data != null && _data!.unallocatedFunds > 0) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colorScheme.tertiaryContainer.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: colorScheme.tertiary.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.volunteer_activism, color: colorScheme.tertiary),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.unallocatedFunds,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: colorScheme.onTertiaryContainer,
                                          ),
                                        ),
                                        Text(
                                          _currencyFormat.format(_data!.unallocatedFunds),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.onTertiaryContainer,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // TODO: Navigate to allocation screen
                                    },
                                    child: Text(l10n.allocate),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],

                          // Active Goals Section
                          _buildSectionHeader(context, title: l10n.myGoals, onTapAll: () {}),
                          const SizedBox(height: 16),
                          if (_data != null && _data!.activeGoals.isEmpty)
                            _buildEmptyState(context, l10n.noActiveGoals, Icons.flag_outlined)
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _data!.activeGoals.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final goal = _data!.activeGoals[index];
                                return GoalCard(goal: goal);
                              },
                            ),
                          const SizedBox(height: 32),

                          // Recent Transactions Section
                          _buildSectionHeader(context, title: l10n.recentActivity, onTapAll: () {}),
                          const SizedBox(height: 16),
                          if (_data != null && _data!.recentTransactions.isEmpty)
                            _buildEmptyState(context, l10n.noTransactions, Icons.receipt_long_outlined)
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _data!.recentTransactions.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 0),
                              itemBuilder: (context, index) {
                                final transaction = _data!.recentTransactions[index];
                                return TransactionTile(transaction: transaction);
                              },
                            ),
                            
                          // Bottom padding for FAB
                          const SizedBox(height: 80), 
                        ],
                      ),
                    ),
                  ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required String title, required VoidCallback onTapAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, String message, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Theme.of(context).disabledColor),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: Theme.of(context).disabledColor),
          ),
        ],
      ),
    );
  }
}
