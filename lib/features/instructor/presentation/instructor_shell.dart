import 'package:flutter/material.dart';

import 'pages/instructor_assignments_page.dart';
import 'pages/instructor_courses_page.dart';
import 'pages/instructor_dashboard_page.dart';
import 'pages/instructor_enrollments_page.dart';
import 'pages/instructor_profile_page.dart';
import 'widgets/instructor_bottom_nav.dart';

/// Hosts the 5 instructor tabs with IndexedStack.
class InstructorShell extends StatefulWidget {
  const InstructorShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<InstructorShell> createState() => _InstructorShellState();
}

class _InstructorShellState extends State<InstructorShell> {
  late int _index = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          InstructorDashboardPage(),
          InstructorCoursesPage(),
          InstructorEnrollmentsPage(),
          InstructorAssignmentsPage(courseId: '',),
          InstructorProfilePage(),
        ],
      ),
      bottomNavigationBar: InstructorBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}