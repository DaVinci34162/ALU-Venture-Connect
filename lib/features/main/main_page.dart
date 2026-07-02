import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../auth/domain/entities/app_user.dart';
import '../auth/presentation/bloc/auth_bloc.dart';
import '../opportunities/presentation/pages/opportunity_feed_page.dart';
import '../opportunities/presentation/pages/explore_page.dart';
import '../applications/presentation/pages/my_applications_page.dart';
import '../startup_profile/presentation/pages/startup_profile_page.dart';
import '../profile/presentation/pages/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;
    final isStudent = user?.role == UserRole.student;

    final pages = [
      const OpportunityFeedPage(),
      const ExplorePage(),
      isStudent
          ? const MyApplicationsPage()
          : const StartupProfilePage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: AppColors.surface,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
        ),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              isStudent ? Icons.assignment_outlined : Icons.business_outlined,
            ),
            activeIcon: Icon(
              isStudent ? Icons.assignment : Icons.business,
            ),
            label: isStudent ? 'Applications' : 'My Startup',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}