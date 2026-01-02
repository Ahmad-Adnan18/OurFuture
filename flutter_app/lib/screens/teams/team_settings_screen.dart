import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/team_service.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';

class TeamSettingsScreen extends StatefulWidget {
  final Team team;

  const TeamSettingsScreen({super.key, required this.team});

  @override
  State<TeamSettingsScreen> createState() => _TeamSettingsScreenState();
}

class _TeamSettingsScreenState extends State<TeamSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  final _teamService = TeamService();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.team.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // ... existing submit code ... (this replacement is just context, not actual replacement of submit)
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _teamService.updateTeam(widget.team.id, _nameController.text);
      // Refresh user data
      await _authService.getCurrentUser();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Team updated successfully')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update team: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteTeam() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Team'),
        content: const Text(
          'Are you sure you want to delete this team? Once a team is deleted, all of its resources and data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      await _teamService.deleteTeam(widget.team.id);
      // Refresh user data to update the team list and current team
      await _authService.getCurrentUser();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Team deleted successfully')),
        );
        // Go back to previous screen (likely home or team list)
        context.pop(); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete team: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Update Team Name',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Team Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.group),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a team name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Changes'),
              ),
              const SizedBox(height: 32),
              Text(
                'Team Members',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (widget.team.users == null || widget.team.users!.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'No other members in this team.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.team.users!.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final member = widget.team.users![index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: member.profilePhotoUrl != null
                            ? NetworkImage(member.profilePhotoUrl!)
                            : null,
                        child: member.profilePhotoUrl == null
                            ? Text(member.name.substring(0, 1).toUpperCase())
                            : null,
                      ),
                      title: Text(member.name),
                      subtitle: Text(member.email),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () {
                           ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Remove member coming soon!')),
                          );
                        },
                      ),
                    );
                  },
                ),
              const SizedBox(height: 32),
              if (!widget.team.personalTeam) ...[
                Text(
                  'Delete Team',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.red,
                      ),
                ),
                const SizedBox(height: 8),
                Card(
                  color: Colors.red.shade50,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.red.shade100),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Permanently delete this team.',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: Colors.red.shade900,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Once a team is deleted, all of its resources and data will be permanently deleted.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.red.shade700,
                              ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _isLoading ? null : _deleteTeam,
                          icon: const Icon(Icons.delete_forever),
                          label: const Text('Delete Team'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
