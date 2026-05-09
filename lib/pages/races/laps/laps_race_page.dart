import 'dart:async';
import 'dart:math';

import 'package:circuito/objects/lap_result.dart';
import 'package:circuito/pages/races/laps/laps_race_results_page.dart';
import 'package:circuito/services/race_timer_service.dart';
import 'package:circuito/utils/app_colors.dart';
import 'package:circuito/utils/database.dart';
import 'package:circuito/utils/transitions.dart';
import 'package:circuito/widgets/app_button.dart';
import 'package:circuito/widgets/page_title.dart';
import 'package:circuito/widgets/race_result_popup.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class _LapDelta {
  final int lapTimeMs;
  final int? diffVsPrevMs;   // null if first lap
  final int? diffVsIdealMs;  // null if no ideal time set
  final Color color;

  _LapDelta({
    required this.lapTimeMs,
    required this.diffVsPrevMs,
    required this.diffVsIdealMs,
    required this.color,
  });
}

class LapsRacePage extends StatefulWidget {
  final int idealTimeMs;
  final int raceId;

  const LapsRacePage({
    super.key,
    required this.idealTimeMs,
    required this.raceId,
  });

  @override
  State<LapsRacePage> createState() => _LapsRacePageState();
}

class _LapsRacePageState extends State<LapsRacePage> {
  bool started = false;

  int _fastestLapMs = 0;
  int _previousLapTimeMs = 0;
  _LapDelta? _currentDelta;
  Timer? _deltaTimer;

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
      service.racePageBuilder = (ctx) => LapsRacePage(
            idealTimeMs: widget.idealTimeMs,
            raceId: widget.raceId,
          );
      _loadStateFromDb();
    }
  }

  @override
  void dispose() {
    _deltaTimer?.cancel();
    RaceTimerService.instance.removeListener(_onServiceUpdate);
    RaceTimerService.instance.setRacePageVisible(false);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _loadStateFromDb() async {
    final lapResults = await DatabaseHelper.instance.getLapResultsByRaceId(widget.raceId);
    if (lapResults.isEmpty || !mounted) return;
    setState(() {
      _fastestLapMs = lapResults.map((l) => l.completionTime).reduce(min);
      _previousLapTimeMs = lapResults.last.completionTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return PopScope(
      canPop: !started,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('abandon_race_title'.tr()),
            content: Text('abandon_race_body'.tr()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('cancel'.tr()),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('abandon'.tr()),
              ),
            ],
          ),
        );
        if (confirmed == true && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: started ? AppColors.activeRaceBorder : null,
        body: Stack(
          children: [
            body(colors),
            if (_currentDelta != null)
              RaceResultPopup(
              primaryText: _formatTime(_currentDelta!.lapTimeMs),
              subtitle: _currentDelta!.diffVsPrevMs != null
                  ? _formatTimeDifference(_currentDelta!.diffVsPrevMs!)
                  : (_currentDelta!.diffVsIdealMs != null
                      ? _formatTimeDifference(_currentDelta!.diffVsIdealMs!)
                      : null),
              tertiaryText: _currentDelta!.diffVsPrevMs != null &&
                      _currentDelta!.diffVsIdealMs != null
                  ? 'ideal: ${_formatTimeDifference(_currentDelta!.diffVsIdealMs!)}'
                  : null,
              color: _currentDelta!.color,
            ),
          ],
        ),
      ),
    );
  }

  Widget body(ColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: started ? AppColors.activeRaceBorder : Colors.white,
          width: 12,
        ),
        borderRadius: BorderRadius.circular(55),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            topBar(colors),
            const SizedBox(height: 64),
            timerSection(colors),
            Expanded(child: Container()),
            lapCompletedButton(colors),
            endRaceButton(colors),
            startRaceButton(colors),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget topBar(ColorScheme colors) {
    final service = RaceTimerService.instance;
    final lapNumber = started ? service.lapCurrent : 1;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleWidget(
          intro: 'laps_race'.tr(),
          title: '${'lap'.tr()} $lapNumber',
        ),
      ],
    );
  }

  Widget timerSection(ColorScheme colors) {
    final service = RaceTimerService.instance;
    final ms = started ? service.lapCurrentTimeMs : 0;
    final minutes = ms ~/ (60 * 1000);
    final seconds = (ms % (60 * 1000)) ~/ 1000;
    final milliseconds = ms % 1000;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
                '${minutes.toString().padLeft(2, '0')}:',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: colors.onSurface,
                      fontSize: 70,
                    ),
              ),
              Text(
                '${seconds.toString().padLeft(2, '0')}.',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: colors.onSurface,
                      fontSize: 70,
                    ),
              ),
              Text(
                milliseconds.toString().padLeft(3, '0'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: colors.onSurface,
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
    if (!started) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppButton(
        label: 'lap_completed'.tr(),
        onPressed: () => _onLapComplete(),
      ),
    );
  }

  Widget endRaceButton(ColorScheme colors) {
    if (!started) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppButton(
        label: 'end_race'.tr(),
        backgroundColor: colors.error,
        textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
        onPressed: () => _showEndRaceConfirmation(colors),
      ),
    );
  }

  Future<void> _showEndRaceConfirmation(ColorScheme colors) async {
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
                  'end_race_confirmation'.tr(),
                  style: Theme.of(context).textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: colors.outline, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'cancel'.tr(),
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: colors.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _onEndRace();
                          },
                          child: Text(
                            'end_race'.tr(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                ),
                          ),
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

  Widget startRaceButton(ColorScheme colors) {
    if (started) return const SizedBox();
    return AppButton(
      label: 'start_race'.tr(),
      onPressed: () => setState(() {
        started = true;
        _startRace();
      }),
    );
  }

  // ── Race logic ──────────────────────────────────────────────────────────────

  void _startRace() {
    final service = RaceTimerService.instance;
    service.startLapsRace(
      raceId: widget.raceId,
      idealTimeMs: widget.idealTimeMs,
      pageBuilder: (ctx) => LapsRacePage(
        idealTimeMs: widget.idealTimeMs,
        raceId: widget.raceId,
      ),
    );
    service.setRacePageVisible(true);
  }

  Future<void> _onLapComplete() async {
    final service = RaceTimerService.instance;
    final completionTime = service.lapCurrentTimeMs;

    // Compute each diff independently
    final int? diffVsPrev =
        _previousLapTimeMs > 0 ? completionTime - _previousLapTimeMs : null;
    final int? diffVsIdeal =
        widget.idealTimeMs > 0 ? completionTime - widget.idealTimeMs : null;

    // Color is driven by vs-prev when available, falling back to vs-ideal
    final int? primaryDiff = diffVsPrev ?? diffVsIdeal;
    final isFastest = _fastestLapMs == 0 || completionTime < _fastestLapMs;
    final Color deltaColor;
    if (isFastest) {
      deltaColor = AppColors.lapFastest;
      _fastestLapMs = completionTime;
    } else if (primaryDiff != null && primaryDiff < 0) {
      deltaColor = AppColors.lapGain;
    } else {
      deltaColor = AppColors.lapLoss;
    }

    setState(() {
      _currentDelta = _LapDelta(
        lapTimeMs: completionTime,
        diffVsPrevMs: diffVsPrev,
        diffVsIdealMs: diffVsIdeal,
        color: deltaColor,
      );
    });
    _deltaTimer?.cancel();
    _deltaTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _currentDelta = null);
    });

    // Persist: store vs-ideal if set, else vs-prev, else 0
    final int timeDifference = diffVsIdeal ?? diffVsPrev ?? 0;
    await DatabaseHelper.instance.insertLapResult(
      LapResult(
        raceId: widget.raceId,
        lapNumber: service.lapCurrent,
        completionTime: completionTime,
        timeDifference: timeDifference,
        createdAt: DateTime.now().toIso8601String(),
      ),
    );

    _previousLapTimeMs = completionTime;
    service.advanceLap();
  }

  Future<void> _onEndRace() async {
    RaceTimerService.instance.stopLapsTimer();
    final lapResults = await DatabaseHelper.instance.getLapResultsByRaceId(widget.raceId);
    final int averageTime;
    final int fastestTime;
    if (lapResults.isEmpty) {
      averageTime = 0;
      fastestTime = 0;
    } else {
      final total = lapResults.fold(0, (sum, l) => sum + l.completionTime);
      averageTime = total ~/ lapResults.length;
      fastestTime = lapResults.map((l) => l.completionTime).reduce(min);
    }
    await DatabaseHelper.instance.endRace(widget.raceId);
    await DatabaseHelper.instance.insertRaceResult(
      widget.raceId,
      fastestTime,
      averageTime,
      null,
      null,
    );
    RaceTimerService.instance.clearRace();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        slideRoute(LapsRaceResultsPage(raceId: widget.raceId)),
      );
    }
  }

  String _formatTime(int milliseconds) {
    final minutes = milliseconds ~/ (60 * 1000);
    final seconds = (milliseconds % (60 * 1000)) ~/ 1000;
    final ms = milliseconds % 1000;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${ms.toString().padLeft(3, '0')}';
  }

  String _formatTimeDifference(int milliseconds) {
    final isNegative = milliseconds < 0;
    return '${isNegative ? '-' : '+'}${_formatTime(milliseconds.abs())}';
  }
}
