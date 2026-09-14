import 'package:flutter/material.dart';

/// Central color palette. Use these instead of raw Color(0x...) values
/// anywhere in the app.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF4F46E5); // Indigo
  static const Color primaryDark = Color(0xFF4338CA);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primarySurface = Color(0xFFEEF2FF);

  // Accents
  static const Color secondary = Color(0xFF0EA5E9);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);

  // Surfaces
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color card = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Borders / dividers
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFEDF1F7);

  // Status backgrounds (used by status chips)
  static const Color statusDraftBg = Color(0xFFFEF3C7);
  static const Color statusDraftFg = Color(0xFF92400E);
  static const Color statusPublishedBg = Color(0xFFDCFCE7);
  static const Color statusPublishedFg = Color(0xFF166534);
  static const Color statusArchivedBg = Color(0xFFE5E7EB);
  static const Color statusArchivedFg = Color(0xFF374151);
  static const Color statusPendingBg = Color(0xFFFEF3C7);
  static const Color statusPendingFg = Color(0xFF92400E);
  static const Color statusSubmittedBg = Color(0xFFDBEAFE);
  static const Color statusSubmittedFg = Color(0xFF1E40AF);
  static const Color statusGradedBg = Color(0xFFDCFCE7);
  static const Color statusGradedFg = Color(0xFF166534);
  static const Color statusResubmissionBg = Color(0xFFFEE2E2);
  static const Color statusResubmissionFg = Color(0xFF991B1B);
  static const Color statusActiveBg = Color(0xFFDCFCE7);
  static const Color statusActiveFg = Color(0xFF166534);
  static const Color statusInactiveBg = Color(0xFFE5E7EB);
  static const Color statusInactiveFg = Color(0xFF374151);
  static const Color statusSuspendedBg = Color(0xFFFEE2E2);
  static const Color statusSuspendedFg = Color(0xFF991B1B);

  // Misc
  static const Color shadow = Color(0x14000000);
  static const Color overlay = Color(0x33000000);
  static const Color star = Color(0xFFFACC15);
}