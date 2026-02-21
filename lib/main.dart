import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/expenses/presentation/main_screen.dart';
import 'core/theme/app_theme.dart';
import 'features/expenses/data/expense_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the local Hive database
  final repository = ExpenseRepository();
  await repository.init();

  // Wrap the app in ProviderScope for Riverpod
  runApp(const ProviderScope(child: ExpensifyApp()));
}

class ExpensifyApp extends StatelessWidget {
  const ExpensifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expensify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainScreen(), 
    );
  }
}
