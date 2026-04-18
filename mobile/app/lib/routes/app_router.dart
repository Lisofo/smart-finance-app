import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/providers/auth_provider.dart';
import '../presentation/screens/add_edit_expense_screen.dart';
import '../presentation/screens/expenses_list_screen.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/register_screen.dart';

/// Notifies [GoRouter] when auth state changes without recreating the router.
class GoRouterRefresh extends ChangeNotifier {
  void refresh() => notifyListeners();
}

final routerRefreshProvider = Provider<GoRouterRefresh>((ref) {
  final notifier = GoRouterRefresh();
  ref.onDispose(notifier.dispose);
  ref.listen<AuthState>(authProvider, (_, __) => notifier.refresh());
  return notifier;
});

CustomTransitionPage<void> _fadeSlidePage({
  required LocalKey pageKey,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: pageKey,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

CustomTransitionPage<void> _fadePage({
  required LocalKey pageKey,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: pageKey,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    child: child,
    transitionsBuilder: (context, animation, _, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ),
        child: child,
      );
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(routerRefreshProvider);

  return GoRouter(
    refreshListenable: refresh,
    initialLocation: '/login',
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final isAuthenticated = auth.isAuthenticated;
      final loc = state.matchedLocation;
      final isLoginRoute = loc == '/login';
      final isRegisterRoute = loc == '/register';

      if (!isAuthenticated && !isLoginRoute && !isRegisterRoute) {
        return '/login';
      }
      if (isAuthenticated && (isLoginRoute || isRegisterRoute)) {
        return '/expenses';
      }
      return null;
    },
    routes: [
      GoRoute(
        name: 'login',
        path: '/login',
        pageBuilder: (context, state) => _fadePage(
          pageKey: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        name: 'register',
        path: '/register',
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        name: 'expenses',
        path: '/expenses',
        pageBuilder: (context, state) => _fadePage(
          pageKey: state.pageKey,
          child: const ExpensesListScreen(),
        ),
      ),
      GoRoute(
        name: 'addExpense',
        path: '/expenses/add',
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const AddEditExpenseScreen(),
        ),
      ),
      GoRoute(
        name: 'editExpense',
        path: '/expenses/edit/:id',
        pageBuilder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          final expense = state.extra as Map<String, dynamic>?;
          return _fadeSlidePage(
            pageKey: state.pageKey,
            child: AddEditExpenseScreen(
              expenseId: id,
              initialDescription: expense?['description'] as String?,
              initialAmount: expense?['amount'] as double?,
              initialCategory: expense?['category'] as String?,
              initialExpenseDate: expense?['expenseDate'] as DateTime?,
            ),
          );
        },
      ),
    ],
  );
});
