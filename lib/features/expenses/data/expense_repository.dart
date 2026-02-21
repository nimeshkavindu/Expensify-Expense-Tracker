import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../domain/expense.dart';

// 1. Riverpod Provider for easy access anywhere in the app
final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository();
});

// 2. The Repository logic
class ExpenseRepository {
  static const String boxName = 'expensesBox';

  // Initialize Hive and open the box (database)
  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ExpenseAdapter());
    await Hive.openBox<Expense>(boxName);
  }

  Box<Expense> get _box => Hive.box<Expense>(boxName);

  // Read all expenses
  List<Expense> getAllExpenses() {
    return _box.values.toList().cast<Expense>();
  }

  // Create or Update an expense
  Future<void> addExpense(Expense expense) async {
    await _box.put(expense.id, expense);
  }

  // Delete an expense
  Future<void> deleteExpense(String id) async {
    await _box.delete(id);
  }
}