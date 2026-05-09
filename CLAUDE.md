# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run on a connected device or simulator
flutter run

# Build for iOS / Android
flutter build ios
flutter build apk

# Analyze for linting issues
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart
```

## Architecture Overview

**Circuito** is a Flutter mobile app (iOS/Android) for tracking car race performance at old timer / vintage car racing events. It uses `sqflite` for local SQLite persistence, `easy_localization` for i18n (English and Italian), and `oktoast` for toast notifications. There is no backend — all data is stored on-device. No advanced state management (Provider, BLoC, Riverpod) is used — state is managed via `ChangeNotifier` in `RaceTimerService` only; all other pages use local widget state.

### Two race modes

- **Laps race** (`RaceType.laps`, id=2): Countdown timer per lap. The driver sets a target lap time and number of laps; the timer counts down and resets each lap. Results: fastest lap + average lap time.
- **Timed race / Time trial** (`RaceType.timed`, id=1): Challenge-based. A race is divided into *sections* (e.g. "Day 1 - Round 1"), and each section contains ordered *timed challenges*. During a run, the timer counts down per challenge; the driver presses STOP when they complete each one. The time deviation from the target is recorded. Results: total time difference + a score weighted by car year (`(year % 100) / 100 + 1`).

### Data model (`lib/objects/`, `lib/utils/database.dart`)

The `DatabaseHelper` singleton (`DatabaseHelper.instance`) manages all DB access. The schema (v1, **no migrations** — schema changes require reinstall) has these tables with cascade-delete FK relationships:

```
cars → races → race_results
circuits → races
races → lap_results
races → timed_race_sections → timed_challenges → timed_challenge_results
```

All time values are stored as integers (milliseconds). Key schema details:

- `race_results` is sparse: `fastest_lap`/`average_lap_time` for laps races; `final_time`/`final_score` for timed races.
- `timed_challenges` has a unique constraint on `(section_id, rank)`. Bulk rank updates use temporary negative ranks to avoid constraint violations.
- `races.coefficient` stores the scoring multiplier (default: `(carYear % 100) / 100 + 1`); overridable per race.
- Final score formula: `((totalTimeDifference / 10) * coefficient).round()`.
- `updateRaceResultsForSection()` uses a DB transaction to aggregate challenge results into the section total.

### RaceTimerService (`lib/services/race_timer_service.dart`)

Singleton `ChangeNotifier` that owns the live race timer and survives navigation. The `Timer.periodic(10ms)` runs here, not in widgets. Key state:

**Laps race:** `lapCurrentTimeMs`, `lapIdealTimeMs` (target), `lapCurrent`

**Timed race:** `timedElapsedMs`, `timedChallenges` (ordered list), `timedDisplayIndex`, `timedActualIndex`, `timedCurrentMs` (countdown, goes negative in overtime)

Auto-advances timed challenges when countdown reaches zero. Call `clearRace()` after saving results to reset all state.

### Navigation flow

1. **Splash** → checks `shared_preferences` for `skip_intro`; routes to `LanguagePage` (first launch) or `HomePage`.
2. **HomePage** (`/main`) — shows incomplete races, links to Garage (`/garage`), Circuits (`/circuits`), completed races, and create race.
3. **CreateRacePage** — selects car, circuit, race type; inserts a `Race` with `status=0`; routes to `EditTimedRacePage` or `EditLapsRacePage`.
4. **Edit pages** — configure the race (sections/challenges for timed; laps/target time for laps); launch the active race page.
5. **Active race pages** (`TimedRacePage`, `LapsRacePage`) — live timer via `RaceTimerService`; on completion routes to results page.
6. **Results pages** — display stats and allow ending/saving the race (`status=1`).

A global `appNavigatorKey` (`lib/utils/navigation.dart`) is passed to `MaterialApp` so that `RaceTimerService` can navigate without a `BuildContext`. The `RaceTimerBanner` widget is injected via `MaterialApp`'s `builder` and stays visible across all routes to show the active race countdown.

### Theme conventions (`lib/main.dart`)

The app uses a single `ThemeData` with a light `ColorScheme` (primary=black, secondary=white, tertiary=grey). Text styles follow a strict semantic mapping — use these instead of raw `TextStyle`:

| Style | Color | Size |
|---|---|---|
| `displayLarge` | black | 46 |
| `displayMedium` | black | 20 |
| `displaySmall` | black | 16 |
| `labelLarge/Medium/Small` | grey | 24/20/16 |
| `bodyLarge/Medium/Small` | white | 24/20/16 |
| `headlineSmall` | blue (accent) | 16 |

### Localization

All user-facing strings must use `.tr()` from `easy_localization`. Translation keys live in `assets/translations/en-US.json` and `assets/translations/it-IT.json`. Both files must be kept in sync when adding new strings.
