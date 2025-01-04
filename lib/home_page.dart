import 'package:circuito/settings/settings_page.dart';
import 'package:circuito/widgets/page_title.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  int isContinue = 0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: body(colors),
    );
  }

  Widget body(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const SizedBox(height: 64),
          topBar(colors),
          Expanded(
            child: Container(),
          ),
          middleButtons(colors),
          const SizedBox(height: 24),
          racesButton(colors),
          Expanded(
            child: Container(),
          ),
          isContinue == 1 ? continueRaceButton(colors) : newRaceButton(colors),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget topBar(ColorScheme colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleWidget(
          intro: 'welcome'.tr(),
          title: 'Pippo',
        ),
        Expanded(
          child: Container(),
        ),
        settingsButton(colors),
      ],
    );
  }

  Widget settingsButton(ColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(25),
      ),
      child: IconButton(
        icon: Icon(
          Icons.settings,
          color: colors.secondary,
          size: 28,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SettingsPage(),
            ),
          );
        },
      ),
    );
  }

  middleButtons(ColorScheme colors) {
    return Row(
      children: [
        centerButton(colors, Icons.car_rental, 'my_garage'.tr(), '/garage'),
        const SizedBox(
          width: 24,
        ),
        centerButton(colors, Icons.home, 'my_circuits'.tr(), '/circuits'),
      ],
    );
  }

  Widget centerButton(ColorScheme colors, IconData icon, String text, String route) {
    return Container(
      height: (MediaQuery.of(context).size.width / 2) - 82,
      width: (MediaQuery.of(context).size.width / 2) - 44,
      decoration: BoxDecoration(
        border: Border.all(
          color: colors.primary,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextButton(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Expanded(
              child: Container(),
            ),
            Icon(
              icon,
              color: colors.primary,
              size: 32,
            ),
            Expanded(
              child: Container(),
            ),
            Text(
              text,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
          ],
        ),
        onPressed: () {
          Navigator.pushNamed(
            context,
            route,
          );
        },
      ),
    );
  }

  Widget racesButton(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(4),
      height: 260,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: colors.primary,
          width: 2,
        ),
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: TextButton(
          onPressed: () => {},
          child: Text(
            'my_races'.tr(),
            style: Theme.of(context).textTheme.displayMedium,
          ),
        ),
      ),
    );
  }

  Widget newRaceButton(ColorScheme colors) {
    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width - 96,
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextButton(
        onPressed: () => {
          setState(() {
            isContinue = 1;
          })
        },
        child: Text(
          "new_race".tr(),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget continueRaceButton(ColorScheme colors) {
    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width - 96,
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextButton(
        onPressed: () => {
          setState(() {
            isContinue = 0;
          })
        },
        child: Text(
          "continue_race".tr(),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
