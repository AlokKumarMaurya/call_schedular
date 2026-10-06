import 'package:call_schedular/core/widgets/app_glass_action_button.dart';
import 'package:flutter/material.dart';

class SchedulePrimaryButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final bool isLoading;

  const SchedulePrimaryButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppGlassActionButton(
      label: title,
      icon: Icons.check_rounded,
      onPressed: onPressed,
      isLoading: isLoading,
      expand: true,
    );
  }
}
