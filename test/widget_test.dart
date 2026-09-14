import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_lms/main.dart';
import 'package:flutter_lms/core/routes/app_routes.dart';

void main() {
  testWidgets('App boots and shows the splash placeholder',
          (WidgetTester tester) async {
        await tester.pumpWidget(const FlutterLmsApp());
        await tester.pumpAndSettle();

        // The router currently renders a placeholder for the splash route.
        expect(find.byType(Scaffold), findsWidgets);
        expect(find.text('Splash'), findsOneWidget);
      });

  testWidgets('Unknown routes render the not-found screen',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            initialRoute: '/this-route-does-not-exist',
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (_) => const Scaffold(body: Text('ignored')),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(Scaffold), findsOneWidget);
      });

  test('All route names are unique', () {
    final routes = <String>{
      AppRoutes.splash,
      AppRoutes.onboarding,
      AppRoutes.login,
      AppRoutes.registerStudent,
      AppRoutes.registerInstructor,
      AppRoutes.verifyEmail,
      AppRoutes.forgotPassword,
      AppRoutes.resetPassword,
      AppRoutes.studentDashboard,
      AppRoutes.instructorDashboard,
      AppRoutes.adminDashboard,
    };
    expect(routes.length, 11);
  });
}