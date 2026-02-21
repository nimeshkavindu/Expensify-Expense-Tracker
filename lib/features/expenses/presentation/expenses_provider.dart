import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/expense_repository.dart';
import '../domain/expense.dart';

class ExpensesNotifier extends Notifier<List<Expense>> {
  @override
  List<Expense> build() {
    // Load initial data from Hive when the app starts
    return ref.read(expenseRepositoryProvider).getAllExpenses();
  }

  // Refresh the state after modifying the database
  void refresh() {
    state = ref.read(expenseRepositoryProvider).getAllExpenses();
  }

  // Add an expense and update UI
  Future<void> addExpense(Expense expense) async {
    await ref.read(expenseRepositoryProvider).addExpense(expense);
    refresh();
  }

  // Delete an expense and update UI
  Future<void> deleteExpense(String id) async {
    await ref.read(expenseRepositoryProvider).deleteExpense(id);
    refresh();
  }
}

// The global provider we will watch in our UI
final expensesProvider = NotifierProvider<ExpensesNotifier, List<Expense>>(() {
  return ExpensesNotifier();
});