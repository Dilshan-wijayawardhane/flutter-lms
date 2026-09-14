import 'package:flutter/material.dart';

import 'core/routes/app_router.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const FlutterLmsApp());
}

class FlutterLmsApp extends StatelessWidget {
  const FlutterLmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter LMS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}

class AppTheme {
  static ThemeData? get light => null;
}