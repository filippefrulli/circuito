import 'package:flutter/material.dart';

/// Full-screen centered overlay showing a race result time difference.
/// Must be placed inside a [Stack] that fills the screen.
///
/// [primaryText] is shown large. [subtitle] and [tertiaryText] are optional
/// additional lines shown below at decreasing sizes.
class RaceResultPopup extends StatelessWidget {
  final String primaryText;
  final String? subtitle;
  final String? tertiaryText;
  final Color color;

  const RaceResultPopup({
    super.key,
    required this.primaryText,
    this.subtitle,
    this.tertiaryText,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color, width: 3),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  primaryText,
                  style: TextStyle(
                    color: color,
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Raleway',
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: color,
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Raleway',
                    ),
                  ),
                ],
                if (tertiaryText != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    tertiaryText!,
                    style: TextStyle(
                      color: color,
                      fontSize: 20,
                      fontFamily: 'Raleway',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
