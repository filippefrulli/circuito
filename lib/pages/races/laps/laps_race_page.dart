import 'package:circuito/objects/lap_result.dart';
import 'package:circuito/pages/races/laps/laps_race_results_page.dart';
import 'package:circuito/services/race_timer_service.dart';
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
  bool started = false;
  bool isEnded = false;

  @override
  void initState() {
    super.initState();
    RaceTimerService.instance.addListener(_onServiceUpdate);

    final service = RaceTimerService.instance;
    final isReconnecting = service.isRunning &&
        service.raceType == ActiveRaceType.laps &&
        service.raceId == widget.raceId;

    if (isReconnecting) {
      started = true;
      service.setRacePageVisible(true);
      // Refresh the page builder so the banner points to this instance.
      service.racePageBuilder = (ctx) => LapsRacePage(
            laps: widget.laps,
            minutes: widget.minutes,
            seconds: widget.seconds,
            milliseconds: widget.milliseconds,
            raceId: widget.raceId,
          );
    }
  }

  @override
  void dispose() {
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
    final service = RaceTimerService.instance;
    final ms = started ? service.lapCurrentTimeMs : _initialTimeMs;
    final isNegative = ms < 0;
    final abs = ms.abs();
    final minutes = abs ~/ (60 * 1000);
    final seconds = (abs % (60 * 1000)) ~/ 1000;
    final milliseconds = abs % 1000;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${'lap'.tr()} ${started ? service.lapCurrent : 1} / ${widget.laps}',
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
                '${isNegative ? '-' : ''}${minutes.abs().toString().padLeft(2, '0')}:',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: isNegative ? colors.error : colors.onSurface,
                      fontSize: 70,
                    ),
              ),
              Text(
                '${seconds.toString().padLeft(2, '0')}.',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: isNegative ? colors.error : colors.onSurface,
                      fontSize: 70,
                    ),
              ),
              Text(
                milliseconds.toString().padLeft(3, '0'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: isNegative ? colors.error : colors.onSurface,
                      fontSize: 35,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget lapCompletedButton(ColorScheme colors) {
    return started && !isEnded
        ? Container(
            height: 60,
            width: MediaQuery.of(context).size.width - 96,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextButton(
              onPressed: _onLapComplete,
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

  Widget startRaceButton(ColorScheme colors) {
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
                  started = true;
                  _startRace();
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

  Widget endRaceButton(ColorScheme colors) {
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
                  null,
                );
                RaceTimerService.instance.clearRace();
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) =>
                          LapsRaceResultsPage(raceId: widget.raceId),
                    ),
                  );
                }
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

  // ── Race logic ─────────────────────────────────────────────────────────────

  int get _initialTimeMs =>
      (widget.minutes * 60 * 1000) + (widget.seconds * 1000) + widget.milliseconds;

  void _startRace() {
    final service = RaceTimerService.instance;
    service.startLapsRace(
      raceId: widget.raceId,
      initialTimeMs: _initialTimeMs,
      totalLaps: widget.laps,
      pageBuilder: (ctx) => LapsRacePage(
        laps: widget.laps,
        minutes: widget.minutes,
        seconds: widget.seconds,
        milliseconds: widget.milliseconds,
        raceId: widget.raceId,
      ),
    );
    service.setRacePageVisible(true);
  }

  void _onLapComplete() {
    final service = RaceTimerService.instance;
    final completionTime = service.lapInitialTimeMs - service.lapCurrentTimeMs;
    final timeDifference = -service.lapCurrentTimeMs;

    DatabaseHelper.instance.insertLapResult(
      LapResult(
        raceId: widget.raceId,
        lapNumber: service.lapCurrent,
        completionTime: completionTime,
        timeDifference: timeDifference,
        createdAt: DateTime.now().toIso8601String(),
      ),
    );

    if (service.lapCurrent < widget.laps) {
      service.advanceLap();
    } else {
      service.stopLapsTimer();
      setState(() => isEnded = true);
    }
  }

  Future<int> calculateAverageTime() async {
    final lapResults =
        await DatabaseHelper.instance.getLapResultsByRaceId(widget.raceId);
    if (lapResults.isEmpty) return 0;
    final total =
        lapResults.fold(0, (sum, lap) => sum + lap.completionTime);
    return total ~/ lapResults.length;
  }

  Future<int> calculateFastestLapTime() async {
    final lapResults =
        await DatabaseHelper.instance.getLapResultsByRaceId(widget.raceId);
    if (lapResults.isEmpty) return 0;
    return lapResults
        .map((l) => l.completionTime)
        .reduce((a, b) => a < b ? a : b);
  }
}
