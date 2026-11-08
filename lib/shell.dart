import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/faith_screen.dart';
import 'screens/alarm_settings_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/add_habit_screen.dart';

class Shell extends StatefulWidget { const Shell({super.key});
  @override State<Shell> createState() => _ShellState(); }

class _ShellState extends State<Shell> {
  int _i = 0;
  final _pages = const [HomeScreen(), FaithScreen(), AlarmScreen(), StatsScreen()];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: IndexedStack(index: _i, children: _pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _i,
          onDestinationSelected: (i) => setState(() => _i = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), icon: Icon(Icons.home_outlined), label: 'الرئيسية'),
            NavigationDestination(icon: Icon(Icons.self_improvement), label: 'الإيمان'),
            NavigationDestination(icon: Icon(Icons.alarm), label: 'المنبه'),
            NavigationDestination(icon: Icon(Icons.bar_chart), label: 'الإحصائيات'),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddHabitScreen())),
          backgroundColor: const Color(0xFF1B7A5E),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      );
}
