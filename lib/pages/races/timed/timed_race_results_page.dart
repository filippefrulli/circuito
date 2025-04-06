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

          return results.length > 0
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
