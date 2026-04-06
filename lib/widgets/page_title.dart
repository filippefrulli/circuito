import 'package:auto_size_text/auto_size_text.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';

class PageTitleWidget extends StatelessWidget {
  final String intro;
  final String title;
  final bool showBackButton;

  const PageTitleWidget({
    super.key,
    required this.intro,
    required this.title,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showBackButton) ...[
          SizedBox(height: topPadding + 4),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.chevron_left, size: 32),
          ),
          const SizedBox(height: 8),
        ] else
          MediaQuery.of(context).size.height < 670 ? const SizedBox(height: 16) : const SizedBox(height: 64),
        Text(
          intro,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        SizedBox(height: 12, width: MediaQuery.of(context).size.width - 110),
        DelayedDisplay(
          fadingDuration: const Duration(milliseconds: 1000),
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 120,
            child: AutoSizeText(
              title,
              wrapWords: false,
              maxLines: MediaQuery.of(context).size.height < 670 ? 1 : 2,
              minFontSize: 12,
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ),
        ),
      ],
    );
  }
}
