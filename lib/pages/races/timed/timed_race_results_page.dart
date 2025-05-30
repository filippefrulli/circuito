import 'package:circuito/objects/race.dart';
import 'package:circuito/objects/timed_challenge_result.dart';
import 'package:circuito/objects/timed_race_section.dart';
import 'package:circuito/pages/home_page.dart';
import 'package:circuito/utils/database.dart';
import 'package:circuito/widgets/page_title.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class TimedRaceResultsPage extends StatefulWidget {
  final int raceId;

  const TimedRaceResultsPage({
    super.key,
    required this.raceId,
  });

  @override
  State<TimedRaceResultsPage> createState() => _TimedRaceResultsPageState();
}

class _TimedRaceResultsPageState extends State<TimedRaceResultsPage> {
  Race? _race;
  List<TimedRaceSection>? _sections;
  Map<int, List<TimedChallengeResult>>? _results;
  Map<String, dynamic>? _raceResults;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || _race == null) {
      return Scaffold(
        body: Center(child: Text(_errorMessage ?? 'Race data not available')),
      );
    }

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
          const SizedBox(height: 32),
          overallResultsWidget(colors),
          const SizedBox(height: 16),
          sectionResultsList(colors),
          const SizedBox(height: 32),
          backToHomeButton(colors),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget topBar(ColorScheme colors) {
    return Row(
      children: [
        PageTitleWidget(
          intro: 'race_results'.tr(),
          title: _race!.name,
        ),
      ],
    );
  }

  Widget overallResultsWidget(ColorScheme colors) {
    final totalTime = _raceResults?[DatabaseHelper.raceResultTimedFinalTime];
    final totalScore = _raceResults?[DatabaseHelper.raceResultTimedFinalScore];

    if (totalTime == null) {
      return const SizedBox();
    }

    return Row(
      children: [
        Expanded(
          child: totalTimeWidget(colors, totalTime),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: totalScoreWidget(colors, totalScore ?? 0),
        ),
      ],
    );
  }

  Widget totalTimeWidget(ColorScheme colors, int totalTime) {
    return Container(
      height: 108,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: colors.outline, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'total_time'.tr(),
            style: Theme.of(context).textTheme.displaySmall!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _formatTimeDifference(totalTime),
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.error,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget totalScoreWidget(ColorScheme colors, int totalScore) {
    return Container(
      height: 108,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: colors.outline, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'total_score'.tr(),
            style: Theme.of(context).textTheme.displaySmall!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Container(),
              ),
              Text(
                totalScore.toString(),
                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[600],
                    ),
                textAlign: TextAlign.center,
              ),
              IconButton(
                icon: Icon(
                  Icons.info_outline,
                  color: colors.outline,
                  size: 16,
                ),
                visualDensity: VisualDensity.compact,
                tooltip: 'score_formula_tooltip'.tr(),
                onPressed: () => _showScoreInfoDialog(context, colors),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget sectionResultsList(ColorScheme colors) {
    if (_sections == null || _sections!.isEmpty) {
      return const Center(
        child: Text('No sections found'),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: _sections!.length,
        itemBuilder: (context, sectionIndex) {
          final section = _sections![sectionIndex];
          final results = _results?[section.id!] ?? [];

          return results.isNotEmpty
              ? ExpansionTile(
                  tilePadding: const EdgeInsets.only(bottom: 8),
                  title: Text(
                    section.name,
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      "+ ${(section.result / 1000).toStringAsFixed(3)}s",
                      style: Theme.of(context).textTheme.displayMedium!.copyWith(
                            color: section.result > 0 ? colors.error : Colors.green[600],
                          ),
                    ),
                  ),
                  children: results
                      .map(
                        (result) => Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: colors.outline, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Challenge ${result.rank}',
                                style: Theme.of(context).textTheme.displayMedium,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _formatTime(result.completionTime),
                                    style: Theme.of(context).textTheme.displayMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _formatTimeDifference(result.timeDifference),
                                    style: TextStyle(
                                      color: result.timeDifference > 0 ? colors.error : Colors.green[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                )
              : Container();
        },
      ),
    );
  }

  backToHomeButton(ColorScheme colors) {
    return Container(
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
              builder: (context) => const HomePage(),
            ),
          );
        },
        child: Text(
          'close'.tr(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.onPrimary,
              ),
        ),
      ),
    );
  }

  Future<void> _loadAllData() async {
    try {
      // Load race data
      _race = await DatabaseHelper.instance.getRaceById(widget.raceId);
      if (_race == null) {
        setState(() {
          _errorMessage = 'Race not found';
          _isLoading = false;
        });
        return;
      }

      // Load race results
      _raceResults = await DatabaseHelper.instance.getRaceResults(widget.raceId);

      // Load sections data
      _sections = await DatabaseHelper.instance.getSectionsByRaceId(widget.raceId);

      // Load results data
      final resultsMap = <int, List<TimedChallengeResult>>{};
      for (var section in _sections!) {
        final challenges = await DatabaseHelper.instance.getChallengesBySectionId(section.id!);
        final sectionResults = <TimedChallengeResult>[];

        for (var challenge in challenges) {
          final challengeResults = await DatabaseHelper.instance.getTimedChallengeResultByChallengeId(challenge.id!);
          if (challengeResults.isNotEmpty) {
            sectionResults.add(challengeResults.first);
          }
        }

        if (sectionResults.isNotEmpty) {
          resultsMap[section.id!] = sectionResults;
        }
      }

      _results = resultsMap;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading data: $e';
        _isLoading = false;
      });
    }
  }

  // Method to show the score formula info dialog
  Future<void> _showScoreInfoDialog(BuildContext context, ColorScheme colors) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'score_formula_title'.tr(),
            style: Theme.of(context).textTheme.displayMedium,
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 1, color: colors.outline),
                const SizedBox(height: 16),
                Text(
                  'score_formula_explanation'.tr(),
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 32),
                Text(
                  'score_formula_example'.tr(),
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: colors.outline, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'OK'.tr(),
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: colors.outline, width: 2),
          ),
        );
      },
    );
  }

  String _formatTime(int milliseconds) {
    final minutes = milliseconds ~/ (60 * 1000);
    final seconds = (milliseconds % (60 * 1000)) ~/ 1000;
    final ms = milliseconds % 1000;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${ms.toString().padLeft(3, '0')}';
  }

  String _formatTimeDifference(int milliseconds) {
    final isNegative = milliseconds < 0;
    final time = _formatTime(milliseconds.abs());
    return '${isNegative ? '-' : '+'}$time';
  }
}
