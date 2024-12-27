import 'dart:io';
import 'package:circuito/settings/language_page.dart';
import 'package:circuito/settings/privacy_policy_page.dart';
import 'package:circuito/widgets/divider.dart';
import 'package:circuito/widgets/page_title.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class GaragePage extends StatefulWidget {
  const GaragePage({super.key});

  @override
  State<GaragePage> createState() => _GaragePageState();
}

class _GaragePageState extends State<GaragePage> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pageBody(),
    );
  }

  Widget pageBody() {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(height: 64),
            PageTitleWidget(
              intro: 'my_sg'.tr(),
              title: 'garage'.tr(),
            ),
            const SizedBox(height: 32),
            carItem(colors, 'Porsche 911 GT', 1997, 'assets/images/porsche.png'),
            carItem(colors, 'Porsche 911 GT', 1997, 'assets/images/porsche.png'),
          ],
        ),
      ),
    );
  }

  Widget carItem(ColorScheme colors, String name, int year, String image) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: colors.primary, width: 2),
          borderRadius: const BorderRadius.all(Radius.circular(25)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  name,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  year.toString(),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
            Expanded(
              child: Container(),
            ),
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                border: Border.all(color: colors.primary, width: 1),
                borderRadius: const BorderRadius.all(Radius.circular(15.0)),
              ),
              child: Container(
                  //Image.asset(image, width: 100, height: 100),)
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
