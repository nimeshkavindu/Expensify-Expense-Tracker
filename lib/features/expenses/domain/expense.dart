import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 0, adapterName: 'ExpenseAdapter')
class Expense extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String merchant;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final String? receiptPath;

  Expense({
    required this.id,
    required this.merchant,
    required this.amount,
    required this.date,
    required this.category,
    this.receiptPath,
  });
}