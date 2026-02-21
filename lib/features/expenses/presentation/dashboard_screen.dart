import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'expenses_provider.dart';
import '../domain/expense.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const emeraldPrimary = Color(0xFF10b77f);
    const surfaceDark = Color(0xFF112240);

    // 1. Fetch live data from the provider
    final expenses = ref.watch(expensesProvider);

    // 2. Calculate Real Data
    double totalSpend = 0;
    Map<String, double> categoryTotals = {};

    for (var expense in expenses) {
      totalSpend += expense.amount;
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    // Format the total spend to split the dollars and cents for the UI
    final totalString = totalSpend.toStringAsFixed(2);
    final dollarPart = totalString.split('.')[0];
    final centsPart = totalString.split('.')[1];

    // Get the 5 most recent expenses
    final recentExpenses = expenses.reversed.take(5).toList();

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Clean Header (Removed Profile)
            Padding(
              padding: const EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                top: 24.0,
                bottom: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Overview',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // 2. Total Monthly Spend (Live Data)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: surfaceDark.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Spend',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '\$$dollarPart',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 32,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '.$centsPart',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: emeraldPrimary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.insights,
                                    color: emeraldPrimary,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Live',
                                    style: TextStyle(
                                      color: emeraldPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Mini mock chart (Keeping visual for design aesthetics)
                        SizedBox(
                          height: 60,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildBar(0.3, emeraldPrimary),
                              _buildBar(0.5, emeraldPrimary),
                              _buildBar(0.4, emeraldPrimary),
                              _buildBar(0.7, emeraldPrimary),
                              _buildBar(0.55, emeraldPrimary),
                              _buildBar(0.35, emeraldPrimary),
                              _buildBar(0.6, emeraldPrimary),
                              _buildBar(0.85, emeraldPrimary),
                              Container(
                                width: 20,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      emeraldPrimary,
                                      emeraldPrimary.withOpacity(0.6),
                                    ],
                                  ),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: emeraldPrimary.withOpacity(0.4),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 3. Dynamic Category Summary
            Padding(
              padding: const EdgeInsets.only(
                left: 24,
                top: 24,
                bottom: 16,
                right: 24,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Category Summary',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (categoryTotals.isNotEmpty)
                    Text(
                      'See all',
                      style: TextStyle(
                        color: emeraldPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),

            // Increased height to 140 to prevent bottom overflow
            SizedBox(
              height: 140,
              child: categoryTotals.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        'No categories yet. Scan an expense!',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: categoryTotals.entries.map((entry) {
                        double progress = totalSpend > 0
                            ? entry.value / totalSpend
                            : 0;
                        return _buildCategoryCard(
                          entry.key,
                          '\$${entry.value.toStringAsFixed(0)}',
                          _getCategoryIcon(entry.key),
                          _getCategoryColor(entry.key),
                          progress,
                        );
                      }).toList(),
                    ),
            ),

            // 4. Real Recent Scans
            const Padding(
              padding: EdgeInsets.only(left: 24, top: 32, bottom: 16),
              child: Text(
                'Recent Scans',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: recentExpenses.isEmpty
                    ? [
                        const Center(
                          child: Text(
                            'No recent scans found.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ]
                    : recentExpenses.map((expense) {
                        final dateStr = DateFormat(
                          'MMM dd, hh:mm a',
                        ).format(expense.date);
                        return _buildTransaction(
                          expense.merchant,
                          dateStr,
                          '-\$${expense.amount.toStringAsFixed(2)}',
                          _getCategoryIcon(expense.category),
                        );
                      }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Utility Helpers ---

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Transport':
        return Icons.local_taxi;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Bills':
        return Icons.receipt_long;
      default:
        return Icons.category;
    }
  }

  MaterialColor _getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return Colors.orange;
      case 'Transport':
        return Colors.blue;
      case 'Shopping':
        return Colors.pink;
      case 'Bills':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildBar(double heightFactor, Color color) {
    return FractionallySizedBox(
      heightFactor: heightFactor,
      child: Container(
        width: 20,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    String title,
    String amount,
    IconData icon,
    MaterialColor color,
    double progress,
  ) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF112240).withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color.shade400, size: 20),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color.shade400),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildTransaction(
    String title,
    String date,
    String amount,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF112240).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0A192F),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF10b77f), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  date,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
