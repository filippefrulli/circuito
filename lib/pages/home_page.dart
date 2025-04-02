import 'package:circuito/objects/race.dart';
import 'package:circuito/pages/completed_races_page.dart';
import 'package:circuito/pages/races/create_race_page.dart';
import 'package:circuito/pages/races/laps/edit_laps_race_page.dart';
import 'package:circuito/pages/races/timed/edit_timed_race_page.dart';
import 'package:circuito/pages/settings/settings_page.dart';
import 'package:circuito/utils/database.dart';
import 'package:circuito/widgets/page_title.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Race>> _incompletedRacesFuture;

  @override
  void initState() {
    super.initState();
    _incompletedRacesFuture = DatabaseHelper.instance.getIncompleteRaces();
  }

  @override
  void dispose() {
    super.dispose();
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
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          topBar(colors),
          MediaQuery.of(context).size.height < 670 ? const SizedBox(height: 32) : const SizedBox(height: 64),
          middleButtons(colors),
          const SizedBox(height: 24),
          completedRacesButton(colors),
          const SizedBox(height: 24),
          incompleteRacesList(colors),
          Expanded(
            child: Container(),
          ),
          newRaceButton(colors),
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
          intro: ''.tr(),
          title: 'welcome'.tr(),
        ),
        settingsButton(colors),
      ],
    );
  }

  Widget settingsButton(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(top: 64),
      child: Container(
        width: 46,
        height: 46,
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

  Widget completedRacesButton(ColorScheme colors) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CompletedRacesPage(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 70,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: colors.primary,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(
              'my_races'.tr(),
              style: Theme.of(context).textTheme.displayMedium,
            ),
            Expanded(
              child: Container(),
            ),
            Icon(
              Icons.chevron_right,
              color: colors.primary,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }

  Widget incompleteRacesList(ColorScheme colors) {
    return FutureBuilder<List<Race>>(
      future: _incompletedRacesFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox();
        }

        return Container(
          height: MediaQuery.of(context).size.height < 670 ? 200 : 240,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...snapshot.data!.map(
                  (race) => SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                race.type == 2 ? EditLapsRacePage(id: race.id!) : EditTimedRacePage(id: race.id!),
                          ),
                        );
                        _refreshIncompleteRaces();
                      },
                      child: incompleteRaceItem(colors, race),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget incompleteRaceItem(ColorScheme colors, Race race) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: colors.primary,
          width: 2,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'in_progress'.tr(),
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Colors.green[600],
                ),
          ),
          Row(
            children: [
              Text(
                race.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Expanded(
                child: Container(),
              ),
              Icon(
                Icons.chevron_right,
                color: colors.primary,
                size: 32,
              ),
            ],
          ),
        ],
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
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateRacePage(),
            ),
          );
          _refreshIncompleteRaces();
        },
        child: Text(
          "new_race".tr(),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  void _refreshIncompleteRaces() {
    setState(() {
      _incompletedRacesFuture = DatabaseHelper.instance.getIncompleteRaces();
    });
  }
}
