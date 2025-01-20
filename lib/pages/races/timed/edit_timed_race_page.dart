import 'package:circuito/objects/race.dart';
import 'package:circuito/pages/races/timed/timed_race_page.dart';
import 'package:circuito/utils/database.dart';
import 'package:circuito/widgets/page_title.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class EditTimedRacePage extends StatefulWidget {
  final int id;

  const EditTimedRacePage({
    super.key,
    required this.id,
  });

  @override
  State<EditTimedRacePage> createState() => _EditTimedRacePageState();
}

class _EditTimedRacePageState extends State<EditTimedRacePage> {
  late Future<Race> _raceFuture;
  int _laps = 10;

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
          const SizedBox(height: 64),
          topBar(colors, race),
          const SizedBox(height: 64),
          Text(
            'number_of_laps'.tr(),
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 16),
          numberOfLaps(colors),
          const SizedBox(height: 64),
          Text(
            'lap_time'.tr(),
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 16),
          timeInputSection(colors),
          Expanded(child: Container()),
          startRaceButton(colors, _laps, _minutes, _seconds, _milliseconds),
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
          intro: 'timed_race'.tr(),
          title: race.name,
        ),
      ],
    );
  }

  Widget numberOfLaps(ColorScheme colors) {
    return Container(
      height: 54,
      width: 110,
      decoration: BoxDecoration(
        border: Border.all(color: colors.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: NumberPicker(
          value: _laps,
          minValue: 1,
          maxValue: 200,
          itemHeight: 54,
          itemCount: 1,
          onChanged: (value) => setState(() => _laps = value),
          textStyle: Theme.of(context).textTheme.displayMedium,
          selectedTextStyle: Theme.of(context).textTheme.displayMedium),
    );
  }

  Widget timeInputSection(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        border: Border.all(color: colors.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _timeUnit(colors, _minutes, 59, (value) => setState(() => _minutes = value), 'min'),
          Text(':', style: TextStyle(color: colors.primary, fontSize: 24)),
          _timeUnit(colors, _seconds, 59, (value) => setState(() => _seconds = value), 'sec'),
          Text('.', style: TextStyle(color: colors.primary, fontSize: 24)),
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
            fontSize: 20,
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

  Widget startRaceButton(ColorScheme colors, int laps, int minutes, int seconds, int milliseconds) {
    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width - 96,
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextButton(
        onPressed: () => {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TimedRacePage(
                  laps: laps, minutes: minutes, seconds: seconds, milliseconds: milliseconds, raceId: widget.id),
            ),
          ),
        },
        child: Text(
          "go_to_race".tr(),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
