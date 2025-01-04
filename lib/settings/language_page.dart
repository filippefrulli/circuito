import 'package:circuito/home_page.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  static List<String> languages = [
    'English',
    'Italiano',
  ];

  static List<String> lang = ['en', 'it'];

  static List<String> regions = ['US', 'IT'];

  int selected = 42;

  double opacity = 1.0;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body(),
    );
  }

  Widget body() {
    return Column(
      children: [
        const SizedBox(height: 48),
        Text(
          'Select your language',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayLarge,
        ),
        Expanded(
          child: Container(),
        ),
        languageList(),
        Expanded(
          child: Container(),
        ),
        Expanded(
          child: Container(),
        ),
        nextButton(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget languageList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
        height: 130,
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: ListView.builder(
            itemCount: languages.length,
            itemBuilder: (context, index) {
              return _listTile(languages[index], lang[index], regions[index], index);
            },
          ),
        ),
      ),
    );
  }

  Widget _listTile(String language, String lang, String region, int index) {
    return TextButton(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _text(language, index),
          const SizedBox(height: 6),
          Container(height: 1, color: Colors.grey[600]),
        ],
      ),
      onPressed: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (mounted) {
          context.setLocale(Locale(lang, region));

          prefs.setInt('language_number', index);
          prefs.setString('lang', '$lang-$region');

          setState(() {
            selected = index;
          });
        }
      },
    );
  }

  Widget _text(String language, int index) {
    if (selected == index) {
      return Text(
        language,
        style: Theme.of(context).textTheme.displayMedium,
      );
    } else {
      return Text(
        language,
        style: Theme.of(context).textTheme.labelMedium,
      );
    }
  }

  Widget nextButton() {
    if (selected < 10) {
      return DelayedDisplay(
        delay: const Duration(milliseconds: 100),
        child: Container(
          width: 200,
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(25),
          ),
          child: TextButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              bool seen = prefs.getBool('skip_intro') ?? false;
              if (mounted && seen) {
                Navigator.of(context).pop();
              } else if (mounted && !seen) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ),
                );
              }
            },
            child: Text(
              "done".tr(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    } else {
      return Container(
        height: 70,
      );
    }
  }
}
