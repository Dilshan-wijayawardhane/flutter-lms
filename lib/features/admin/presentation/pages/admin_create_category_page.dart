import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../core/widgets/app_text_field.dart';

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
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _saving = false);
    AppSnackbar.showSuccess(context, 'Category created (mock).');
    Navigator.of(context).pop();
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
                hint: 'e.g., Mobile Development',
                prefixIcon: Icons.category_outlined,
                validator: (v) =>
                    Validators.minLength(v, 3, field: 'Category name'),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _descCtrl,
                label: 'Description (optional)',
                hint: 'A short summary of what this category contains.',
                maxLines: 4,
                minLines: 2,
              ),
              const SizedBox(height: AppSpacing.md),
              _switchRow(
                title: 'Active on creation',
                subtitle:
                'Active categories are available for new courses.',
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton.primary(
                label: 'Create Category',
                icon: Icons.check_rounded,
                isLoading: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _switchRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles_label),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles_caption),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  // Simple local aliases to avoid importing app_text_styles just for two
  // style references. Kept inline for brevity.
  static const TextStyle AppTextStyles_label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle AppTextStyles_caption = TextStyle(
    fontSize: 12,
  );
}