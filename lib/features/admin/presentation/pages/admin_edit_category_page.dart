import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../student/providers/category_provider.dart';

class AdminEditCategoryPage extends StatefulWidget {
  const AdminEditCategoryPage({super.key, required this.categoryId});

  final String categoryId;

  @override
  State<AdminEditCategoryPage> createState() =>
      _AdminEditCategoryPageState();
}

class _AdminEditCategoryPageState
    extends State<AdminEditCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  bool _isActive = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final categories = context.read<CategoryProvider>().categories;
    for (final c in categories) {
      if (c.id == widget.categoryId) {
        _nameCtrl = TextEditingController(text: c.name);
        _descCtrl = TextEditingController(text: c.description ?? '');
        _isActive = c.isActive;
        return;
      }
    }
    _nameCtrl = TextEditingController();
    _descCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final ok = await context.read<CategoryProvider>().update(
      categoryId: widget.categoryId,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      AppSnackbar.showSuccess(context, 'Category updated.');
      Navigator.of(context).pop();
    } else {
      AppSnackbar.showError(context, 'Could not update.');
    }
  }

  Future<void> _toggleActive() async {
    final action = _isActive ? 'Deactivate' : 'Activate';
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: '$action category?',
      message: _isActive
          ? 'The category will no longer be selectable for new courses.'
          : 'The category will become available for new courses.',
      confirmLabel: action,
      isDestructive: _isActive,
      icon: _isActive
          ? Icons.toggle_off_outlined
          : Icons.toggle_on_outlined,
    );
    if (!confirmed || !mounted) return;
    final ok = await context
        .read<CategoryProvider>()
        .setActive(widget.categoryId, !_isActive);
    if (!mounted) return;
    if (ok) setState(() => _isActive = !_isActive);
    AppSnackbar.showSuccess(
      context,
      ok ? '$action successful.' : 'Could not update.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Edit Category')),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius:
                  BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Text('Status',
                        style: AppTextStyles.labelMedium),
                    const Spacer(),
                    if (_isActive)
                      const AppStatusChip(status: AppStatus.active)
                    else
                      const AppStatusChip(status: AppStatus.inactive),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _nameCtrl,
                label: 'Category name',
                prefixIcon: Icons.category_outlined,
                validator: (v) =>
                    Validators.minLength(v, 3, field: 'Category name'),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _descCtrl,
                label: 'Description',
                maxLines: 4,
                minLines: 2,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton.primary(
                label: 'Save Changes',
                icon: Icons.save_outlined,
                isLoading: _saving,
                onPressed: _saving ? null : _save,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton.secondary(
                label: _isActive ? 'Deactivate' : 'Activate',
                icon: _isActive
                    ? Icons.toggle_off_outlined
                    : Icons.toggle_on_outlined,
                onPressed: _toggleActive,
              ),
            ],
          ),
        ),
      ),
    );
  }
}