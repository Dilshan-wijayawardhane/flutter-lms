import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../student/providers/category_provider.dart';

class AdminCreateCategoryPage extends StatefulWidget {
  const AdminCreateCategoryPage({super.key});

  @override
  State<AdminCreateCategoryPage> createState() =>
      _AdminCreateCategoryPageState();
}

class _AdminCreateCategoryPageState
    extends State<AdminCreateCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _isActive = true;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final created = await context.read<CategoryProvider>().create(
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      isActive: _isActive,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (created != null) {
      AppSnackbar.showSuccess(context, 'Category created.');
      Navigator.of(context).pop();
    } else {
      AppSnackbar.showError(context, 'Could not create category.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Create Category')),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
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
                label: 'Description (optional)',
                maxLines: 4,
                minLines: 2,
              ),
              const SizedBox(height: AppSpacing.md),
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Active on creation',
                              style: AppTextStyles.labelLarge),
                          const SizedBox(height: 2),
                          Text(
                            'Active categories are available for new courses.',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                      activeThumbColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton.primary(
                label: 'Create Category',
                icon: Icons.check_rounded,
                isLoading: _saving,
                onPressed: _saving ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}