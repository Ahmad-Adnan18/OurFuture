import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models/goal.dart';
import '../../services/goal_service.dart';

class GoalFormScreen extends StatefulWidget {
  final int? goalId;

  const GoalFormScreen({super.key, this.goalId});

  @override
  State<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends State<GoalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _goalService = GoalService();

  DateTime _startDate = DateTime.now();
  DateTime? _estimatedDate;
  String _status = 'active';
  
  bool _isLoading = false;
  bool _isLoadingData = false;
  Goal? _existingGoal;

  bool get _isEditing => widget.goalId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadGoal();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadGoal() async {
    setState(() => _isLoadingData = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      final goal = await _goalService.getGoal(widget.goalId!);
      setState(() {
        _existingGoal = goal;
        _titleController.text = goal.title;
        _targetAmountController.text = goal.targetAmount.toStringAsFixed(0);
        _status = goal.status;
        if (goal.startDate != null) {
          _startDate = DateTime.parse(goal.startDate!);
        }
        if (goal.estimatedDate != null) {
          _estimatedDate = DateTime.parse(goal.estimatedDate!);
        }
        _isLoadingData = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToLoadGoal)),
        );
        context.pop();
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);

    try {
      final targetAmount = double.parse(_targetAmountController.text.replaceAll(',', ''));

      if (_isEditing) {
        await _goalService.updateGoal(
          widget.goalId!,
          title: _titleController.text,
          targetAmount: targetAmount,
          estimatedDate: _estimatedDate?.toIso8601String().split('T').first,
          status: _status,
        );
      } else {
        await _goalService.createGoal(
          title: _titleController.text,
          targetAmount: targetAmount,
          startDate: _startDate.toIso8601String().split('T').first,
          estimatedDate: _estimatedDate?.toIso8601String().split('T').first,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? l10n.goalUpdated : l10n.goalCreated)),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? l10n.failedToUpdateGoal : l10n.failedToCreateGoal),
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

  Future<void> _selectDate(bool isStart) async {
    final initialDate = isStart ? _startDate : (_estimatedDate ?? DateTime.now());
    final firstDate = isStart ? DateTime(2020) : _startDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _estimatedDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editGoal : l10n.newGoal),
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
                    // Title Field
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: l10n.goalTitle,
                        hintText: l10n.goalTitleHint,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.flag_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.enterGoalTitle;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Target Amount Field
                    TextFormField(
                      controller: _targetAmountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.targetAmountLabel,
                        hintText: l10n.amountHint,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.attach_money),
                        prefixText: 'Rp ',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.enterTargetAmount;
                        }
                        final amount = double.tryParse(value.replaceAll(',', ''));
                        if (amount == null || amount <= 0) {
                          return l10n.enterValidAmount;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Start Date (only for new goals)
                    if (!_isEditing)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today),
                        title: Text(l10n.startDate),
                        subtitle: Text(dateFormat.format(_startDate)),
                        onTap: () => _selectDate(true),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                    if (!_isEditing) const SizedBox(height: 16),

                    // Estimated Date
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.event),
                      title: Text(l10n.targetDateOptional),
                      subtitle: Text(
                        _estimatedDate != null
                            ? dateFormat.format(_estimatedDate!)
                            : l10n.notSet,
                      ),
                      trailing: _estimatedDate != null
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() => _estimatedDate = null);
                              },
                            )
                          : null,
                      onTap: () => _selectDate(false),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Status (only for editing)
                    if (_isEditing) ...[
                      DropdownButtonFormField<String>(
                        value: _status,
                        decoration: InputDecoration(
                          labelText: l10n.status,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.check_circle_outline),
                        ),
                        items: [
                           DropdownMenuItem(value: 'active', child: Text(l10n.active)),
                           DropdownMenuItem(value: 'completed', child: Text(l10n.completed)),
                           DropdownMenuItem(value: 'archived', child: Text(l10n.archived)),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _status = value);
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Submit Button
                    FilledButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                          : Text(_isEditing ? l10n.updateGoal : l10n.createGoal),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
