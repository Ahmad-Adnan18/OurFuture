import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models/goal.dart';
import '../../services/goal_service.dart';
import '../../widgets/goal_card.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> with SingleTickerProviderStateMixin {
  final _goalService = GoalService();
  late TabController _tabController;
  
  List<Goal> _activeGoals = [];
  List<Goal> _archivedGoals = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadGoals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadGoals() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final activeGoals = await _goalService.getGoals(status: 'active');
      final archivedGoals = await _goalService.getGoals(status: 'archived');
      
      if (mounted) {
        setState(() {
          _activeGoals = activeGoals;
          _archivedGoals = archivedGoals;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _error = l10n.failedToLoadGoals;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteGoal(Goal goal) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteGoal),
        content: Text(l10n.deleteGoalConfirmation(goal.title)),
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
        await _goalService.deleteGoal(goal.id);
        _loadGoals();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.goalDeleted)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.failedToDeleteGoal),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.goals),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/goals/create').then((_) => _loadGoals()),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.active),
            Tab(text: l10n.archived),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.failedToLoadGoals, style: TextStyle(color: colorScheme.error)),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _loadGoals,
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // Active Goals Tab
                    RefreshIndicator(
                      onRefresh: _loadGoals,
                      child: _activeGoals.isEmpty
                          ? _buildEmptyState(l10n.noActiveGoalsYet)
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _activeGoals.length,
                              itemBuilder: (context, index) {
                                final goal = _activeGoals[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: GoalCard(
                                    goal: goal,
                                    onTap: () => context.push('/goals/${goal.id}/edit')
                                        .then((_) => _loadGoals()),
                                    onDelete: () => _deleteGoal(goal),
                                  ),
                                );
                              },
                            ),
                    ),
                    // Archived Goals Tab
                    RefreshIndicator(
                      onRefresh: _loadGoals,
                      child: _archivedGoals.isEmpty
                          ? _buildEmptyState(l10n.noArchivedGoals)
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _archivedGoals.length,
                              itemBuilder: (context, index) {
                                final goal = _archivedGoals[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: GoalCard(
                                    goal: goal,
                                    onTap: () => context.push('/goals/${goal.id}/edit')
                                        .then((_) => _loadGoals()),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmptyState(String message) {
    return ListView(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.flag_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
