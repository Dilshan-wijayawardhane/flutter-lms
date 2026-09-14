import 'package:flutter/material.dart';
import 'pages/student_courses_page.dart';
import 'pages/student_dashboard_page.dart';
import 'pages/student_my_courses_page.dart';
import 'pages/student_notifications_page.dart';
import 'pages/student_profile_page.dart';
import 'widgets/student_bottom_nav.dart';

/// Hosts the 5 student tabs using an IndexedStack so each tab keeps its
/// state while the user switches back and forth.
class StudentShell extends StatefulWidget {
  const StudentShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  late int _index = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          StudentDashboardPage(),
          StudentCoursesPage(),
          StudentMyCoursesPage(),
          StudentNotificationsPage(),
          StudentProfilePage(),
        ],
      ),
      bottomNavigationBar: StudentBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}