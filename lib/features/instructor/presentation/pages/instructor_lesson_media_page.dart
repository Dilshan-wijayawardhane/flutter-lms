import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/media_picker.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../core/widgets/file_picker_field.dart';
import '../../../../core/widgets/selected_file_card.dart';
import '../../../../core/widgets/upload_preview.dart';
import '../../../student/data/models/lesson.dart';
import '../../providers/instructor_course_provider.dart';

/// Route arguments: {'courseId', 'sectionId', 'lessonId'}.
class InstructorLessonMediaPage extends StatefulWidget {
  const InstructorLessonMediaPage({
    super.key,
    required this.courseId,
    required this.sectionId,
    required this.lessonId,
  });

  final String courseId;
  final String sectionId;
  final String lessonId;

  @override
  State<InstructorLessonMediaPage> createState() =>
      _InstructorLessonMediaPageState();
}

class _InstructorLessonMediaPageState
    extends State<InstructorLessonMediaPage> {
  LessonType _type = LessonType.video;
  PickedMedia? _picked;
  double? _uploadProgress;
  bool _uploading = false;

  Lesson? _lesson;

  @override
  void initState() {
    super.initState();
    final lessons = context
        .read<InstructorCourseProvider>()
        .lessonsFor(widget.courseId, widget.sectionId);
    for (final l in lessons) {
      if (l.id == widget.lessonId) {
        _lesson = l;
        _type = l.type == LessonType.text ? LessonType.video : l.type;
        break;
      }
    }
  }

  void _pickVideo() async {
    final picked = await MediaPicker.pickFile(
      allowedExtensions: ['mp4', 'mov', 'webm', 'mkv'],
    );
    if (picked == null) return;
    setState(() => _picked = picked);
  }

  void _pickDocument() async {
    final picked = await MediaPicker.pickFile(
      allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
    );
    if (picked == null) return;
    setState(() => _picked = picked);
  }

  Future<void> _upload() async {
    final picked = _picked;
    if (picked == null) return;

    setState(() {
      _uploading = true;
      _uploadProgress = 0;
    });

    final p = context.read<InstructorCourseProvider>();
    final ok = _type == LessonType.video
        ? await p.uploadLessonVideo(
      courseId: widget.courseId,
      sectionId: widget.sectionId,
      lessonId: widget.lessonId,
      filePath: picked.path,
      fileName: picked.name,
      mimeType: picked.mimeType,
      onSendProgress: (sent, total) {
        if (total > 0 && mounted) {
          setState(() => _uploadProgress = sent / total);
        }
      },
    )
        : await p.uploadLessonDocument(
      courseId: widget.courseId,
      sectionId: widget.sectionId,
      lessonId: widget.lessonId,
      filePath: picked.path,
      fileName: picked.name,
      mimeType: picked.mimeType,
      onSendProgress: (sent, total) {
        if (total > 0 && mounted) {
          setState(() => _uploadProgress = sent / total);
        }
      },
    );

    if (!mounted) return;
    setState(() {
      _uploading = false;
      _uploadProgress = null;
    });

    if (ok) {
      AppSnackbar.showSuccess(context, 'Media uploaded.');
      setState(() => _picked = null);
    } else {
      AppSnackbar.showError(
        context,
        p.errorMessage ?? 'Upload failed.',
      );
    }
  }

  Future<void> _deleteMedia() async {
    final ok = await context
        .read<InstructorCourseProvider>()
        .deleteLessonMedia(
      courseId: widget.courseId,
      sectionId: widget.sectionId,
      lessonId: widget.lessonId,
    );
    if (!mounted) return;
    if (ok) {
      AppSnackbar.showSuccess(context, 'Media removed.');
    } else {
      AppSnackbar.showError(context, 'Could not remove media.');
    }
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
            _notice(),
            const SizedBox(height: AppSpacing.md),
            Text('Media type', style: AppTextStyles.labelMedium),
            const SizedBox(height: AppSpacing.xs),
            _typeSelector(),
            const SizedBox(height: AppSpacing.lg),

            if (_type == LessonType.video) ...[
              Text('Video file', style: AppTextStyles.headingSmall),
              const SizedBox(height: AppSpacing.xs),
              if (_picked == null)
                FilePickerField(
                  title: 'Select video',
                  allowedTypesLabel: 'MP4, MOV up to 500MB',
                  allowedExtensions: const ['mp4', 'mov', 'webm', 'mkv'],
                  icon: Icons.videocam_outlined,
                  onPicked: (m) => setState(() => _picked = m),
                )
              else
                UploadPreview(
                  fileName: _picked!.name,
                  fileTypeLabel: 'VIDEO',
                  fileSizeLabel: _picked!.sizeLabel,
                  progress: _uploadProgress,
                  onRemove: () => setState(() => _picked = null),
                ),
            ] else if (_type == LessonType.document) ...[
              Text('Document file', style: AppTextStyles.headingSmall),
              const SizedBox(height: AppSpacing.xs),
              if (_picked == null)
                FilePickerField(
                  title: 'Select document',
                  allowedTypesLabel: 'PDF, DOCX up to 20MB',
                  allowedExtensions: const [
                    'pdf',
                    'doc',
                    'docx',
                    'ppt',
                    'pptx',
                  ],
                  icon: Icons.description_outlined,
                  onPicked: (m) => setState(() => _picked = m),
                )
              else
                SelectedFileCard(
                  fileName: _picked!.name,
                  fileSizeLabel: _picked!.sizeLabel,
                  onRemove: () => setState(() => _picked = null),
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
                  'TEXT lessons do not have attached media. Edit the lesson content from the lesson editor.',
                  style: AppTextStyles.bodySmall,
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xl),
            if (_picked != null && !_uploading)
              AppButton.primary(
                label: 'Upload Media',
                icon: Icons.cloud_upload_outlined,
                onPressed: _upload,
              ),
            if (_lesson != null &&
                ((_lesson!.videoUrl?.isNotEmpty ?? false) ||
                    (_lesson!.documentUrl?.isNotEmpty ?? false))) ...[
              const SizedBox(height: AppSpacing.sm),
              AppButton.secondary(
                label: 'Remove existing media',
                icon: Icons.delete_outline_rounded,
                onPressed: _uploading ? null : _deleteMedia,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _notice() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Pick a file and tap Upload. Progress appears above.',
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
        onTap: () => setState(() {
          _type = t;
          _picked = null;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color:
            active ? AppColors.primary : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(
              color: active ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18,
                  color: active
                      ? Colors.white
                      : AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                t.name.toUpperCase(),
                style: AppTextStyles.labelMedium.copyWith(
                  color: active
                      ? Colors.white
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}