import 'package:flutter/material.dart';

import 'app_primary_button.dart';

/// Backwards-compatible alias for [AppPrimaryButton].
class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppPrimaryButton(
      onPressed: onPressed,
      label: text,
      isLoading: isLoading,
    );
  }
}
