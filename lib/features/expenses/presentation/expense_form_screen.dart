import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/expense.dart';
import 'expenses_provider.dart';

class ExpenseFormScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> initialData;

  const ExpenseFormScreen({super.key, required this.initialData});

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  late TextEditingController _merchantController;
  late TextEditingController _amountController;
  String _selectedCategory = 'Food';

  final List<String> _categories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    // Auto-fill the form with the AI's extracted data!
    _merchantController = TextEditingController(
      text: widget.initialData['merchant'],
    );
    _amountController = TextEditingController(
      text: widget.initialData['amount'].toString(),
    );
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _saveExpense() {
    final expense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      merchant: _merchantController.text,
      amount: double.tryParse(_amountController.text) ?? 0.0,
      date: widget.initialData['date'] ?? DateTime.now(),
      category: _selectedCategory,
      receiptPath: widget.initialData['imagePath'],
    );

    // Save to Hive Database
    ref.read(expensesProvider.notifier).addExpense(expense);

    // Go back to the dashboard
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const navyBackground = Color(0xFF0A192F);
    const emeraldPrimary = Color(0xFF10b77f);
    const surfaceDark = Color(0xFF112240);

    return Scaffold(
      backgroundColor: navyBackground,
      appBar: AppBar(
        backgroundColor: navyBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Confirm Expense',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail of the receipt
            if (widget.initialData['imagePath'] != null)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(widget.initialData['imagePath']),
                    height: 150,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            const SizedBox(height: 32),

            // Merchant Field
            const Text(
              'Merchant',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _merchantController,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: surfaceDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.storefront, color: emeraldPrimary),
              ),
            ),

            const SizedBox(height: 24),

            // Amount Field
            const Text(
              'Total Amount',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: surfaceDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(
                  Icons.attach_money,
                  color: emeraldPrimary,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Category Dropdown
            const Text(
              'Category',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: surfaceDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  dropdownColor: surfaceDark,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: emeraldPrimary,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  onChanged: (String? newValue) {
                    setState(() => _selectedCategory = newValue!);
                  },
                  items: _categories.map<DropdownMenuItem<String>>((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: emeraldPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _saveExpense,
                child: const Text(
                  'Save Expense',
                  style: TextStyle(
                    color: navyBackground,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
