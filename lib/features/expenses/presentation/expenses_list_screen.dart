import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../domain/expense.dart';
import 'expenses_provider.dart';

class ExpensesListScreen extends ConsumerWidget {
  const ExpensesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const navyBackground = Color(0xFF0A192F);
    const surfaceDark = Color(0xFF112240);
    const emeraldPrimary = Color(0xFF10b77f);

    // Watch the live list of expenses from Hive!
    final expenses = ref.watch(expensesProvider);

    return SafeArea(
      bottom: false,
      child: Container(
        color: navyBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Invisible back button to balance the layout
                  const IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.transparent),
                    onPressed: null,
                  ),
                  const Text(
                    'All Expenses',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // 2. Filter Row
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFilterChip(
                    'Date Range',
                    true,
                    navyBackground,
                    emeraldPrimary,
                  ),
                  _buildFilterChip(
                    'Category',
                    false,
                    surfaceDark,
                    emeraldPrimary,
                  ),
                  _buildFilterChip(
                    'Amount',
                    false,
                    surfaceDark,
                    emeraldPrimary,
                  ),
                  _buildFilterChip(
                    'Status',
                    false,
                    surfaceDark,
                    emeraldPrimary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. Dynamic Expenses List
            Expanded(
              child: expenses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 64,
                            color: Colors.grey.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No expenses yet',
                            style: TextStyle(color: Colors.grey, fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap the camera icon to scan a receipt',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 100,
                      ),
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        // Reverse the list so the newest are at the top
                        final expense = expenses[expenses.length - 1 - index];
                        return _buildExpenseCard(
                          expense,
                          surfaceDark,
                          emeraldPrimary,
                          ref,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    Color bgDark,
    Color emeraldPrimary,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : bgDark,
        borderRadius: BorderRadius.circular(20),
        border: isSelected
            ? null
            : Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? bgDark : Colors.grey.shade300,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down,
            size: 16,
            color: isSelected ? bgDark : Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(
    Expense expense,
    Color surfaceDark,
    Color emeraldPrimary,
    WidgetRef ref,
  ) {
    // Format the date beautifully (e.g., "Oct 24, 2023")
    final dateStr = DateFormat('MMM dd, yyyy').format(expense.date);

    return Dismissible(
      // Swipe to delete logic!
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        ref.read(expensesProvider.notifier).deleteExpense(expense.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(
                  0.1,
                ), // We can make this dynamic based on category later
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.receipt, color: Colors.blueAccent),
            ),
            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.merchant,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$dateStr • ${expense.category}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Amount
            Text(
              '-\$${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
