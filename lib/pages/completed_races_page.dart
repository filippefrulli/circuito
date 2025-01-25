import 'package:auto_size_text/auto_size_text.dart';
import 'package:circuito/objects/race.dart';
import 'package:circuito/pages/races/timed/timed_race_results_page.dart';
import 'package:circuito/utils/database.dart';
import 'package:circuito/widgets/page_title.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CompletedRacesPage extends StatefulWidget {
  const CompletedRacesPage({super.key});

  @override
  State<CompletedRacesPage> createState() => _CompletedRacesPageState();
}

class _CompletedRacesPageState extends State<CompletedRacesPage> {
  late Future<List<Race>> _racesFuture;

  @override
  void initState() {
    super.initState();
    _racesFuture = DatabaseHelper.instance.getRaces();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const SizedBox(height: 64),
            topBar(colors),
            const SizedBox(height: 32),
            raceList(
              colors,
            )
          ],
        ),
      ),
    );
  }

  Widget topBar(ColorScheme colors) {
    return Row(
      children: [
        PageTitleWidget(
          intro: 'your'.tr(),
          title: 'completed_races'.tr(),
        ),
      ],
    );
  }

  raceList(ColorScheme colors) {
    return Expanded(
      child: FutureBuilder<List<Race>>(
        future: _racesFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'no_completed_races'.tr(),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.zero,
            physics: const ClampingScrollPhysics(),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final race = snapshot.data![index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TimedRaceResultsPage(
                        raceId: race.id!,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.outline, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            maxLines: 1,
                            race.name,
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd/MM/yyyy').format(
                              DateTime.parse(race.timestamp),
                            ),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: colors.primary,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
