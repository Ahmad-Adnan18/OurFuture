import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/goals/goals_screen.dart';
import 'screens/goals/goal_form_screen.dart';
import 'screens/wallets/wallets_screen.dart';
import 'screens/transactions/transactions_screen.dart';
import 'screens/transactions/transaction_form_screen.dart';
import 'screens/teams/create_team_screen.dart';
import 'screens/teams/team_settings_screen.dart';
import 'screens/teams/invite_member_screen.dart';
import 'screens/profile_screen.dart';
import 'models/user.dart';
import 'services/auth_service.dart';
import 'widgets/app_drawer.dart';

import 'providers/theme_provider.dart';

void main() {
  runApp(const ProviderScope(child: OurFutureApp()));
}

class OurFutureApp extends ConsumerWidget {
  const OurFutureApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'OurFuture',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF059669), // emerald-600
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF059669), // emerald-600
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) async {
    final authService = AuthService();
    final isAuthenticated = await authService.isAuthenticated();
    final isAuthRoute = state.matchedLocation == '/login' || 
                        state.matchedLocation == '/register';

    if (!isAuthenticated && !isAuthRoute) {
      return '/login';
    }

    if (isAuthenticated && isAuthRoute) {
      return '/dashboard';
    }

    return null;
  },
  routes: [
    // Team Routes
    GoRoute(
      path: '/create-team',
      name: 'create-team',
      builder: (context, state) => const CreateTeamScreen(),
    ),
    GoRoute(
      path: '/team-settings',
      name: 'team-settings',
      builder: (context, state) {
        final team = state.extra as Team;
        return TeamSettingsScreen(team: team);
      },
    ),
    GoRoute(
      path: '/invite-member',
      name: 'invite-member',
      builder: (context, state) {
        final team = state.extra as Team;
        return InviteMemberScreen(team: team);
      },
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) {
        final user = state.extra as User;
        return ProfileScreen(user: user);
      },
    ),

    // Auth routes
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
    
    // Main app routes (with shell for bottom navigation)
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/goals',
          name: 'goals',
          builder: (context, state) => const GoalsScreen(),
          routes: [
            GoRoute(
              path: 'create',
              name: 'goal-create',
              builder: (context, state) => const GoalFormScreen(),
            ),
            GoRoute(
              path: ':id/edit',
              name: 'goal-edit',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return GoalFormScreen(goalId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/wallets',
          name: 'wallets',
          builder: (context, state) => const WalletsScreen(),
        ),
        GoRoute(
          path: '/transactions',
          name: 'transactions',
          builder: (context, state) => const TransactionsScreen(),
          routes: [
            GoRoute(
              path: 'create',
              name: 'transaction-create',
              builder: (context, state) => const TransactionFormScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

/// Main Shell with Bottom Navigation
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 32),
            const SizedBox(width: 8),
            const Text('OurFuture'),
          ],
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: const AppDrawer(),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag),
            label: 'Goals',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Wallets',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'History',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/transactions/create'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/goals')) return 1;
    if (location.startsWith('/wallets')) return 2;
    if (location.startsWith('/transactions')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/goals');
        break;
      case 2:
        context.go('/wallets');
        break;
      case 3:
        context.go('/transactions');
        break;
    }
  }
}
