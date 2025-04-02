import 'dart:async';

import 'package:circuito/objects/lap_result.dart';
import 'package:circuito/pages/races/laps/laps_race_results_page.dart';
import 'package:circuito/utils/database.dart';
import 'package:circuito/widgets/page_title.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LapsRacePage extends StatefulWidget {
  final int laps;
  final int minutes;
  final int seconds;
  final int milliseconds;
  final int raceId;

  const LapsRacePage({
    super.key,
    required this.laps,
    required this.minutes,
    required this.seconds,
    required this.milliseconds,
    required this.raceId,
  });

  @override
  State<LapsRacePage> createState() => _LapsRacePageState();
}

class _LapsRacePageState extends State<LapsRacePage> {
  late int _minutes = widget.minutes;
  late int _seconds = widget.seconds;
  late int _milliseconds = widget.milliseconds;
  int _currentLap = 1;
  bool started = false;
  bool isEnded = false;

  Timer? _timer;
  late int _initialTimeInMs;
  late int _currentTimeInMs;

  @override
  void initState() {
    super.initState();
    _initialTimeInMs = _convertToMilliseconds(widget.minutes, widget.seconds, widget.milliseconds);
    _currentTimeInMs = _initialTimeInMs;
    _updateTimeDisplay();
  }

  @override
  void dispose() {
    _timer?.cancel();
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
          const SizedBox(height: 64),
          timerSection(colors),
          Expanded(child: Container()),
          lapCompletedButton(colors),
          const SizedBox(height: 32),
          startRaceButton(colors),
          endRaceButton(colors),
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
          intro: 'timed_race'.tr(),
          title: isEnded
              ? 'completed'.tr()
              : started
                  ? 'in_progress'.tr()
                  : 'ready'.tr(),
        ),
      ],
    );
  }

  Widget timerSection(ColorScheme colors) {
    final isNegative = _currentTimeInMs < 0;
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${'lap'.tr()} $_currentLap / ${widget.laps}',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
          ),
          const SizedBox(height: 32),
          Container(
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
                  '${isNegative ? '-' : ''}${_minutes.abs().toString().padLeft(2, '0')}:',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: isNegative ? colors.error : colors.onSurface,
                        fontSize: 70,
                      ),
                ),
                Text(
                  '${_seconds.toString().padLeft(2, '0')}.',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: isNegative ? colors.error : colors.onSurface,
                        fontSize: 70,
                      ),
                ),
                Text(
                  _milliseconds.toString().padLeft(3, '0'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: isNegative ? colors.error : colors.onSurface,
                        fontSize: 35,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  lapCompletedButton(ColorScheme colors) {
    return started && !isEnded
        ? Container(
            height: 60,
            width: MediaQuery.of(context).size.width - 96,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextButton(
              onPressed: started ? _onLapComplete : null,
              child: Text(
                'lap_completed'.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onPrimary,
                    ),
              ),
            ),
          )
        : Container();
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
                    _startTimer();
                  }
                });
              },
              child: Text(
                'start_race'.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onPrimary,
                    ),
              ),
            ),
          );
  }

  endRaceButton(ColorScheme colors) {
    return isEnded
        ? Container(
            height: 60,
            width: MediaQuery.of(context).size.width - 96,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextButton(
              onPressed: () async {
                final averageTime = await calculateAverageTime();
                final fastestLapTime = await calculateFastestLapTime();
                await DatabaseHelper.instance.endRace(widget.raceId);
                await DatabaseHelper.instance.insertRaceResult(
                  widget.raceId,
                  averageTime,
                  fastestLapTime,
                  null,
                );
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => LapsRaceResultsPage(
                      raceId: widget.raceId,
                    ),
                  ),
                );
              },
              child: Text(
                'end_race'.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onPrimary,
                    ),
              ),
            ),
          )
        : Container();
  }

  Future<int> calculateAverageTime() async {
    // Get all lap results for this race
    final lapResults = await DatabaseHelper.instance.getLapResultsByRaceId(widget.raceId);

    if (lapResults.isEmpty) {
      return 0;
    }

    // Calculate total completion time
    final totalCompletionTime = lapResults.fold(0, (sum, lap) => sum + lap.completionTime);

    // Calculate average lap time
    final averageLapTime = totalCompletionTime ~/ lapResults.length;

    return averageLapTime;
  }

  Future<int> calculateFastestLapTime() async {
    final lapResults = await DatabaseHelper.instance.getLapResultsByRaceId(widget.raceId);

    if (lapResults.isEmpty) {
      return 0;
    }

    // Find the lap with the smallest completion time
    int fastestLapTime = lapResults[0].completionTime;

    for (var lap in lapResults) {
      if (lap.completionTime < fastestLapTime) {
        fastestLapTime = lap.completionTime;
      }
    }

    return fastestLapTime;
  }

  int _convertToMilliseconds(int minutes, int seconds, int milliseconds) {
    return (minutes * 60 * 1000) + (seconds * 1000) + milliseconds;
  }

  void _updateTimeDisplay() {
    final timeAbs = _currentTimeInMs.abs();
    final isNegative = _currentTimeInMs < 0;

    _minutes = (timeAbs ~/ (60 * 1000));
    _seconds = (timeAbs % (60 * 1000)) ~/ 1000;
    _milliseconds = timeAbs % 1000;

    if (isNegative) {
      _minutes = -_minutes;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        _currentTimeInMs -= 10;
        _updateTimeDisplay();
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  int _calculateTimeDifference() {
    final elapsedTime = _initialTimeInMs - _currentTimeInMs;
    // If elapsed time is greater than initial time, return positive difference
    // If elapsed time is less than initial time, return negative difference
    return elapsedTime - _initialTimeInMs;
  }

  void _onLapComplete() {
    final timeDifference = _calculateTimeDifference();
    final completionTime = _initialTimeInMs - _currentTimeInMs;

    final lapResult = LapResult(
      raceId: widget.raceId,
      lapNumber: _currentLap,
      completionTime: completionTime,
      timeDifference: timeDifference,
      createdAt: DateTime.now().toIso8601String(),
    );

    DatabaseHelper.instance.insertLapResult(lapResult);

    setState(() {
      if (_currentLap < widget.laps) {
        _currentTimeInMs = _initialTimeInMs;
        _updateTimeDisplay();
        _currentLap++;
      } else {
        isEnded = true;
        _stopTimer();
      }
    });
  }
}
