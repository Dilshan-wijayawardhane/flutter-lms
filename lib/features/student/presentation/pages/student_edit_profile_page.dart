import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/media_picker.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_success_message.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/image_picker_field.dart';
import '../../providers/profile_provider.dart';

class StudentEditProfilePage extends StatefulWidget {
  const StudentEditProfilePage({super.key});

  @override
  State<StudentEditProfilePage> createState() =>
      _StudentEditProfilePageState();
}

class _StudentEditProfilePageState extends State<StudentEditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _countryCtrl;
  late final TextEditingController _educationCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _interestsCtrl;

  PickedMedia? _pickedImage;
  double? _uploadProgress;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = context.read<ProfileProvider>().profile;
    _nameCtrl = TextEditingController(text: p?.fullName ?? '');
    _phoneCtrl = TextEditingController(text: p?.phone ?? '');
    _countryCtrl = TextEditingController(text: p?.country ?? '');
    _educationCtrl =
        TextEditingController(text: p?.educationLevel ?? '');
    _bioCtrl = TextEditingController(text: p?.bio ?? '');
    _interestsCtrl =
        TextEditingController(text: (p?.interests ?? []).join(', '));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _countryCtrl.dispose();
    _educationCtrl.dispose();
    _bioCtrl.dispose();
    _interestsCtrl.dispose();
    super.dispose();
  }

  void _onPickedImage(PickedMedia media) {
    setState(() => _pickedImage = media);
  }

  Future<void> _uploadImage() async {
    final picked = _pickedImage;
    if (picked == null) return;

    setState(() => _uploadProgress = 0);
    final ok = await context.read<ProfileProvider>().uploadProfileImage(
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
    setState(() => _uploadProgress = null);
    if (ok) {
      AppSnackbar.showSuccess(context, 'Profile image updated.');
      setState(() => _pickedImage = null);
    } else {
      AppSnackbar.showError(context, 'Upload failed.');
    }
  }

  Future<void> _removeImage() async {
    final ok = await context.read<ProfileProvider>().deleteProfileImage();
    if (!mounted) return;
    if (ok) {
      setState(() => _pickedImage = null);
      AppSnackbar.showSuccess(context, 'Profile image removed.');
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ProfileProvider>();
    final current = provider.profile;
    if (current == null) {
      AppSnackbar.showError(context, 'Profile not loaded yet.');
      return;
    }

    setState(() => _saving = true);

    final updated = current.copyWith(
      fullName: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      country: _countryCtrl.text.trim().isEmpty
          ? null
          : _countryCtrl.text.trim(),
      educationLevel: _educationCtrl.text.trim().isEmpty
          ? null
          : _educationCtrl.text.trim(),
      bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
      interests: _interestsCtrl.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
    );

    provider.applyLocalUpdate(updated);

    if (!mounted) return;
    setState(() => _saving = false);
    AppSnackbar.showSuccess(context, 'Profile saved locally.');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              ImagePickerField(
                imageUrl: provider.profile?.profileImageUrl,
                localFilePath: _pickedImage?.path,
                uploadProgress: _uploadProgress,
                label: 'Change profile picture',
                onPicked: _onPickedImage,
                onUpload: _pickedImage == null ? null : _uploadImage,
                onRemove: _removeImage,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _nameCtrl,
                label: 'Full name',
                prefixIcon: Icons.person_outline_rounded,
                validator: (v) =>
                    Validators.minLength(v, 2, field: 'Full name'),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _phoneCtrl,
                label: 'Phone',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: Validators.phone,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _countryCtrl,
                label: 'Country',
                prefixIcon: Icons.public_rounded,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _educationCtrl,
                label: 'Education level',
                prefixIcon: Icons.school_outlined,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _interestsCtrl,
                label: 'Interests (comma separated)',
                prefixIcon: Icons.star_outline_rounded,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _bioCtrl,
                label: 'Bio',
                maxLines: 4,
                validator: (v) =>
                    Validators.maxLength(v, 500, field: 'Bio'),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton.primary(
                label: 'Save Changes',
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