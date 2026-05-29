import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/models/budget.dart';
import '../data/models/phase.dart';
import '../domain/blocs/auth/auth_bloc.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/budget/budget_form_screen.dart';
import '../presentation/screens/budget/budget_screen.dart';
import '../presentation/screens/dashboard/dashboard_screen.dart';
import '../presentation/screens/guest/guest_form_screen.dart';
import '../presentation/screens/guest/guest_screen.dart';
import '../presentation/screens/phase/phase_detail_screen.dart';
import '../presentation/screens/phase/phase_screen.dart';
import '../presentation/screens/rundown/rundown_form_screen.dart';
import '../presentation/screens/rundown/rundown_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';
import '../presentation/screens/task/task_form_screen.dart';
import '../presentation/screens/task/task_screen.dart';
import '../presentation/screens/vendor/vendor_form_screen.dart';
import '../presentation/screens/vendor/vendor_screen.dart';
import '../presentation/shell/app_shell.dart';

/// Application route paths.
class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String tasks = '/tasks';
  static const String taskAdd = '/tasks/add';
  static const String budget = '/budget';
  static const String budgetAdd = '/budget/add';
  static const String budgetEdit = '/budget/edit';
  static const String guests = '/guests';
  static const String guestAdd = '/guests/add';
  static const String phases = '/phases';
  static const String phaseDetail = '/phases/detail';
  static const String rundown = '/rundown';
  static const String rundownAdd = '/rundown/add';
  static const String vendors = '/vendors';
  static const String vendorAdd = '/vendors/add';
  static const String settings = '/settings';
}

/// Creates the GoRouter instance with auth-based redirect logic.
///
/// Uses [StatefulShellRoute] to preserve navigation state across tabs
/// (scroll position, content state) as required by Requirement 12.7.
///
/// Branches:
/// - 0: Dashboard
/// - 1: Tasks
/// - 2: Budget
/// - 3: Guests
/// - 4: Phases (More sub-screen)
/// - 5: Rundown (More sub-screen)
/// - 6: Vendors (More sub-screen)
/// - 7: Settings (More sub-screen)
GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    refreshListenable: _AuthRefreshListenable(authBloc),
    redirect: (BuildContext context, GoRouterState state) {
      final authStatus = authBloc.state.status;
      final isOnLoginPage = state.matchedLocation == AppRoutes.login;

      // If auth status is unknown (still checking), don't redirect yet
      if (authStatus == AuthStatus.unknown) {
        return null;
      }

      // If not authenticated, redirect to login (unless already there)
      if (authStatus == AuthStatus.unauthenticated) {
        return isOnLoginPage ? null : AppRoutes.login;
      }

      // If authenticated and on login page, redirect to dashboard
      if (isOnLoginPage) {
        return AppRoutes.dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      // StatefulShellRoute preserves state across all branches (tabs)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          // Branch 1: Tasks
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.tasks,
                builder: (context, state) => const TaskScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) {
                      final phases = state.extra as List<Phase>? ?? [];
                      return TaskFormScreen(phases: phases);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Branch 2: Budget
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.budget,
                builder: (context, state) => const BudgetScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const BudgetFormScreen(),
                  ),
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) {
                      final budget = state.extra as Budget?;
                      return BudgetFormScreen(budget: budget);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Branch 3: Guests
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.guests,
                builder: (context, state) => const GuestScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const GuestFormScreen(),
                  ),
                ],
              ),
            ],
          ),
          // Branch 4: Phases (More sub-screen)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.phases,
                builder: (context, state) => const PhaseScreen(),
                routes: [
                  GoRoute(
                    path: 'detail',
                    builder: (context, state) {
                      final phase = state.extra as Phase;
                      return PhaseDetailScreen(phase: phase);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Branch 5: Rundown (More sub-screen)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.rundown,
                builder: (context, state) => const RundownScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const RundownFormScreen(),
                  ),
                ],
              ),
            ],
          ),
          // Branch 6: Vendors (More sub-screen)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.vendors,
                builder: (context, state) => const VendorScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const VendorFormScreen(),
                  ),
                ],
              ),
            ],
          ),
          // Branch 7: Settings (More sub-screen)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// A [ChangeNotifier] that listens to [AuthBloc] state changes
/// and notifies GoRouter to re-evaluate its redirect logic.
class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(AuthBloc authBloc) {
    authBloc.stream.listen((_) => notifyListeners());
  }
}
