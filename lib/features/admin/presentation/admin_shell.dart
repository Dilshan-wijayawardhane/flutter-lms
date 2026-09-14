import 'package:flutter/material.dart';
import 'package:flutter_lms/features/admin/presentation/pages/admin_categories_page.dart';
import 'package:flutter_lms/features/admin/presentation/pages/admin_courses_page.dart';
import 'package:flutter_lms/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:flutter_lms/features/admin/presentation/pages/admin_profile_page.dart';
import 'package:flutter_lms/features/admin/presentation/pages/admin_reviews_page.dart';
import 'package:flutter_lms/features/admin/presentation/pages/admin_users_page.dart';
import 'package:flutter_lms/features/admin/presentation/widgets/admin_bottom_nav.dart';

/// Hosts the 6 admin tabs with IndexedStack.
class AdminShell extends StatefulWidget {
  const AdminShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  late int _index = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          AdminDashboardPage(),
          AdminUsersPage(),
          AdminCoursesPage(),
          AdminCategoriesPage(),
          AdminReviewsPage(),
          AdminProfilePage(),
        ],
      ),
      bottomNavigationBar: AdminBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}