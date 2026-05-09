import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.textStyle,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bg = enabled ? (backgroundColor ?? colors.primary) : colors.tertiary;
    return SizedBox(
      height: 60,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(25),
        ),
        child: TextButton(
          onPressed: enabled ? onPressed : null,
          child: Text(
            label,
            style: textStyle ?? Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
