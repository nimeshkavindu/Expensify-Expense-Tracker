import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'expenses_list_screen.dart';
import 'analytics_screen.dart';
import '../../scanner/presentation/scanner_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ExpensesListScreen(),
    const AnalyticsScreen(),
    const Center(
      child: Text('Profile Screen', style: TextStyle(color: Colors.white)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const navyBackground = Color(0xFF0A192F);
    const emeraldPrimary = Color(0xFF10b77f);
    const surfaceDark = Color(0xFF112240);

    return Scaffold(
      backgroundColor: navyBackground,
      // extendBody ensures the list scrolls behind the translucent bottom nav
      extendBody: true,
      
      // 👇 Fixed: Direct 1-to-1 mapping of the index
      body: _screens[_currentIndex],

      // The Center Camera Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: emeraldPrimary,
        shape: const CircleBorder(),
        elevation: 8,
        onPressed: () {
          // Open the Camera Scanner!
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ScannerScreen()),
          );
        },
        child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // The Bottom Navigation Bar
      bottomNavigationBar: BottomAppBar(
        color: surfaceDark.withOpacity(0.95),
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNavItem(Icons.home_outlined, 'Home', 0, emeraldPrimary),
                  _buildNavItem(
                    Icons.receipt_long_outlined,
                    'Expenses',
                    1,
                    emeraldPrimary,
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNavItem(
                    Icons.pie_chart_outline,
                    'Analytics',
                    2,
                    emeraldPrimary,
                  ),
                  _buildNavItem(
                    Icons.person_outline,
                    'Profile',
                    3,
                    emeraldPrimary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index,
    Color emeraldPrimary,
  ) {
    final isSelected = _currentIndex == index;
    // Defined the slate400 color directly here!
    const slate400 = Color(0xFF94a3b8);
    final color = isSelected ? emeraldPrimary : slate400;

    return MaterialButton(
      minWidth: 70,
      onPressed: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}