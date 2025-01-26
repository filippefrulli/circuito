import 'package:circuito/objects/timed_challenge.dart';
import 'package:circuito/objects/timed_race_section.dart';
import 'package:circuito/pages/races/timed/timed_race_page.dart';
import 'package:circuito/utils/database.dart';
import 'package:circuito/widgets/page_title.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class EditTimedRaceSectionPage extends StatefulWidget {
  final int id;

  const EditTimedRaceSectionPage({
    super.key,
    required this.id,
  });

  @override
  State<EditTimedRaceSectionPage> createState() => _EditTimedRaceSectionPageState();
}

class _EditTimedRaceSectionPageState extends State<EditTimedRaceSectionPage> {
  late Future<List<TimedChallenge>> _challengesFuture;
  late Future<TimedRaceSection> _sectionFuture;

  int _newMinutes = 0;
  int _newSeconds = 0;
  int _newMilliseconds = 0;

  final TextEditingController _rankController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadChallenges();
    _sectionFuture = DatabaseHelper.instance.getSectionById(widget.id);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadChallenges() {
    _challengesFuture = DatabaseHelper.instance.getChallengesBySectionId(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: FutureBuilder<TimedRaceSection>(
        future: _sectionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final section = snapshot.data!;
          return body(colors, section);
        },
      ),
    );
  }

  Widget body(ColorScheme colors, TimedRaceSection section) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const SizedBox(height: 64),
          topBar(colors, section),
          const SizedBox(height: 64),
          challengesSection(colors),
          Expanded(child: Container()),
          startSectionButton(colors),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget topBar(ColorScheme colors, TimedRaceSection section) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleWidget(
          intro: 'section'.tr(),
          title: section.name,
        ),
      ],
    );
  }

  Widget challengesSection(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'timed_challenges'.tr(),
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<TimedChallenge>>(
          future: _challengesFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox();

            return Column(
              children: [
                challengeListWidget(colors, snapshot.data!),
                const SizedBox(height: 16),
                addChallengeWidget(colors),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget challengeListWidget(ColorScheme colors, List<TimedChallenge> data) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        border: Border.all(color: colors.outline, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ReorderableListView.builder(
        padding: EdgeInsets.zero,
        itemCount: data.length,
        onReorder: (oldIndex, newIndex) async {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          setState(() {
            final item = data.removeAt(oldIndex);
            data.insert(newIndex, item);
          });

          await DatabaseHelper.instance.updateChallengeRanks(data);
        },
        itemBuilder: (context, index) {
          final challenge = data[index];
          return ListTile(
            key: ValueKey(challenge.id),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${challenge.rank}.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  _formatTime(challenge.completionTime!),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            trailing: ReorderableDragStartListener(
              index: index,
              child: Icon(Icons.drag_handle, color: colors.primary),
            ),
          );
        },
      ),
    );
  }

  Widget addChallengeWidget(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: colors.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _timeUnit(colors, _newMinutes, 59, (val) => setState(() => _newMinutes = val), 'min'),
          Text(':', style: TextStyle(color: colors.primary)),
          _timeUnit(colors, _newSeconds, 59, (val) => setState(() => _newSeconds = val), 'sec'),
          Text(':', style: TextStyle(color: colors.primary)),
          _timeUnit(colors, _newMilliseconds, 999, (val) => setState(() => _newMilliseconds = val), 'ms'),
          Expanded(child: Container()),
          plusButton(colors),
        ],
      ),
    );
  }

  Widget plusButton(ColorScheme colors) {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: IconButton(
        onPressed: () async {
          final time = (_newMinutes * 60 * 1000) + (_newSeconds * 1000) + _newMilliseconds;
          final challenge = TimedChallenge(
            sectionId: widget.id,
            completionTime: time,
          );
          await DatabaseHelper.instance.insertTimedChallenge(challenge);
          setState(() {
            _loadChallenges();
            _rankController.clear();
            _newMinutes = 0;
            _newSeconds = 0;
            _newMilliseconds = 0;
          });
        },
        icon: Icon(Icons.add, color: colors.secondary, size: 32),
      ),
    );
  }

  String _formatTime(int milliseconds) {
    final minutes = milliseconds ~/ (60 * 1000);
    final seconds = (milliseconds % (60 * 1000)) ~/ 1000;
    final ms = milliseconds % 1000;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${ms.toString().padLeft(3, '0')}';
  }

  Widget _timeUnit(ColorScheme colors, int value, int maxValue, ValueChanged<int> onChanged, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 4),
        SizedBox(
          width: 60,
          height: 50,
          child: NumberPicker(
            value: value,
            minValue: 0,
            maxValue: maxValue,
            itemCount: 1,
            itemHeight: 54,
            itemWidth: 60,
            axis: Axis.vertical,
            onChanged: onChanged,
            textStyle: TextStyle(
              color: colors.onSurface,
              fontSize: 20,
            ),
            selectedTextStyle: TextStyle(
              color: colors.primary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
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

  Widget startSectionButton(ColorScheme colors) {
    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width - 96,
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextButton(
        onPressed: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TimedRacePage(
                id: widget.id,
              ),
            ),
          )
        },
        child: Text(
          "start_race".tr(),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
