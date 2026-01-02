import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../providers/theme_provider.dart';

class AppDrawer extends ConsumerStatefulWidget {
  const AppDrawer({super.key});

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
  final _authService = AuthService();
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await _authService.getCurrentUser();
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _authService.logout();
        if (mounted) {
          context.go('/login');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to logout')),
          );
        }
      }
    }
  }

  Future<void> _switchTeam(Team team) async {
    try {
      // Call API to switch team
      final apiService = _authService.apiService;
      await apiService.put('/teams/switch/${team.id}');
      
      // Reload user data
      await _loadUser();
      
      if (mounted) {
        Navigator.pop(context); // Close drawer
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Switched to ${team.name}')),
        );
        // Refresh current page
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to switch team')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark || 
                   (themeMode == ThemeMode.system && MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return Drawer(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                // User Header
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      _user?.name.substring(0, 1).toUpperCase() ?? 'U',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  accountName: Text(
                    _user?.name ?? 'User',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  accountEmail: Text(_user?.email ?? ''),
                ),

                // Current Team
                if (_user?.currentTeam != null)
                  ListTile(
                    leading: const Icon(Icons.group),
                    title: const Text('Current Team'),
                    subtitle: Text(
                      _user!.currentTeam!.name,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                const Divider(),

                // Manage Account Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'MANAGE ACCOUNT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Profile'),
                  onTap: () {
                    Navigator.pop(context);
                    context.pushNamed('profile', extra: _user);
                  },
                ),

                const Divider(),

                // Manage Team Section
                if (_user?.currentTeam != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'MANAGE TEAM',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text('Team Settings'),
                    onTap: () {
                      Navigator.pop(context);
                      context.pushNamed('team-settings', extra: _user!.currentTeam);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_add_outlined),
                    title: const Text('Invite Member'),
                    onTap: () {
                      Navigator.pop(context);
                      context.pushNamed('invite-member', extra: _user!.currentTeam);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.add_circle_outline),
                    title: const Text('Create New Team'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/create-team');
                    },
                  ),

                  // Team Switcher
                  if (_user!.allTeams != null && _user!.allTeams!.length > 1) ...[
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'SWITCH TEAMS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    ..._user!.allTeams!.map((team) => ListTile(
                      leading: team.id == _user!.currentTeam?.id
                          ? Icon(Icons.check_circle, color: colorScheme.primary)
                          : const Icon(Icons.circle_outlined),
                      title: Text(team.name),
                      selected: team.id == _user!.currentTeam?.id,
                      onTap: team.id == _user!.currentTeam?.id
                          ? null
                          : () => _switchTeam(team),
                    )),
                  ],

                  const Divider(),
                ],

                // Theme Toggle
                ListTile(
                  leading: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                  title: Text(isDark ? 'Light Mode' : 'Dark Mode'),
                  onTap: () {
                    ref.read(themeProvider.notifier).toggleTheme();
                    Navigator.pop(context);
                  },
                ),

                const Divider(),

                // Logout
                ListTile(
                  leading: Icon(Icons.logout, color: colorScheme.error),
                  title: Text(
                    'Log Out',
                    style: TextStyle(color: colorScheme.error),
                  ),
                  onTap: _handleLogout,
                ),

                const SizedBox(height: 16),

                // App Version
                Center(
                  child: Text(
                    'OurFuture v1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
    );
  }
}
