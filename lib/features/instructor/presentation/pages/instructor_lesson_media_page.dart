import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../core/widgets/file_picker_field.dart';
import '../../../../core/widgets/image_picker_field.dart';
import '../../../../core/widgets/selected_file_card.dart';
import '../../../../core/widgets/upload_preview.dart';
import '../../../../mock_data/models/mock_lesson.dart';

class InstructorLessonMediaPage extends StatefulWidget {
  const InstructorLessonMediaPage({super.key, required this.lessonId});

  final String lessonId;

  @override
  State<InstructorLessonMediaPage> createState() =>
      _InstructorLessonMediaPageState();
}

class _InstructorLessonMediaPageState
    extends State<InstructorLessonMediaPage> {
  // Phase 1: mock "selected" state only. Real pickers arrive with the
  // backend integration phase.
  String? _videoFileName;
  String? _videoFileSize;
  String? _documentFileName;
  String? _documentFileSize;

  LessonType _type = LessonType.video;

  void _fakePickVideo() {
    setState(() {
      _videoFileName = 'lesson_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      _videoFileSize = '24.5MB';
    });
  }

  void _fakePickDocument() {
    setState(() {
      _documentFileName =
      'lesson_document_${DateTime.now().millisecondsSinceEpoch}.pdf';
      _documentFileSize = '860KB';
    });
  }

  void _fakePickThumbnail() {
    AppSnackbar.showInfo(
      context,
      'Thumbnail picker arrives with backend integration.',
    );
  }

  void _save() {
    AppSnackbar.showSuccess(context, 'Media saved locally (mock).');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Lesson Media')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _noticeCard(),
            const SizedBox(height: AppSpacing.md),

            Text('Media type', style: AppTextStyles.labelMedium),
            const SizedBox(height: AppSpacing.xs),
            _typeSelector(),
            const SizedBox(height: AppSpacing.lg),

            if (_type == LessonType.video) ...[
              Text('Video file', style: AppTextStyles.headingSmall),
              const SizedBox(height: AppSpacing.xs),
              if (_videoFileName == null)
                FilePickerField(
                  title: 'Upload lesson video',
                  allowedTypesLabel: 'MP4, MOV up to 500MB',
                  icon: Icons.videocam_outlined,
                  onPickRequested: _fakePickVideo,
                )
              else
                UploadPreview(
                  fileName: _videoFileName!,
                  fileTypeLabel: 'VIDEO',
                  fileSizeLabel: _videoFileSize,
                  onRemove: () => setState(() {
                    _videoFileName = null;
                    _videoFileSize = null;
                  }),
                ),
              const SizedBox(height: AppSpacing.lg),
              Text('Thumbnail (optional)',
                  style: AppTextStyles.headingSmall),
              const SizedBox(height: AppSpacing.xs),
              ImagePickerField(
                label: 'Select thumbnail',
                height: 140,
                onPickRequested: _fakePickThumbnail,
              ),
            ] else if (_type == LessonType.document) ...[
              Text('Document file', style: AppTextStyles.headingSmall),
              const SizedBox(height: AppSpacing.xs),
              if (_documentFileName == null)
                FilePickerField(
                  title: 'Upload document',
                  allowedTypesLabel: 'PDF, DOCX up to 20MB',
                  icon: Icons.description_outlined,
                  onPickRequested: _fakePickDocument,
                )
              else
                SelectedFileCard(
                  fileName: _documentFileName!,
                  fileSizeLabel: _documentFileSize,
                  onRemove: () => setState(() {
                    _documentFileName = null;
                    _documentFileSize = null;
                  }),
                ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius:
                  BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  'TEXT lessons do not have attached media. Edit the lesson '
                      'content from the lesson editor.',
                  style: AppTextStyles.bodySmall,
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xl),
            AppButton.primary(
              label: 'Save Media',
              icon: Icons.save_outlined,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  Widget _noticeCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Media is not uploaded in this phase. In the backend '
                  'integration phase, this screen will send multipart requests '
                  'using the exact field names from the API contract.',
              style: AppTextStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeSelector() {
    return Row(
      children: [
        _typeButton(LessonType.video, Icons.play_circle_outline_rounded),
        const SizedBox(width: AppSpacing.xs),
        _typeButton(LessonType.document, Icons.description_outlined),
      ],
    );
  }

  Widget _typeButton(LessonType t, IconData icon) {
    final active = _type == t;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = t),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(
              color: active ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: active ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                t.label,
                style: AppTextStyles.labelMedium.copyWith(
                  color:
                  active ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}