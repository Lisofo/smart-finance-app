import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../presentation/providers/auth_provider.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/register_screen.dart';
import '../presentation/screens/expenses_list_screen.dart';
import '../presentation/screens/add_edit_expense_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect:(context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';
      final isRegisterRoute = state.matchedLocation == '/register';

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
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        name: 'register',
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        name: 'expenses',
        path: '/expenses',
        builder: (context, state) => const ExpensesListScreen(),
      ),
      GoRoute(
        name: 'addExpense',
        path: '/expenses/add',
        builder: (context, state) => const AddEditExpenseScreen(),
      ),
      GoRoute(
        name: 'editExpense',
        path: '/expenses/edit/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          final expense = state.extra as Map<String, dynamic>?;
          return AddEditExpenseScreen(
            expenseId: id,
            initialDescription: expense?['description'],
            initialAmount: expense?['amount'],
            initialCategory: expense?['category'],
            initialExpenseDate: expense?['expenseDate'],
          );
        },
      ),
    ],
  );
});