import 'package:circuito/objects/race.dart';
import 'package:circuito/pages/home_page.dart';
import 'package:circuito/pages/races/laps/laps_race_page.dart';
import 'package:circuito/utils/database.dart';
import 'package:circuito/widgets/page_title.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class EditLapsRacePage extends StatefulWidget {
  final int id;

  const EditLapsRacePage({
    super.key,
    required this.id,
  });

  @override
  State<EditLapsRacePage> createState() => _EditLapsRacePageState();
}

class _EditLapsRacePageState extends State<EditLapsRacePage> {
  late Future<Race> _raceFuture;

  int _minutes = 0;
  int _seconds = 0;
  int _milliseconds = 0;

  @override
  void initState() {
    super.initState();
    _raceFuture = _loadRace();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Race> _loadRace() async {
    try {
      final race = await DatabaseHelper.instance.getRaceById(widget.id);
      return race;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: FutureBuilder<Race>(
        future: _raceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final race = snapshot.data!;
          return body(colors, race);
        },
      ),
    );
  }

  Widget body(ColorScheme colors, Race race) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          topBar(colors, race),
          const SizedBox(height: 64),
          Text(
            'ideal_lap_time'.tr(),
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 16),
          timeInputSection(colors),
          Expanded(child: Container()),
          startRaceButton(colors),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget topBar(ColorScheme colors, Race race) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleWidget(
          intro: 'laps_race'.tr(),
          title: race.name,
          showBackButton: true,
        ),
        Expanded(child: Container()),
        deleteButton(colors, race),
      ],
    );
  }

  Widget deleteButton(ColorScheme colors, Race race) {
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
            Icons.delete_outlined,
            color: colors.secondary,
            size: 28,
          ),
          onPressed: () => _showDeleteConfirmation(context, colors, race),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, ColorScheme colors, Race race) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: colors.outline, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'delete_race_confirmation'.tr(),
                  style: Theme.of(context).textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(child: _cancelButton(colors)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: colors.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextButton(
                          child: Text(
                            'delete'.tr(),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          onPressed: () {
                            DatabaseHelper.instance.deleteRace(race.id!);
                            Navigator.of(context).pop();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const HomePage(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _cancelButton(ColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.outline, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      height: 50,
      child: TextButton(
        child: Text(
          'cancel'.tr(),
          style: Theme.of(context).textTheme.displaySmall,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget timeInputSection(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        border: Border.all(color: colors.outline, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _timeUnit(colors, _minutes, 59, (value) => setState(() => _minutes = value), 'min'),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              ':',
              style: TextStyle(color: colors.primary, fontSize: 32),
            ),
          ),
          _timeUnit(colors, _seconds, 59, (value) => setState(() => _seconds = value), 'sec'),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '.',
              style: TextStyle(color: colors.primary, fontSize: 32),
            ),
          ),
          _timeUnit(colors, _milliseconds, 999, (value) => setState(() => _milliseconds = value), 'ms'),
        ],
      ),
    );
  }

  Widget _timeUnit(ColorScheme colors, int value, int maxValue, Function(int) onChanged, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        NumberPicker(
          value: value,
          minValue: 0,
          maxValue: maxValue,
          itemCount: 1,
          itemHeight: 54,
          itemWidth: 54,
          axis: Axis.vertical,
          onChanged: onChanged,
          textStyle: TextStyle(color: colors.onSurface),
          selectedTextStyle: TextStyle(
            color: colors.primary,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: colors.primary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget startRaceButton(ColorScheme colors) {
    final idealTimeMs = (_minutes * 60 * 1000) + (_seconds * 1000) + _milliseconds;
    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width - 96,
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LapsRacePage(
              idealTimeMs: idealTimeMs,
              raceId: widget.id,
            ),
          ),
        ),
        child: Text(
          "go_to_race".tr(),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
