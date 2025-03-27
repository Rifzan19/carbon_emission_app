import 'package:carbon_emission_app/config/theme.dart';
import 'package:carbon_emission_app/providers/bottom_nav_bar/bottom_nav_bar_provider.dart';
import 'package:carbon_emission_app/screens/electricity_screen.dart';
import 'package:carbon_emission_app/screens/history_screen.dart';
import 'package:carbon_emission_app/screens/home_screen.dart';
import 'package:carbon_emission_app/screens/transportation_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Dashboard extends ConsumerStatefulWidget {
  const Dashboard({super.key});

  @override
  ConsumerState<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard> {
  final List<Widget> _screens = [
    HomeScreen(),
    TransportationScreen(),
    ElectricityScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: ref.watch(bottomNavBarIndexProvider),
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: secondaryGreen,
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.car),
            label: 'Transportation',
            backgroundColor: primaryBlue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bolt),
            label: 'Electricity',
            backgroundColor: primaryYellow,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
            backgroundColor: primaryGreen,
          ),
        ],
        currentIndex: ref.watch(bottomNavBarIndexProvider),
        onTap: (index) {
          ref.read(bottomNavBarIndexProvider.notifier).updateIndex(index);
        },
        selectedLabelStyle: label(bold: true),
      ),
    );
  }
}