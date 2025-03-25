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
        SafeArea(
          child: Container(),
        ),
        const SizedBox(height: 16),
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
