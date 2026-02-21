import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import 'expenses_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const navyBackground = Color(0xFF0A192F);
    const surfaceDark = Color(0xFF112240);
    const emeraldPrimary = Color(0xFF10b77f);
    
    // Watch the live data from Hive
    final expenses = ref.watch(expensesProvider);

    // Process Data
    double totalSpend = 0;
    Map<String, double> categoryTotals = {};
    
    for (var expense in expenses) {
      totalSpend += expense.amount;
      categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    // Sort categories by highest spend
    var sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Define colors for the donut chart segments
    final List<Color> chartColors = [
      emeraldPrimary,
      const Color(0xFF0f766e), // Teal
      const Color(0xFF155e75), // Dark Navy/Teal
      Colors.orange,
      Colors.purple,
    ];

    return SafeArea(
      bottom: false,
      child: Container(
        color: navyBackground,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120), // Padding for nav bar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Spending Insights', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: surfaceDark, borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          Text('This Month', style: TextStyle(color: emeraldPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 4),
                          Icon(Icons.expand_more, color: emeraldPrimary, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (expenses.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 100.0),
                    child: Text("No data yet. Scan a receipt!", style: TextStyle(color: Colors.grey)),
                  ),
                )
              else ...[
                // 2. Donut Chart Card
                _buildGlassCard(
                  surfaceDark: surfaceDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Category Breakdown', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      
                      // Donut Chart
                      SizedBox(
                        height: 200,
                        child: Stack(
                          children: [
                            PieChart(
                              PieChartData(
                                sectionsSpace: 4,
                                centerSpaceRadius: 70,
                                sections: _generateChartSections(sortedCategories, totalSpend, chartColors),
                              ),
                            ),
                            // Center Text
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('TOTAL SPEND', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1.5)),
                                  Text('\$${totalSpend.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Legend
                      ...List.generate(sortedCategories.length, (index) {
                        final category = sortedCategories[index];
                        final percentage = ((category.value / totalSpend) * 100).toStringAsFixed(0);
                        final color = chartColors[index % chartColors.length];
                        
                        return _buildLegendItem(category.key, category.value, percentage, color);
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 3. Weekly Trend Bar Chart Card (Mock Data for visual UI, easily wired to real dates later)
                _buildGlassCard(
                  surfaceDark: surfaceDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Weekly Spend Trends', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              Text('Last 7 Days', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.trending_up, color: emeraldPrimary, size: 16),
                              const SizedBox(width: 4),
                              Text('+8%', style: TextStyle(color: emeraldPrimary, fontWeight: FontWeight.bold)),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 150,
                        child: _buildBarChart(emeraldPrimary),
                      ),
                    ],
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Methods ---

  Widget _buildGlassCard({required Color surfaceDark, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceDark.withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: child,
    );
  }

  List<PieChartSectionData> _generateChartSections(List<MapEntry<String, double>> sortedCategories, double totalSpend, List<Color> colors) {
    return List.generate(sortedCategories.length, (index) {
      final category = sortedCategories[index];
      final percentage = (category.value / totalSpend) * 100;
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: percentage,
        title: '', // We use the legend instead of chart labels
        radius: 16, // Thickness of the donut ring
      );
    });
  }

  Widget _buildLegendItem(String title, double amount, String percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(height: 12, width: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
          Row(
            children: [
              Text('\$${amount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text('$percentage%', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBarChart(Color emeraldPrimary) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(days[value.toInt()], style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          _makeBarGroup(0, 30, emeraldPrimary),
          _makeBarGroup(1, 85, emeraldPrimary, isTouched: true), // Highlighted day
          _makeBarGroup(2, 50, emeraldPrimary),
          _makeBarGroup(3, 25, emeraldPrimary),
          _makeBarGroup(4, 15, emeraldPrimary),
          _makeBarGroup(5, 60, emeraldPrimary),
          _makeBarGroup(6, 40, emeraldPrimary),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color primaryColor, {bool isTouched = false}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: isTouched ? primaryColor : Colors.blueGrey.withOpacity(0.3),
          width: 22,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }
}