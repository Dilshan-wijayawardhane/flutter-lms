import 'models/mock_lesson.dart';
import 'models/mock_quiz.dart';
import 'models/mock_quiz_attempt.dart';
import 'models/mock_quiz_question.dart';
import 'models/mock_section.dart';

class MockSections {
  MockSections._();

  static const List<MockSection> flutterFundamentals = [
    MockSection(
      id: 'section_001',
      courseId: 'course_001',
      title: 'Getting Started',
      description: 'Install Flutter and set up your first project.',
      order: 1,
      lessonCount: 4,
    ),
    MockSection(
      id: 'section_002',
      courseId: 'course_001',
      title: 'Core Widgets',
      description: 'Layout, text, containers, and common widgets.',
      order: 2,
      lessonCount: 6,
    ),
    MockSection(
      id: 'section_003',
      courseId: 'course_001',
      title: 'State Management',
      description: 'Local state, ChangeNotifier, and architecture basics.',
      order: 3,
      lessonCount: 7,
    ),
    MockSection(
      id: 'section_004',
      courseId: 'course_001',
      title: 'Building Real Apps',
      description: 'Navigation, forms, and network integration.',
      order: 4,
      lessonCount: 7,
    ),
  ];

  static const List<MockSection> advancedFlutter = [
    MockSection(
      id: 'section_101',
      courseId: 'course_002',
      title: 'Clean Architecture',
      order: 1,
      lessonCount: 6,
    ),
    MockSection(
      id: 'section_102',
      courseId: 'course_002',
      title: 'Advanced State Management',
      order: 2,
      lessonCount: 8,
    ),
    MockSection(
      id: 'section_103',
      courseId: 'course_002',
      title: 'Testing',
      order: 3,
      lessonCount: 6,
    ),
  ];

  static List<MockSection> byCourse(String courseId) {
    switch (courseId) {
      case 'course_001':
        return flutterFundamentals;
      case 'course_002':
        return advancedFlutter;
      default:
        return const [];
    }
  }
}

class MockLessons {
  MockLessons._();

  static const List<MockLesson> flutterFundamentals = [
    // Section 1
    MockLesson(
      id: 'lesson_001',
      sectionId: 'section_001',
      courseId: 'course_001',
      title: 'Welcome to Flutter',
      type: LessonType.text,
      status: LessonStatus.published,
      order: 1,
      durationMinutes: 5,
      content:
      'Flutter is Google\'s UI toolkit for building natively compiled '
          'applications for mobile, web, and desktop from a single codebase. '
          'In this lesson, we will look at what Flutter is, why it is popular, '
          'and what you will build throughout this course.',
      isCompleted: true,
    ),
    MockLesson(
      id: 'lesson_002',
      sectionId: 'section_001',
      courseId: 'course_001',
      title: 'Installing the SDK',
      type: LessonType.video,
      status: LessonStatus.published,
      order: 2,
      durationMinutes: 12,
      videoUrl: 'mock://video/lesson_002',
      isCompleted: true,
    ),
    MockLesson(
      id: 'lesson_003',
      sectionId: 'section_001',
      courseId: 'course_001',
      title: 'Your First App',
      type: LessonType.video,
      status: LessonStatus.published,
      order: 3,
      durationMinutes: 18,
      videoUrl: 'mock://video/lesson_003',
      isCompleted: true,
    ),
    MockLesson(
      id: 'lesson_004',
      sectionId: 'section_001',
      courseId: 'course_001',
      title: 'Setup Cheat Sheet',
      type: LessonType.document,
      status: LessonStatus.published,
      order: 4,
      durationMinutes: 3,
      documentUrl: 'mock://doc/lesson_004',
      documentName: 'setup_cheatsheet.pdf',
      isCompleted: true,
    ),

    // Section 2
    MockLesson(
      id: 'lesson_005',
      sectionId: 'section_002',
      courseId: 'course_001',
      title: 'Stateless vs Stateful',
      type: LessonType.text,
      status: LessonStatus.published,
      order: 1,
      durationMinutes: 10,
      content:
      'Stateless widgets are immutable and do not change over time. '
          'Stateful widgets hold state that can change during the lifetime of '
          'the widget and rebuild when setState is called.',
      isCompleted: true,
    ),
    MockLesson(
      id: 'lesson_006',
      sectionId: 'section_002',
      courseId: 'course_001',
      title: 'Layout Basics',
      type: LessonType.video,
      status: LessonStatus.published,
      order: 2,
      durationMinutes: 22,
      videoUrl: 'mock://video/lesson_006',
      isCompleted: false,
    ),
    MockLesson(
      id: 'lesson_007',
      sectionId: 'section_002',
      courseId: 'course_001',
      title: 'Common Widgets',
      type: LessonType.video,
      status: LessonStatus.published,
      order: 3,
      durationMinutes: 26,
      videoUrl: 'mock://video/lesson_007',
      isCompleted: false,
    ),
    MockLesson(
      id: 'lesson_008',
      sectionId: 'section_002',
      courseId: 'course_001',
      title: 'Widgets Reference',
      type: LessonType.document,
      status: LessonStatus.published,
      order: 4,
      durationMinutes: 2,
      documentUrl: 'mock://doc/lesson_008',
      documentName: 'widgets_reference.pdf',
      isCompleted: false,
    ),

    // Section 3 (locked)
    MockLesson(
      id: 'lesson_009',
      sectionId: 'section_003',
      courseId: 'course_001',
      title: 'Introduction to State',
      type: LessonType.text,
      status: LessonStatus.published,
      order: 1,
      durationMinutes: 8,
      content: 'Managing state is at the heart of every Flutter app.',
      isLocked: true,
    ),
    MockLesson(
      id: 'lesson_010',
      sectionId: 'section_003',
      courseId: 'course_001',
      title: 'ChangeNotifier in Practice',
      type: LessonType.video,
      status: LessonStatus.published,
      order: 2,
      durationMinutes: 24,
      videoUrl: 'mock://video/lesson_010',
      isLocked: true,
    ),
  ];

  static List<MockLesson> bySection(String sectionId) =>
      flutterFundamentals.where((l) => l.sectionId == sectionId).toList();

  static List<MockLesson> byCourse(String courseId) =>
      flutterFundamentals.where((l) => l.courseId == courseId).toList();
}

class MockQuizzes {
  MockQuizzes._();

  static const MockQuiz flutterBasics = MockQuiz(
    id: 'quiz_001',
    courseId: 'course_001',
    title: 'Flutter Basics Quiz',
    status: QuizStatus.published,
    description: 'Test your understanding of core Flutter concepts.',
    durationMinutes: 20,
    passingScore: 60,
    maxAttempts: 3,
    questionCount: 5,
    totalPoints: 50,
  );

  static const MockQuiz widgetsQuiz = MockQuiz(
    id: 'quiz_002',
    courseId: 'course_001',
    title: 'Widgets Deep Dive Quiz',
    status: QuizStatus.published,
    description: 'Stateless, stateful, and layout widgets.',
    durationMinutes: 15,
    passingScore: 70,
    maxAttempts: 3,
    questionCount: 4,
    totalPoints: 40,
  );

  static const MockQuiz architectureQuiz = MockQuiz(
    id: 'quiz_003',
    courseId: 'course_002',
    title: 'Clean Architecture Quiz',
    status: QuizStatus.draft,
    description: 'Layers, boundaries, and dependency inversion.',
    durationMinutes: 25,
    passingScore: 70,
    maxAttempts: 2,
    questionCount: 3,
    totalPoints: 30,
  );

  static const List<MockQuiz> all = [
    flutterBasics,
    widgetsQuiz,
    architectureQuiz,
  ];

  static List<MockQuiz> byCourse(String courseId) =>
      all.where((q) => q.courseId == courseId).toList();
}

class MockQuizQuestions {
  MockQuizQuestions._();

  static const List<MockQuizQuestion> flutterBasics = [
    MockQuizQuestion(
      id: 'question_001',
      quizId: 'quiz_001',
      text: 'Which widget is used for creating immutable UI?',
      order: 1,
      points: 10,
      options: [
        'StatefulWidget',
        'StatelessWidget',
        'InheritedWidget',
        'ProviderWidget',
      ],
      correctOptionIndex: 1,
    ),
    MockQuizQuestion(
      id: 'question_002',
      quizId: 'quiz_001',
      text: 'What does setState() do?',
      order: 2,
      points: 10,
      options: [
        'Rebuilds the current widget subtree',
        'Restarts the app',
        'Saves state to disk',
        'Creates a new isolate',
      ],
      correctOptionIndex: 0,
    ),
    MockQuizQuestion(
      id: 'question_003',
      quizId: 'quiz_001',
      text: 'Which language is used to write Flutter code?',
      order: 3,
      points: 10,
      options: ['Kotlin', 'Swift', 'Dart', 'JavaScript'],
      correctOptionIndex: 2,
    ),
    MockQuizQuestion(
      id: 'question_004',
      quizId: 'quiz_001',
      text: 'Which widget lays out children vertically?',
      order: 4,
      points: 10,
      options: ['Row', 'Column', 'Stack', 'Wrap'],
      correctOptionIndex: 1,
    ),
    MockQuizQuestion(
      id: 'question_005',
      quizId: 'quiz_001',
      text: 'What is a Widget in Flutter?',
      order: 5,
      points: 10,
      options: [
        'A database table',
        'A configuration describing part of the UI',
        'A native Android view',
        'A network request',
      ],
      correctOptionIndex: 1,
    ),
  ];

  static List<MockQuizQuestion> byQuiz(String quizId) {
    if (quizId == 'quiz_001') return flutterBasics;
    return const [];
  }
}

class MockQuizAttempts {
  MockQuizAttempts._();

  static final List<MockQuizAttempt> student1Attempts = [
    MockQuizAttempt(
      id: 'attempt_001',
      quizId: 'quiz_001',
      quizTitle: 'Flutter Basics Quiz',
      studentId: 'user_student_001',
      studentName: 'Aisha Rahman',
      attemptNumber: 1,
      score: 30,
      totalPoints: 50,
      passed: false,
      submittedAt: DateTime(2025, 3, 5, 14, 30),
      durationSeconds: 820,
    ),
    MockQuizAttempt(
      id: 'attempt_002',
      quizId: 'quiz_001',
      quizTitle: 'Flutter Basics Quiz',
      studentId: 'user_student_001',
      studentName: 'Aisha Rahman',
      attemptNumber: 2,
      score: 45,
      totalPoints: 50,
      passed: true,
      submittedAt: DateTime(2025, 3, 7, 10, 5),
      durationSeconds: 640,
    ),
  ];

  static final List<MockQuizAttempt> byInstructor = [
    ...student1Attempts,
    MockQuizAttempt(
      id: 'attempt_003',
      quizId: 'quiz_001',
      quizTitle: 'Flutter Basics Quiz',
      studentId: 'user_student_002',
      studentName: 'Daniel Okafor',
      attemptNumber: 1,
      score: 50,
      totalPoints: 50,
      passed: true,
      submittedAt: DateTime(2025, 3, 6, 9, 45),
      durationSeconds: 510,
    ),
    MockQuizAttempt(
      id: 'attempt_004',
      quizId: 'quiz_002',
      quizTitle: 'Widgets Deep Dive Quiz',
      studentId: 'user_student_003',
      studentName: 'Mai Tanaka',
      attemptNumber: 1,
      score: 30,
      totalPoints: 40,
      passed: false,
      submittedAt: DateTime(2025, 3, 8, 16, 20),
      durationSeconds: 700,
    ),
  ];
}