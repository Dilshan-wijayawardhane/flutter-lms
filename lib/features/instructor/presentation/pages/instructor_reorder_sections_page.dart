import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../mock_data/mock_quizzes.dart';
import '../../../../mock_data/models/mock_section.dart';

class InstructorReorderSectionsPage extends StatefulWidget {
  const InstructorReorderSectionsPage({
    super.key,
    required this.courseId,
  });

  final String courseId;

  @override
  State<InstructorReorderSectionsPage> createState() =>
      _InstructorReorderSectionsPageState();
}

class _InstructorReorderSectionsPageState
    extends State<InstructorReorderSectionsPage> {
  late List<MockSection> _items;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _items = List.of(MockSections.byCourse(widget.courseId));
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    setState(() {
      final s = _items.removeAt(oldIndex);
      _items.insert(newIndex, s);
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _saving = false);
    AppSnackbar.showSuccess(context, 'Order saved (mock).');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Reorder Sections')),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              color: AppColors.primarySurface,
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Drag to reorder. Order will be saved to the backend '
                          'in the integration phase.',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: _items.length,
                onReorder: _onReorder,
                itemBuilder: (_, i) {
                  final s = _items[i];
                  return _tile(s, i);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SafeArea(
                top: false,
                child: AppButton.primary(
                  label: 'Save Order',
                  icon: Icons.save_outlined,
                  isLoading: _saving,
                  onPressed: _save,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(MockSection s, int index) {
    return Container(
      key: ValueKey(s.id),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Text(
              '${index + 1}',
              style: AppTextStyles.labelLarge
                  .copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.title, style: AppTextStyles.labelLarge),
                const SizedBox(height: 2),
                Text('${s.lessonCount} lessons',
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          const Icon(
            Icons.drag_handle_rounded,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}