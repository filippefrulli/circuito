import 'package:circuito/utils/constants.dart';
import 'package:flutter/material.dart';

class PrivacyPolicy extends StatelessWidget {
  // constructor
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 64),
          child: Text(privacyPolicy, style: Theme.of(context).textTheme.displaySmall),
        ),
      ),
    );
  }
}
