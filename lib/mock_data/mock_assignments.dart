import 'models/mock_assignment.dart';
import 'models/mock_submission.dart';

class MockAssignments {
  MockAssignments._();

  static final MockAssignment firstFlutterApp = MockAssignment(
    id: 'assignment_001',
    courseId: 'course_001',
    courseName: 'Flutter Fundamentals',
    title: 'Build Your First Flutter App',
    status: AssignmentStatus.published,
    description:
    'Create a simple counter app with a clean UI. Submit the source '
        'code as a ZIP or provide a link to a public repository.',
    dueDate: DateTime(2025, 4, 15, 23, 59),
    maxPoints: 100,
    allowTextSubmission: true,
    allowFileSubmission: true,
    attachmentName: 'assignment_brief.pdf',
    attachmentUrl: 'mock://doc/assignment_001_brief',
    createdAt: DateTime(2025, 3, 20),
  );

  static final MockAssignment stateManagementProject = MockAssignment(
    id: 'assignment_002',
    courseId: 'course_001',
    courseName: 'Flutter Fundamentals',
    title: 'State Management Mini Project',
    status: AssignmentStatus.published,
    description:
    'Build a small app that uses ChangeNotifier to manage state across '
        'multiple screens.',
    dueDate: DateTime(2025, 4, 28, 23, 59),
    maxPoints: 100,
    allowTextSubmission: true,
    allowFileSubmission: true,
    createdAt: DateTime(2025, 4, 2),
  );

  static final MockAssignment architectureReflection = MockAssignment(
    id: 'assignment_003',
    courseId: 'course_002',
    courseName: 'Advanced Flutter Architecture',
    title: 'Architecture Reflection',
    status: AssignmentStatus.published,
    description:
    'Write a 500-word reflection on how you would structure a large '
        'Flutter app using clean architecture.',
    dueDate: DateTime(2025, 5, 5, 23, 59),
    maxPoints: 50,
    allowTextSubmission: true,
    allowFileSubmission: false,
    createdAt: DateTime(2025, 4, 5),
  );

  static final MockAssignment designSystemDraft = MockAssignment(
    id: 'assignment_004',
    courseId: 'course_007',
    courseName: 'UI/UX Design Foundations',
    title: 'Design System Draft',
    status: AssignmentStatus.draft,
    description: 'Draft a small design system with colors and typography.',
    maxPoints: 100,
    allowTextSubmission: false,
    allowFileSubmission: true,
    createdAt: DateTime(2025, 4, 10),
  );

  static final List<MockAssignment> all = [
    firstFlutterApp,
    stateManagementProject,
    architectureReflection,
    designSystemDraft,
  ];

  static List<MockAssignment> byCourse(String courseId) =>
      all.where((a) => a.courseId == courseId).toList();

  static List<MockAssignment> get published =>
      all.where((a) => a.status == AssignmentStatus.published).toList();
}

class MockSubmissions {
  MockSubmissions._();

  /// Current student's submissions.
  static final List<MockSubmission> student1 = [
    MockSubmission(
      id: 'submission_001',
      assignmentId: 'assignment_001',
      assignmentTitle: 'Build Your First Flutter App',
      studentId: 'user_student_001',
      studentName: 'Aisha Rahman',
      status: SubmissionStatus.graded,
      textContent: 'Repository: https://example.com/repo',
      fileName: 'first_app.zip',
      submittedAt: DateTime(2025, 4, 10, 12, 20),
      score: 92,
      maxPoints: 100,
      feedback:
      'Great work! Clean UI and well-organized code. Consider adding '
          'unit tests for the counter logic.',
      gradedAt: DateTime(2025, 4, 12, 9, 0),
    ),
    MockSubmission(
      id: 'submission_002',
      assignmentId: 'assignment_002',
      assignmentTitle: 'State Management Mini Project',
      studentId: 'user_student_001',
      studentName: 'Aisha Rahman',
      status: SubmissionStatus.submitted,
      textContent: 'Submitted the project as per requirements.',
      fileName: 'state_project.zip',
      submittedAt: DateTime(2025, 4, 25, 18, 5),
    ),
    MockSubmission(
      id: 'submission_003',
      assignmentId: 'assignment_003',
      assignmentTitle: 'Architecture Reflection',
      studentId: 'user_student_001',
      studentName: 'Aisha Rahman',
      status: SubmissionStatus.resubmissionRequired,
      textContent: 'Initial draft.',
      submittedAt: DateTime(2025, 4, 30, 21, 0),
      feedback:
      'Please expand on how you would handle dependency injection.',
      resubmissionRequestedAt: DateTime(2025, 5, 1, 10, 30),
    ),
  ];

  /// All submissions visible to the instructor.
  static final List<MockSubmission> all = [
    ...student1,
    MockSubmission(
      id: 'submission_101',
      assignmentId: 'assignment_001',
      assignmentTitle: 'Build Your First Flutter App',
      studentId: 'user_student_002',
      studentName: 'Daniel Okafor',
      status: SubmissionStatus.submitted,
      textContent: 'Here is my submission.',
      fileName: 'daniel_first_app.zip',
      submittedAt: DateTime(2025, 4, 11, 8, 30),
    ),
    MockSubmission(
      id: 'submission_102',
      assignmentId: 'assignment_001',
      assignmentTitle: 'Build Your First Flutter App',
      studentId: 'user_student_003',
      studentName: 'Mai Tanaka',
      status: SubmissionStatus.graded,
      textContent: 'Link in the text file.',
      fileName: 'mai_first_app.zip',
      submittedAt: DateTime(2025, 4, 12, 15, 0),
      score: 88,
      maxPoints: 100,
      feedback: 'Well done. Small issues with null safety.',
      gradedAt: DateTime(2025, 4, 14, 11, 15),
    ),
  ];

  static List<MockSubmission> byAssignment(String assignmentId) =>
      all.where((s) => s.assignmentId == assignmentId).toList();

  static MockSubmission? byStudentAndAssignment(
      String studentId,
      String assignmentId,
      ) {
    for (final s in all) {
      if (s.studentId == studentId && s.assignmentId == assignmentId) {
        return s;
      }
    }
    return null;
  }
}