import 'dart:io';
import 'package:circuito/pages/settings/language_page.dart';
import 'package:circuito/pages/settings/privacy_policy_page.dart';
import 'package:circuito/widgets/divider.dart';
import 'package:circuito/widgets/page_title.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: body(colors),
    );
  }

  Widget body(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(height: 64),
            topBar(colors),
            const SizedBox(height: 32),
            TextButton(
              child: rowWidget(("edit_language".tr()), Icons.language_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LanguagePage(),
                  ),
                );
              },
            ),
            const DividerWidget(padding: 0, height: 32),
            TextButton(
              child: rowWidget(("rate_app".tr()), Icons.star),
              onPressed: () async {
                if (Platform.isAndroid) {
                  final Uri url =
                      Uri.parse('https://play.google.com/store/apps/details?id=com.filippefrulli.watch_next');
                  if (!await launchUrl(url)) {
                    throw Exception('Could not launch url');
                  }
                } else if (Platform.isIOS) {
                  final Uri url =
                      Uri.parse('https://apps.apple.com/de/app/watch-next-ai-movie-assistant/id6450368827?l=en');
                  if (!await launchUrl(url)) {
                    throw Exception('Could not launch url');
                  }
                }
              },
            ),
            TextButton(
              child: rowWidget(("share".tr()), Icons.share),
              onPressed: () {
                if (Platform.isAndroid) {
                  Share.share(
                      'Check out my app: https://play.google.com/store/apps/details?id=com.filippefrulli.watch_next');
                } else if (Platform.isIOS) {
                  Share.share(
                      'Check out my app: https://apps.apple.com/de/app/watch-next-ai-movie-assistant/id6450368827?l=en');
                }
              },
            ),
            const DividerWidget(padding: 0, height: 32),
            TextButton(
              child: rowWidget(("about".tr()), Icons.info),
              onPressed: () {
                showAboutDialog(
                  context: context,
                  children: [
                    Text(
                      'Circuito',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const DividerWidget(padding: 0, height: 16),
                  ],
                );
              },
            ),
            const DividerWidget(padding: 0, height: 16),
            TextButton(
              child: rowWidget(("privacy_policy".tr()), Icons.receipt),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacyPolicy(),
                  ),
                );
              },
            ),
            const DividerWidget(padding: 0, height: 16),
          ],
        ),
      ),
    );
  }

  Widget topBar(ColorScheme colors) {
    return Row(
      children: [
        PageTitleWidget(
          intro: '',
          title: 'settings'.tr(),
        ),
      ],
    );
  }

  Widget rowWidget(String text, IconData icon) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: Colors.black),
          const SizedBox(width: 16),
          Text(
            text,
            style: Theme.of(context).textTheme.displayMedium,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
