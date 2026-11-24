import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/domain/auth_state.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/ai_generator/presentation/screens/ai_studio_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/resume/presentation/screens/resume_overview_screen.dart';
import '../../features/resume/presentation/screens/resume_upload_screen.dart';
import '../../features/tracker/presentation/screens/tracker_screen.dart';
import '../../shared/scaffold/app_scaffold.dart';
import 'route_names.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _dashboardNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'dashboard');
final _trackerNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'tracker');
final _generatorNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'generator');
final _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authControllerProvider,
      (_, __) => notifyListeners(),
    );
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authControllerProvider);

    // Allow splash/loading to settle
    if (authState.status == AuthStatus.initial || authState.status == AuthStatus.loading) {
      return null;
    }

    final isAuthRoute = state.matchedLocation == RouteNames.login ||
        state.matchedLocation == RouteNames.register ||
        state.matchedLocation == RouteNames.forgotPassword;

    if (!authState.isAuthenticated) {
      return isAuthRoute ? null : RouteNames.login;
    }

    if (isAuthRoute) {
      return RouteNames.dashboard;
    }

    return null;
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouteNames.dashboard,
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      // Authentication Routes
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Resume Subroutes (Standalone over shell)
      GoRoute(
        path: RouteNames.resumeUpload,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ResumeUploadScreen(),
      ),
      GoRoute(
        path: RouteNames.resumeAudit,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ResumeOverviewScreen(),
      ),

      // 4-Tab Main Navigation Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Tab 0: Dashboard
          StatefulShellBranch(
            navigatorKey: _dashboardNavigatorKey,
            routes: [
              GoRoute(
                path: RouteNames.dashboard,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),

          // Tab 1: Application CRM Pipeline
          StatefulShellBranch(
            navigatorKey: _trackerNavigatorKey,
            routes: [
              GoRoute(
                path: RouteNames.tracker,
                builder: (context, state) => const TrackerScreen(),
              ),
            ],
          ),

          // Tab 2: AI Generation Suite
          StatefulShellBranch(
            navigatorKey: _generatorNavigatorKey,
            routes: [
              GoRoute(
                path: RouteNames.generator,
                builder: (context, state) => const AiStudioScreen(),
              ),
            ],
          ),

          // Tab 3: Candidate Profile & Settings
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: RouteNames.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
