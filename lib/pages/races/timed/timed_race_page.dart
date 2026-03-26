import 'dart:async';

import 'package:circuito/objects/timed_challenge.dart';
import 'package:circuito/objects/timed_challenge_result.dart';
import 'package:circuito/objects/timed_race_section.dart';
import 'package:circuito/pages/races/timed/timed_race_results_page.dart';
import 'package:circuito/services/race_timer_service.dart';
import 'package:circuito/utils/database.dart';
import 'package:circuito/widgets/page_title.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class TimedRacePage extends StatefulWidget {
  final int sectionId;
  final int raceId;

  const TimedRacePage({
    super.key,
    required this.sectionId,
    required this.raceId,
  });

  @override
  State<TimedRacePage> createState() => _TimedRacePageState();
}

class _TimedRacePageState extends State<TimedRacePage> {
  late List<TimedChallenge> _challenges;
  late TimedRaceSection _section;

  bool started = false;
  bool isEnded = false;
  bool _isLoading = true;

  int? _resultDiffMs;
  Timer? _resultTimer;

  @override
  void initState() {
    super.initState();
    RaceTimerService.instance.addListener(_onServiceUpdate);
    _loadData();
  }

  @override
  void dispose() {
    _resultTimer?.cancel();
    RaceTimerService.instance.removeListener(_onServiceUpdate);
    // Let the timer keep running; only hide the overlay flag.
    RaceTimerService.instance.setRacePageVisible(false);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_challenges.isEmpty) {
      return Scaffold(body: Center(child: Text('no_challenges'.tr())));
    }

    return Scaffold(
      body: Stack(
        children: [
          body(colors, _section),
          if (_resultDiffMs != null) _resultPopup(_resultDiffMs!),
        ],
      ),
    );
  }

  Widget body(ColorScheme colors, TimedRaceSection section) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: started && !isEnded ? Colors.green[800]! : Colors.white,
          width: 12,
        ),
        borderRadius: BorderRadius.circular(55),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            topBar(colors),
            MediaQuery.of(context).size.height < 670
                ? Container()
                : Expanded(child: Container()),
            timerSection(colors),
            MediaQuery.of(context).size.height < 670
                ? Container()
                : Expanded(child: Container()),
            nextChallengePreview(colors),
            const SizedBox(height: 64),
            startRaceButton(colors),
            challengeCompletedButton(colors),
            endSectionButton(colors),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget topBar(ColorScheme colors) {
    final service = RaceTimerService.instance;
    final displayIndex = started ? service.timedDisplayIndex : 0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleWidget(
          intro: 'challenge'.tr(),
          title: '${displayIndex + 1} / ${_challenges.length}',
        ),
      ],
    );
  }

  Widget timerSection(ColorScheme colors) {
    final service = RaceTimerService.instance;
    final ms = started ? service.timedCurrentMs : _challenges[0].completionTime!;
    final isNegative = ms < 0;
    final abs = ms.abs();
    final minutes = abs ~/ (60 * 1000);
    final seconds = (abs % (60 * 1000)) ~/ 1000;
    final milliseconds = abs % 1000;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${isNegative ? '-' : ''}${minutes.abs().toString().padLeft(2, '0')}:',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: colors.primary,
                fontSize: 66,
              ),
        ),
        Text(
          '${seconds.toString().padLeft(2, '0')}.',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: colors.primary,
                fontSize: 66,
              ),
        ),
        Text(
          milliseconds.toString().padLeft(3, '0'),
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: colors.primary,
                fontSize: 24,
              ),
        ),
      ],
    );
  }

  Widget nextChallengePreview(ColorScheme colors) {
    final service = RaceTimerService.instance;
    final displayIndex = started ? service.timedDisplayIndex : 0;
    if (displayIndex >= _challenges.length - 1) return Container();
    final nextChallenge = _challenges[displayIndex + 1];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: colors.outline, width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            '${'next_challenge'.tr()}: #${displayIndex + 2}',
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

  Widget startRaceButton(ColorScheme colors) {
    return started
        ? Container()
        : Container(
            height: 60,
            width: MediaQuery.of(context).size.width - 96,
            decoration: BoxDecoration(
              color: Colors.green[800],
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextButton(
              onPressed: () {
                setState(() {
                  started = true;
                  _startTimer();
                });
              },
              child: Text(
                'START',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          );
  }

  Widget endSectionButton(ColorScheme colors) {
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
                final results = await _calculateSectionResults();
                await DatabaseHelper.instance.markSectionAsCompleted(
                  widget.sectionId,
                  widget.raceId,
                  timeDifference: results['timeDifference'],
                );
                RaceTimerService.instance.clearRace();
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) =>
                          TimedRaceResultsPage(raceId: widget.raceId),
                    ),
                  );
                }
              },
              child: Text(
                'complete_section'.tr(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          )
        : Container();
  }

  Widget challengeCompletedButton(ColorScheme colors) {
    return started && !isEnded
        ? Container(
            height: 60,
            width: MediaQuery.of(context).size.width - 96,
            decoration: BoxDecoration(
              color: colors.error,
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextButton(
              onPressed: _onChallengeComplete,
              child: Text(
                'STOP',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          )
        : Container();
  }

  Widget _resultPopup(int diffMs) {
    final isOver = diffMs > 0;
    final abs = diffMs.abs();
    final m = abs ~/ (60 * 1000);
    final s = (abs % (60 * 1000)) ~/ 1000;
    final ms = abs % 1000;
    final sign = isOver ? '+' : '-';
    final timeStr =
        '$sign${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}.${ms.toString().padLeft(3, '0')}';
    final color = isOver ? Colors.red[700]! : Colors.green[700]!;

    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color, width: 3),
            ),
            child: Text(
              timeStr,
              style: TextStyle(
                color: color,
                fontSize: 52,
                fontWeight: FontWeight.bold,
                fontFamily: 'Raleway',
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showResultFor(int diffMs) {
    _resultTimer?.cancel();
    setState(() => _resultDiffMs = diffMs);
    _resultTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _resultDiffMs = null);
    });
  }

  // ── Race logic ─────────────────────────────────────────────────────────────

  Future<void> _loadData() async {
    _section = await DatabaseHelper.instance.getSectionById(widget.sectionId);
    _challenges =
        await DatabaseHelper.instance.getChallengesBySectionId(widget.sectionId);

    final service = RaceTimerService.instance;
    final isReconnecting = service.isRunning &&
        service.raceType == ActiveRaceType.timed &&
        service.raceId == widget.raceId;

    if (isReconnecting) {
      started = true;
      service.setRacePageVisible(true);
      // Refresh the page builder so the banner points to this instance.
      service.racePageBuilder =
          (ctx) => TimedRacePage(sectionId: widget.sectionId, raceId: widget.raceId);
    }

    setState(() => _isLoading = false);
  }

  void _startTimer() {
    final service = RaceTimerService.instance;
    service.startTimedRace(
      raceId: widget.raceId,
      sectionId: widget.sectionId,
      challenges: _challenges,
      pageBuilder: (ctx) =>
          TimedRacePage(sectionId: widget.sectionId, raceId: widget.raceId),
    );
    service.setRacePageVisible(true);
  }

  void _onChallengeComplete() async {
    final service = RaceTimerService.instance;
    final challengeIdx = service.timedDisplayIndex;
    if (challengeIdx >= _challenges.length) return;

    int previousChallengesTime = 0;
    for (int i = 0; i < challengeIdx; i++) {
      previousChallengesTime += _challenges[i].completionTime!;
    }

    final actualTime = service.timedElapsedMs - previousChallengesTime;
    final targetTime = _challenges[challengeIdx].completionTime!;

    final timeDifference = actualTime - targetTime;

    await DatabaseHelper.instance.insertTimedChallengeResult(
      TimedChallengeResult(
        challengeId: _challenges[challengeIdx].id!,
        completionTime: actualTime,
        timeDifference: timeDifference,
        rank: _challenges[challengeIdx].rank!,
        createdAt: DateTime.now().toIso8601String(),
      ),
    );

    _showResultFor(timeDifference);

    if (challengeIdx < _challenges.length - 1) {
      service.advanceTimedChallenge();
    } else {
      service.stopTimedTimer();
      setState(() => isEnded = true);
    }
  }

  Future<Map<String, int>> _calculateSectionResults() async {
    List<TimedChallengeResult> allResults = [];
    for (var challenge in _challenges) {
      final results = await DatabaseHelper.instance
          .getTimedChallengeResultByChallengeId(challenge.id!);
      if (results.isNotEmpty) allResults.add(results.first);
    }
    final totalTarget =
        _challenges.fold(0, (sum, c) => sum + c.completionTime!);
    final totalActual =
        allResults.fold(0, (sum, r) => sum + r.completionTime);
    final totalDiff =
        allResults.fold(0, (sum, r) => sum + r.timeDifference.abs());
    return {
      'targetTime': totalTarget,
      'actualTime': totalActual,
      'timeDifference': totalDiff,
    };
  }
}
