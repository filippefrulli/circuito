# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run on a connected device or simulator
flutter run

# Build for iOS
flutter build ios

# Analyze for linting issues
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart
```

## Architecture Overview

**Circuito** is a Flutter mobile app (iOS/Android) for tracking car race performance, aimed at old timer / vintage car racing events. It uses `sqflite` for local SQLite persistence, `easy_localization` for i18n (English and Italian), and `oktoast` for toast notifications. There is no backend — all data is stored on-device.

### Two race modes

- **Laps race** (`RaceType.laps`, id=2): Countdown timer per lap. The driver sets a target lap time and number of laps; the timer counts down and resets each lap. Results: fastest lap + average lap time.
- **Timed race / Time trial** (`RaceType.timed`, id=1): Challenge-based. A race is divided into *sections* (e.g. "Day 1 - Round 1"), and each section contains ordered *timed challenges*. During a run, the timer counts down per challenge; the driver presses STOP when they complete each one. The time deviation from the target is recorded. Results: total time difference + a score weighted by car year (`(year % 100) / 100 + 1`).

### Data model (`lib/objects/`, `lib/utils/database.dart`)

The `DatabaseHelper` singleton (`DatabaseHelper.instance`) manages all DB access. The schema (v1, no migrations yet) has these tables with cascade-delete FK relationships:

```
cars → races → race_results
circuits → races
races → lap_results
races → timed_race_sections → timed_challenges → timed_challenge_results
```

All time values are stored as integers (milliseconds).

### Navigation flow

1. **Splash** → checks `shared_preferences` for `skip_intro`; routes to `LanguagePage` (first launch) or `HomePage`.
2. **HomePage** (`/main`) — shows incomplete races, links to Garage (`/garage`), Circuits (`/circuits`), completed races, and create race.
3. **CreateRacePage** — selects car, circuit, race type; inserts a `Race` with `status=0`; routes to `EditTimedRacePage` or `EditLapsRacePage`.
4. **Edit pages** — configure the race (sections/challenges for timed; laps/target time for laps); launch the active race page.
5. **Active race pages** (`TimedRacePage`, `LapsRacePage`) — live timer using `Timer.periodic(10ms)`; on completion routes to results page.
6. **Results pages** — display stats and allow ending/saving the race (`status=1`).

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
