import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
      
      setState(() {
        _activeGoals = activeGoals;
        _archivedGoals = archivedGoals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load goals';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteGoal(Goal goal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text('Are you sure you want to delete "${goal.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
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
            const SnackBar(content: Text('Goal deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to delete goal'),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/goals/create').then((_) => _loadGoals()),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Archived'),
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
                      Text(_error!, style: TextStyle(color: colorScheme.error)),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _loadGoals,
                        child: const Text('Retry'),
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
                          ? _buildEmptyState('No active goals yet')
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
                          ? _buildEmptyState('No archived goals')
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
