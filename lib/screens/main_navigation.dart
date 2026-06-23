import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import 'dashboard_screen.dart';
import 'temario_tab_screen.dart';
import 'calendar_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const TemarioTabScreen();
      case 2:
        return const CalendarScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const DashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getScreen(_currentIndex),
      bottomNavigationBar: Container(
        height: 76.0,
        decoration: BoxDecoration(
          color: AppColors.white,
          border: const Border(
            top: BorderSide(color: AppColors.surfaceContainerHigh, width: 1.0),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 12.0,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textTertiary,
          elevation: 0.0,
          selectedLabelStyle: AppTypography.labelSm.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 11.0,
          ),
          unselectedLabelStyle: AppTypography.labelSm.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 11.0,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 0 ? Ionicons.grid : Ionicons.grid_outline,
                size: 24.0,
              ),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 1 ? Ionicons.book : Ionicons.book_outline,
                size: 24.0,
              ),
              label: 'Temario',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 2 ? Ionicons.calendar : Ionicons.calendar_outline,
                size: 24.0,
              ),
              label: 'Calendario',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 3 ? Ionicons.person : Ionicons.person_outline,
                size: 24.0,
              ),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
