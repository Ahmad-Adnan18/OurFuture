import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
      
      setState(() {
        _wallets = wallets;
        _goals = goals;
        _isLoadingData = false;
        if (wallets.isNotEmpty) {
          _selectedWalletId = wallets.first.id;
        }
      });
    } catch (e) {
      setState(() => _isLoadingData = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load data')),
        );
      }
    }
  }

  bool get _requiresGoal => 
      _selectedType == 'expense' || _selectedType == 'withdrawal';

  bool get _showGoalField => _selectedType != 'adjustment';

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedWalletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a wallet')),
      );
      return;
    }

    if (_requiresGoal && _selectedGoalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a goal')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text.replaceAll(',', ''));

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
          const SnackBar(content: Text('Transaction created')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to create transaction'),
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
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Transaction'),
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
                      'Type',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: [
                        ButtonSegment(
                          value: 'deposit',
                          label: const Text('Deposit'),
                          icon: Icon(
                            Icons.arrow_upward,
                            color: _selectedType == 'deposit' 
                                ? Colors.white 
                                : Colors.green,
                          ),
                        ),
                        ButtonSegment(
                          value: 'expense',
                          label: const Text('Expense'),
                          icon: Icon(
                            Icons.arrow_downward,
                            color: _selectedType == 'expense' 
                                ? Colors.white 
                                : Colors.red,
                          ),
                        ),
                        ButtonSegment(
                          value: 'withdrawal',
                          label: const Text('Withdraw'),
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
                    // Adjustment option as separate button
                    OutlinedButton.icon(
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
                      label: const Text('Adjustment'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _selectedType == 'adjustment'
                            ? colorScheme.primaryContainer
                            : null,
                      ),
                    ),
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
                        labelText: 'Amount',
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
                          return 'Please enter amount';
                        }
                        final amount = double.tryParse(value.replaceAll(',', ''));
                        if (amount == null || amount <= 0) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Wallet Selector
                    DropdownButtonFormField<int>(
                      value: _selectedWalletId,
                      decoration: const InputDecoration(
                        labelText: 'Wallet',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.account_balance_wallet),
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
                          return 'Please select a wallet';
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
                          labelText: _requiresGoal ? 'Goal (Required)' : 'Goal (Optional)',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.flag),
                        ),
                        items: [
                          if (!_requiresGoal)
                            const DropdownMenuItem(
                              value: null,
                              child: Text('No goal (Unallocated)'),
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
                            return 'Please select a goal';
                          }
                          return null;
                        },
                      ),
                    if (_showGoalField) const SizedBox(height: 16),

                    // Date Selector
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Date'),
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
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        hintText: 'Add description...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.notes),
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
                              _getButtonText(),
                              style: const TextStyle(color: Colors.white),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _getButtonText() {
    switch (_selectedType) {
      case 'deposit':
        return 'Add Deposit';
      case 'expense':
        return 'Record Expense';
      case 'withdrawal':
        return 'Record Withdrawal';
      case 'adjustment':
        return 'Make Adjustment';
      default:
        return 'Save';
    }
  }
}
