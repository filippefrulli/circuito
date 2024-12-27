import 'dart:io';
import 'package:circuito/settings/language_page.dart';
import 'package:circuito/settings/privacy_policy_page.dart';
import 'package:circuito/widgets/divider.dart';
import 'package:circuito/widgets/page_title.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class CircuitsPage extends StatefulWidget {
  const CircuitsPage({super.key});

  @override
  State<CircuitsPage> createState() => _CircuitsPageState();
}

class _CircuitsPageState extends State<CircuitsPage> {
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
              intro: 'my_pl'.tr(),
              title: 'circuits'.tr(),
            ),
            const SizedBox(height: 32),
            carItem('Porsche 911 GT'),
          ],
        ),
      ),
    );
  }

  Widget carItem(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        child: Row(
          children: <Widget>[
            const SizedBox(width: 16),
            Text(
              name,
              style: Theme.of(context).textTheme.displayMedium,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
