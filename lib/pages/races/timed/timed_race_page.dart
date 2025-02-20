import 'dart:async';

import 'package:circuito/objects/timed_challenge.dart';
import 'package:circuito/objects/timed_challenge_result.dart';
import 'package:circuito/objects/timed_race_section.dart';
import 'package:circuito/pages/races/timed/timed_race_results_page.dart';
import 'package:circuito/utils/database.dart';
import 'package:circuito/widgets/page_title.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class TimedRacePage extends StatefulWidget {
  final int id;

  const TimedRacePage({
    super.key,
    required this.id,
  });

  @override
  State<TimedRacePage> createState() => _TimedRacePageState();
}

class _TimedRacePageState extends State<TimedRacePage> {
  late List<TimedChallenge> _challenges;
  late TimedRaceSection _section;

  int _currentChallengeIndex = 0;
  int _totalElapsedTimeMs = 0;

  int _displayChallengeIndex = 0; // For UI display
  int _actualChallengeIndex = 0;

  bool started = false;
  bool isEnded = false;
  bool _isLoading = true;

  Timer? _timer;

  late int _currentTimeInMs;

  int minutes = 0;
  int seconds = 0;
  int milliseconds = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_challenges.isEmpty) {
      return Scaffold(
        body: Center(child: Text('no_challenges'.tr())),
      );
    }

    return Scaffold(
      body: body(colors, _section),
    );
  }

  Widget body(ColorScheme colors, TimedRaceSection section) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const SizedBox(height: 64),
          topBar(colors, section),
          const SizedBox(height: 32),
          timerSection(colors),
          const SizedBox(height: 32),
          nextChallengePreview(colors),
          Expanded(child: Container()),
          startRaceButton(colors),
          challengeCompletedButton(colors),
          endSectionButton(colors),
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
          intro: 'challenge'.tr(),
          title: '${_displayChallengeIndex + 1} / ${_challenges.length}',
        ),
      ],
    );
  }

  Widget timerSection(ColorScheme colors) {
    final isNegative = _currentTimeInMs < 0;
    return Container(
      padding: const EdgeInsets.all(64),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: colors.primary,
          width: 5,
        ),
      ),
      child: Column(
        children: [
          Text(
            '${isNegative ? '-' : ''}${minutes.abs().toString().padLeft(2, '0')}:',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: colors.primary,
                  fontSize: 70,
                ),
          ),
          Text(
            '${seconds.toString().padLeft(2, '0')}.',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: colors.primary,
                  fontSize: 70,
                ),
          ),
          Text(
            milliseconds.toString().padLeft(3, '0'),
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: colors.primary,
                  fontSize: 35,
                ),
          ),
        ],
      ),
    );
  }

  Widget nextChallengePreview(ColorScheme colors) {
    if (_currentChallengeIndex >= _challenges.length - 1) return Container();

    final nextChallenge = _challenges[_currentChallengeIndex + 1];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: colors.outline, width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            'next_challenge'.tr(),
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _formatTime(nextChallenge.completionTime!),
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 42,
                ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int milliseconds) {
    final minutes = milliseconds ~/ (60 * 1000);
    final seconds = (milliseconds % (60 * 1000)) ~/ 1000;
    final ms = milliseconds % 1000;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${ms.toString().padLeft(3, '0')}';
  }

  startRaceButton(ColorScheme colors) {
    return started
        ? Container()
        : Container(
            height: 60,
            width: MediaQuery.of(context).size.width - 96,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextButton(
              onPressed: () {
                setState(() {
                  started = !started;
                  if (started) {
                    startTimer();
                  }
                });
              },
              child: Text(
                'start_race'.tr(),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colors.onPrimary,
                    ),
              ),
            ),
          );
  }

  endSectionButton(ColorScheme colors) {
    return isEnded
        ? Container(
            height: 60,
            width: MediaQuery.of(context).size.width - 96,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => TimedRaceResultsPage(
                      raceId: widget.id,
                    ),
                  ),
                );
              },
              child: Text(
                'complete_section'.tr(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          )
        : Container();
  }

  challengeCompletedButton(ColorScheme colors) {
    return started && !isEnded
        ? Container(
            height: 60,
            width: MediaQuery.of(context).size.width - 96,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextButton(
              onPressed: started ? _onChallengeComplete : null,
              child: Text(
                'challenge_completed'.tr(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          )
        : Container();
  }

  void _onChallengeComplete() async {
    if (_displayChallengeIndex >= _challenges.length) return;

    // Save result for displayed challenge
    int previousChallengesTime = 0;
    for (int i = 0; i < _displayChallengeIndex; i++) {
      previousChallengesTime += _challenges[i].completionTime!;
    }

    int actualTime = _totalElapsedTimeMs - previousChallengesTime;
    int targetTime = _challenges[_displayChallengeIndex].completionTime!;

    final result = TimedChallengeResult(
      challengeId: _challenges[_displayChallengeIndex].id!,
      completionTime: actualTime,
      timeDifference: actualTime - targetTime,
      rank: _challenges[_displayChallengeIndex].rank!,
      timestamp: DateTime.now().toIso8601String(),
    );

    await DatabaseHelper.instance.insertTimedChallengeResult(result);

    setState(() {
      _displayChallengeIndex++;
      if (_displayChallengeIndex >= _challenges.length) {
        isEnded = true;
        _timer?.cancel();
      }
    });
  }

  Future<void> _loadData() async {
    _section = await DatabaseHelper.instance.getSectionById(widget.id);
    _challenges = await DatabaseHelper.instance.getChallengesBySectionId(widget.id);
    if (_challenges.isNotEmpty) {
      _currentTimeInMs = _challenges[0].completionTime!;
      _updateTimeDisplay();
    }
    setState(() => _isLoading = false);
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        _totalElapsedTimeMs += 10;
        _updateTimeDisplay();
      });
    });
  }

  void _updateTimeDisplay() {
    // Calculate elapsed time for current actual challenge
    int previousChallengesTime = 0;
    for (int i = 0; i < _actualChallengeIndex; i++) {
      previousChallengesTime += _challenges[i].completionTime!;
    }

    int currentChallengeElapsed = _totalElapsedTimeMs - previousChallengesTime;
    int currentTarget = _challenges[_actualChallengeIndex].completionTime!;

    _currentTimeInMs = currentTarget - currentChallengeElapsed;

    // Auto-advance actual challenge index when time hits 0
    if (_currentTimeInMs <= 0 && _actualChallengeIndex < _challenges.length - 1) {
      _actualChallengeIndex++;
      return;
    }

    // Update display time
    final timeAbs = _currentTimeInMs.abs();
    minutes = (timeAbs ~/ (60 * 1000));
    seconds = (timeAbs % (60 * 1000)) ~/ 1000;
    milliseconds = timeAbs % 1000;

    if (_currentTimeInMs < 0 && _actualChallengeIndex == _challenges.length - 1) {
      minutes = -minutes;
    }
  }
}
