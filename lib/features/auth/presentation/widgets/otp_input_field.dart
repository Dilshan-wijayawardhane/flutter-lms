import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Six-box OTP input. Returns the entered code via [onChanged] / [onCompleted].
class OtpInputField extends StatefulWidget {
  const OtpInputField({
    super.key,
    this.length = 6,
    this.onChanged,
    this.onCompleted,
    this.hasError = false,
  });

  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool hasError;

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _nodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _value => _controllers.map((c) => c.text).join();

  void _emit() {
    final value = _value;
    widget.onChanged?.call(value);
    if (value.length == widget.length) {
      widget.onCompleted?.call(value);
    }
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < widget.length - 1) {
      _nodes[index + 1].requestFocus();
    }
    _emit();
  }

  void _onKey(int index, RawKeyEvent event) {
    // Not strictly needed since we use onChanged for backspace behaviour
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (i) {
        return SizedBox(
          width: 48,
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (_) {},
            child: TextField(
              controller: _controllers[i],
              focusNode: _nodes[i],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: AppTextStyles.headingMedium,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  borderSide: BorderSide(
                    color: widget.hasError
                        ? AppColors.danger
                        : AppColors.border,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  borderSide: BorderSide(
                    color: widget.hasError
                        ? AppColors.danger
                        : AppColors.border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  borderSide: BorderSide(
                    color: widget.hasError
                        ? AppColors.danger
                        : AppColors.primary,
                    width: 1.6,
                  ),
                ),
              ),
              onChanged: (v) => _onChanged(i, v),
              onSubmitted: (_) {
                if (i < widget.length - 1) {
                  _nodes[i + 1].requestFocus();
                } else {
                  _emit();
                }
              },
            ),
          ),
        );
      }),
    );
  }
}