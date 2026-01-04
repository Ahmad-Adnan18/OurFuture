import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models/goal.dart';
import '../../models/storage_account.dart';
import '../../services/goal_service.dart';
import '../../services/wallet_service.dart';
import '../../services/transaction_service.dart';

class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({super.key});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  final _goalService = GoalService();
  final _walletService = WalletService();
  final _transactionService = TransactionService();

  List<StorageAccount> _wallets = [];
  List<Goal> _goals = [];
  
  String _selectedType = 'deposit';
  int? _selectedWalletId;
  int? _selectedGoalId;
  DateTime _selectedDate = DateTime.now();
  bool _isSubtractAdjustment = false; // For adjustment direction
  
  bool _isLoading = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final wallets = await _walletService.getWallets();
      final goals = await _goalService.getGoals();
      
      if (mounted) {
        setState(() {
          _wallets = wallets;
          _goals = goals;
          _isLoadingData = false;
          if (wallets.isNotEmpty) {
            _selectedWalletId = wallets.first.id;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() => _isLoadingData = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToLoad)),
        );
      }
    }
  }

  // Withdrawal and allocate require goal, expense is optional
  bool get _requiresGoal => _selectedType == 'withdrawal' || _selectedType == 'allocate';

  bool get _showGoalField => _selectedType != 'adjustment';

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;

    if (_selectedWalletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectWallet)),
      );
      return;
    }

    if (_requiresGoal && _selectedGoalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectGoal)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      double amount = double.parse(_amountController.text.replaceAll(',', ''));
      
      // For adjustment with subtract, send negative amount
      if (_selectedType == 'adjustment' && _isSubtractAdjustment) {
        amount = -amount;
      }

      await _transactionService.createTransaction(
        date: _selectedDate.toIso8601String().split('T').first,
        type: _selectedType,
        storageAccountId: _selectedWalletId!,
        amount: amount,
        goalId: _showGoalField ? _selectedGoalId : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.transactionCreated)),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToCreateTransaction),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newTransaction),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Transaction Type Selector
                    Text(
                      l10n.type,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: [
                        ButtonSegment(
                          value: 'deposit',
                          label: Text(l10n.deposit),
                          icon: Icon(
                            Icons.arrow_upward,
                            color: _selectedType == 'deposit' 
                                ? Colors.white 
                                : Colors.green,
                          ),
                        ),
                        ButtonSegment(
                          value: 'expense',
                          label: Text(l10n.expense),
                          icon: Icon(
                            Icons.arrow_downward,
                            color: _selectedType == 'expense' 
                                ? Colors.white 
                                : Colors.red,
                          ),
                        ),
                        ButtonSegment(
                          value: 'withdrawal',
                          label: Text(l10n.withdraw),
                          icon: Icon(
                            Icons.undo,
                            color: _selectedType == 'withdrawal' 
                                ? Colors.white 
                                : Colors.orange,
                          ),
                        ),
                      ],
                      selected: {_selectedType},
                      onSelectionChanged: (selection) {
                        setState(() {
                          _selectedType = selection.first;
                          // Clear goal if switching to adjustment
                          if (_selectedType == 'adjustment') {
                            _selectedGoalId = null;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    // Allocate and Adjustment options as separate buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedType = 'allocate';
                              });
                            },
                            icon: Icon(
                              Icons.push_pin,
                              color: _selectedType == 'allocate' 
                                  ? Colors.purple 
                                  : colorScheme.onSurfaceVariant,
                            ),
                            label: Text(l10n.allocate),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: _selectedType == 'allocate'
                                  ? Colors.purple.shade50
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedType = 'adjustment';
                                _selectedGoalId = null;
                              });
                            },
                            icon: Icon(
                              Icons.tune,
                              color: _selectedType == 'adjustment' 
                                  ? colorScheme.primary 
                                  : colorScheme.onSurfaceVariant,
                            ),
                            label: Text(l10n.adjustment),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: _selectedType == 'adjustment'
                                  ? colorScheme.primaryContainer
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Type Description Helper
                    const SizedBox(height: 8),
                    Text(
                      _selectedType == 'deposit' ? '💰 ${l10n.depositDescription}' :
                      _selectedType == 'expense' ? '🛒 ${l10n.expenseDescription}' :
                      _selectedType == 'withdrawal' ? '↩️ ${l10n.withdrawalDescription}' :
                      _selectedType == 'allocate' ? '📌 ${l10n.allocateDescription}' :
                      '⚖️ ${l10n.adjustmentDescription}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    
                    // Adjustment Direction Toggle
                    if (_selectedType == 'adjustment') ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add, size: 18),
                                  const SizedBox(width: 4),
                                  Text(l10n.addBalance),
                                ],
                              ),
                              selected: !_isSubtractAdjustment,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _isSubtractAdjustment = false);
                                }
                              },
                              selectedColor: Colors.green.shade100,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.remove, size: 18),
                                  const SizedBox(width: 4),
                                  Text(l10n.subtractBalance),
                                ],
                              ),
                              selected: _isSubtractAdjustment,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _isSubtractAdjustment = true);
                                }
                              },
                              selectedColor: Colors.red.shade100,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Amount Field
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        labelText: l10n.amount,
                        prefixText: 'Rp ',
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.attach_money,
                          color: _selectedType == 'deposit' || _selectedType == 'adjustment'
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.enterAmount;
                        }
                        final amount = double.tryParse(value.replaceAll(',', ''));
                        if (amount == null || amount <= 0) {
                          return l10n.enterValidAmount;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Wallet Selector
                    DropdownButtonFormField<int>(
                      value: _selectedWalletId,
                      decoration: InputDecoration(
                        labelText: l10n.wallet,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.account_balance_wallet),
                      ),
                      items: _wallets.map((wallet) {
                        return DropdownMenuItem(
                          value: wallet.id,
                          child: Text('${wallet.typeIcon} ${wallet.name}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedWalletId = value);
                      },
                      validator: (value) {
                        if (value == null) {
                          return l10n.selectWallet;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Goal Selector (conditional)
                    if (_showGoalField)
                      DropdownButtonFormField<int?>(
                        value: _selectedGoalId,
                        decoration: InputDecoration(
                          labelText: _requiresGoal ? l10n.goalRequired : l10n.goalOptional,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.flag),
                        ),
                        items: [
                          if (!_requiresGoal)
                             DropdownMenuItem(
                              value: null,
                              child: Text(l10n.noGoalUnallocated),
                            ),
                          ..._goals.map((goal) {
                            return DropdownMenuItem(
                              value: goal.id,
                              child: Text(goal.title),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedGoalId = value);
                        },
                        validator: (value) {
                          if (_requiresGoal && value == null) {
                            return l10n.selectGoal;
                          }
                          return null;
                        },
                      ),
                    if (_showGoalField) const SizedBox(height: 16),

                    // Date Selector
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: Text(l10n.date),
                      subtitle: Text(dateFormat.format(_selectedDate)),
                      onTap: _selectDate,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: colorScheme.outline),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Notes Field
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: l10n.notesOptional,
                        hintText: l10n.notesHint,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.notes),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    FilledButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: _selectedType == 'deposit' || _selectedType == 'adjustment'
                            ? Colors.green.shade600
                            : colorScheme.error,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _getButtonText(l10n),
                              style: const TextStyle(color: Colors.white),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _getButtonText(AppLocalizations l10n) {
    switch (_selectedType) {
      case 'deposit':
        return l10n.addDeposit;
      case 'expense':
        return l10n.recordExpense;
      case 'withdrawal':
        return l10n.recordWithdrawal;
      case 'adjustment':
        return l10n.makeAdjustment;
      default:
        return l10n.save;
    }
  }
}
