import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logOut),
        content: Text(l10n.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.logOut),
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
            SnackBar(content: Text(l10n.failedToLogout)),
          );
        }
      }
    }
  }

  Future<void> _switchTeam(Team team) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      // Call API to switch team
      final apiService = _authService.apiService;
      await apiService.put('/teams/switch/${team.id}');
      
      // Reload user data
      await _loadUser();
      
      if (mounted) {
        Navigator.pop(context); // Close drawer
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.switchedTo(team.name))),
        );
        // Refresh current page
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToSwitchTeam)),
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
    final l10n = AppLocalizations.of(context)!;

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
                    backgroundImage: _user?.profilePhotoUrl != null
                        ? NetworkImage(_user!.profilePhotoUrl!)
                        : null,
                    child: _user?.profilePhotoUrl == null
                        ? Text(
                            _user?.name.substring(0, 1).toUpperCase() ?? 'U',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          )
                        : null,
                  ),
                  accountName: Text(
                    _user?.name ?? l10n.guest,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.black : Colors.white,
                    ),
                  ),
                  accountEmail: Text(
                    _user?.email ?? '',
                    style: TextStyle(
                      color: isDark ? Colors.black : Colors.white,
                    ),
                  ),
                ),

                // Current Team
                if (_user?.currentTeam != null)
                  ListTile(
                    leading: const Icon(Icons.group),
                    title: Text(l10n.currentTeam),
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
                    l10n.manageAccount,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(l10n.profile),
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
                      l10n.manageTeam,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: Text(l10n.teamSettings),
                    onTap: () {
                      Navigator.pop(context);
                      context.pushNamed('team-settings', extra: _user!.currentTeam);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_add_outlined),
                    title: Text(l10n.inviteMember),
                    onTap: () {
                      Navigator.pop(context);
                      context.pushNamed('invite-member', extra: _user!.currentTeam);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.add_circle_outline),
                    title: Text(l10n.createNewTeam),
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
                        l10n.switchTeams,
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

                // Language Switcher
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(l10n.language),
                  subtitle: Text(
                     Localizations.localeOf(context).languageCode == 'en' 
                        ? l10n.english 
                        : l10n.indonesian
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => SimpleDialog(
                        title: Text(l10n.selectLanguage),
                        children: [
                          SimpleDialogOption(
                            onPressed: () {
                              ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                              Navigator.pop(context);
                              Navigator.pop(context); // Close drawer too
                            },
                            child: Row(
                              children: [
                                Radio<String>(
                                  value: 'en',
                                  groupValue: Localizations.localeOf(context).languageCode,
                                  onChanged: null,
                                ),
                                Text(l10n.english),
                              ],
                            ),
                          ),
                          SimpleDialogOption(
                            onPressed: () {
                              ref.read(localeProvider.notifier).setLocale(const Locale('id'));
                              Navigator.pop(context);
                              Navigator.pop(context); // Close drawer too
                            },
                            child: Row(
                              children: [
                                Radio<String>(
                                  value: 'id',
                                  groupValue: Localizations.localeOf(context).languageCode,
                                  onChanged: null,
                                ),
                                Text(l10n.indonesian),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const Divider(),

                // Theme Toggle
                ListTile(
                  leading: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                  title: Text(isDark ? l10n.lightMode : l10n.darkMode),
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
                    l10n.logOut,
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
