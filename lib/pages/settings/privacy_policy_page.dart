import 'package:circuito/utils/constants.dart';
import 'package:flutter/material.dart';

class PrivacyPolicy extends StatelessWidget {
  // constructor
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 8, top: topPadding + 4),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(Icons.chevron_left, size: 32),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Text(privacyPolicy, style: Theme.of(context).textTheme.displaySmall),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
