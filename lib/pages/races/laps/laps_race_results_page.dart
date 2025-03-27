import 'package:circuito/objects/lap_result.dart';
import 'package:circuito/objects/race.dart';
import 'package:circuito/pages/home_page.dart';
import 'package:circuito/utils/database.dart';
import 'package:circuito/widgets/page_title.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LapsRaceResultsPage extends StatefulWidget {
  final int raceId;

  const LapsRaceResultsPage({
    super.key,
    required this.raceId,
  });

  @override
  State<LapsRaceResultsPage> createState() => _LapsRaceResultsPageState();
}

class _LapsRaceResultsPageState extends State<LapsRaceResultsPage> {
  late Future<Race> _raceFuture;
  late Future<List<LapResult>> _lapResultsFuture;

  @override
  void initState() {
    super.initState();
    _raceFuture = DatabaseHelper.instance.getRaceById(widget.raceId);
    _lapResultsFuture = DatabaseHelper.instance.getLapResultsByRaceId(widget.raceId);
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
          lapResultList(colors),
          const SizedBox(height: 32),
          backToHomeButton(colors),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget topBar(ColorScheme colors) {
    return FutureBuilder<Race>(
      future: _raceFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        return Row(
          children: [
            PageTitleWidget(
              intro: 'race_results'.tr(),
              title: snapshot.data!.name,
            ),
          ],
        );
      },
    );
  }

  Widget lapResultList(ColorScheme colors) {
    return Expanded(
      child: FutureBuilder<List<LapResult>>(
        future: _lapResultsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final lap = snapshot.data![index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: colors.outline, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Lap ${lap.lapNumber}',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatTime(lap.completionTime),
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatTimeDifference(lap.timeDifference),
                          style: TextStyle(
                            color: lap.timeDifference > 0 ? colors.error : Colors.green[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
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
