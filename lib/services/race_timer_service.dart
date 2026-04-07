import 'dart:async';

import 'package:circuito/objects/timed_challenge.dart';
import 'package:flutter/widgets.dart';

enum ActiveRaceType { laps, timed }

/// Singleton service that owns the race timer so it survives navigation.
class RaceTimerService extends ChangeNotifier {
  static final RaceTimerService instance = RaceTimerService._();
  RaceTimerService._();

  Timer? _timer;
  bool _racePageVisible = false;

  DateTime? _lapAnchor;    // Wall-clock start of the current lap
  DateTime? _timedAnchor;  // Wall-clock start of the timed race

  ActiveRaceType? raceType;
  int? raceId;

  /// Builder used by the banner to navigate back to the race page.
  WidgetBuilder? racePageBuilder;

  // ── Laps race state ───────────────────────────────────────────────────────
  int lapCurrentTimeMs = 0;
  int lapIdealTimeMs = 0;
  int lapCurrent = 1;

  // ── Timed race state ──────────────────────────────────────────────────────
  int timedElapsedMs = 0;
  int timedSectionId = 0;
  List<TimedChallenge> timedChallenges = [];
  int timedDisplayIndex = 0;
  int timedActualIndex = 0;

  /// Countdown ms for the current challenge (can be negative = overtime).
  int timedCurrentMs = 0;

  // ── Public API ────────────────────────────────────────────────────────────

  bool get isRunning => _timer?.isActive == true;
  bool get isRacePageVisible => _racePageVisible;

  void setRacePageVisible(bool visible) {
    if (_racePageVisible == visible) return;
    _racePageVisible = visible;
    // Defer notification so this is safe to call from initState / build.
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
  }

  void startLapsRace({
    required int raceId,
    required int idealTimeMs,
    required WidgetBuilder pageBuilder,
  }) {
    _stopTimer();
    raceType = ActiveRaceType.laps;
    this.raceId = raceId;
    lapIdealTimeMs = idealTimeMs;
    lapCurrent = 1;
    lapCurrentTimeMs = 0;
    _lapAnchor = DateTime.now();
    racePageBuilder = pageBuilder;
    _startTimer();
    notifyListeners();
  }

  void startTimedRace({
    required int raceId,
    required int sectionId,
    required List<TimedChallenge> challenges,
    required WidgetBuilder pageBuilder,
  }) {
    _stopTimer();
    raceType = ActiveRaceType.timed;
    this.raceId = raceId;
    timedSectionId = sectionId;
    timedChallenges = challenges;
    timedElapsedMs = 0;
    timedDisplayIndex = 0;
    timedActualIndex = 0;
    _timedAnchor = DateTime.now();
    racePageBuilder = pageBuilder;
    _computeTimedDisplay();
    _startTimer();
    notifyListeners();
  }

  /// Called by LapsRacePage when a lap completes.
  void advanceLap() {
    lapCurrent++;
    lapCurrentTimeMs = 0;
    _lapAnchor = DateTime.now();
    notifyListeners();
  }

  /// Called by LapsRacePage when the final lap completes.
  void stopLapsTimer() {
    _stopTimer();
    notifyListeners();
  }

  /// Called by TimedRacePage when a challenge completes (not the final one).
  void advanceTimedChallenge() {
    timedDisplayIndex++;
    notifyListeners();
  }

  /// Called by TimedRacePage when the final challenge completes.
  void stopTimedTimer() {
    _stopTimer();
    notifyListeners();
  }

  /// Full reset — call when the race is officially saved and navigation
  /// leaves the race flow entirely.
  void clearRace() {
    _stopTimer();
    raceType = null;
    raceId = null;
    racePageBuilder = null;
    _racePageVisible = false;
    _lapAnchor = null;
    _timedAnchor = null;
    notifyListeners();
  }

  // ── Display helpers ───────────────────────────────────────────────────────

  String get displayTimeString {
    final ms = raceType == ActiveRaceType.laps ? lapCurrentTimeMs : timedCurrentMs;
    return _formatMs(ms);
  }

  String get displayLabel {
    if (raceType == ActiveRaceType.laps) return 'Lap $lapCurrent';
    if (raceType == ActiveRaceType.timed) {
      return 'Challenge ${timedDisplayIndex + 1}/${timedChallenges.length}';
    }
    return '';
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 10), (_) => _tick());
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _tick() {
    if (raceType == ActiveRaceType.laps && _lapAnchor != null) {
      lapCurrentTimeMs = DateTime.now().difference(_lapAnchor!).inMilliseconds;
    } else if (raceType == ActiveRaceType.timed && _timedAnchor != null) {
      timedElapsedMs = DateTime.now().difference(_timedAnchor!).inMilliseconds;
      _computeTimedDisplay();
    }
    notifyListeners();
  }

  void _computeTimedDisplay() {
    if (timedChallenges.isEmpty) return;
    int prev = 0;
    for (int i = 0; i < timedActualIndex; i++) {
      prev += timedChallenges[i].completionTime!;
    }
    final elapsed = timedElapsedMs - prev;
    final target = timedChallenges[timedActualIndex].completionTime!;
    timedCurrentMs = target - elapsed;
    // Auto-advance actual index when the challenge time expires.
    if (timedCurrentMs <= 0 && timedActualIndex < timedChallenges.length - 1) {
      timedActualIndex++;
    }
  }

  static String _formatMs(int ms) {
    final abs = ms.abs();
    final sign = ms < 0 ? '-' : '';
    final m = abs ~/ (60 * 1000);
    final s = (abs % (60 * 1000)) ~/ 1000;
    final millis = abs % 1000;
    return '$sign${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}.${millis.toString().padLeft(3, '0')}';
  }
}
