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
          child: Text(
            title,
            style: Theme.of(context).textTheme.displayLarge,
          ),
        ),
      ],
    );
  }
}
