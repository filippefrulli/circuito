import 'package:auto_size_text/auto_size_text.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';

class PageTitleWidget extends StatelessWidget {
  final String intro;
  final String title;

  const PageTitleWidget({super.key, required this.intro, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          intro,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 12),
        DelayedDisplay(
          fadingDuration: const Duration(milliseconds: 1000),
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 120,
            child: AutoSizeText(
              title,
              wrapWords: false,
              maxLines: 2,
              minFontSize: 12,
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ),
        ),
      ],
    );
  }
}
