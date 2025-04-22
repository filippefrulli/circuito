import 'package:circuito/objects/race.dart';
import 'package:circuito/objects/timed_race_section.dart';
import 'package:circuito/pages/home_page.dart';
import 'package:circuito/pages/races/timed/edit_timed_race_section_page.dart';
import 'package:circuito/pages/races/timed/timed_race_results_page.dart';
import 'package:circuito/utils/database.dart';
import 'package:circuito/widgets/page_title.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class EditTimedRacePage extends StatefulWidget {
  final int id;

  const EditTimedRacePage({
    super.key,
    required this.id,
  });

  @override
  State<EditTimedRacePage> createState() => _EditTimedRacePageState();
}

class _EditTimedRacePageState extends State<EditTimedRacePage> {
  late Future<List<TimedRaceSection>> _sectionsFuture;
  late Future<Race> _raceFuture;
  final TextEditingController _sectionNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSections();
    _raceFuture = DatabaseHelper.instance.getRaceById(widget.id);
  }

  @override
  void dispose() {
    _sectionNameController.dispose();
    super.dispose();
  }

  void _loadSections() {
    _sectionsFuture = DatabaseHelper.instance.getSectionsByRaceId(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: FutureBuilder<Race>(
        future: _raceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final race = snapshot.data!;
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: body(colors, race),
            ),
          );
        },
      ),
    );
  }

  Widget body(ColorScheme colors, Race race) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          topBar(colors, race),
          const SizedBox(height: 32),
          sectionsWidget(colors),
          const SizedBox(height: 32),
          endRaceButton(colors, race),
        ],
      ),
    );
  }

  Widget topBar(ColorScheme colors, Race race) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleWidget(
          intro: 'timed_race'.tr(),
          title: race.name,
        ),
        Expanded(
          child: Container(),
        ),
        deleteButton(colors, race)
      ],
    );
  }

  Widget deleteButton(ColorScheme colors, Race race) {
    return Padding(
      padding: const EdgeInsets.only(top: 64),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(25),
        ),
        child: IconButton(
          icon: Icon(
            Icons.delete_outlined,
            color: colors.secondary,
            size: 28,
          ),
          onPressed: () => _showDeleteConfirmation(context, colors, race),
        ),
      ),
    );
  }

  Widget sectionsWidget(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'sections'.tr(),
              style: Theme.of(context).textTheme.displayMedium,
            ),
            IconButton(
              icon: Icon(
                Icons.info_outline,
                color: colors.outline,
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => _showSectionInfoDialog(context, colors),
            ),
          ],
        ),
        FutureBuilder<List<TimedRaceSection>>(
          future: _sectionsFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox();
            return Column(
              children: [
                sectionListWidget(colors, snapshot.data!),
                const SizedBox(height: 16),
                Text(
                  'add_sections'.tr(),
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                addSectionWidget(colors),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget sectionListWidget(ColorScheme colors, List<TimedRaceSection> data) {
    if (data.isEmpty) {
      return Container(
        height: MediaQuery.of(context).size.height / 4,
        decoration: BoxDecoration(
          border: Border.all(color: colors.outline, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'no_sections_yet'.tr(),
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
      );
    }
    return Container(
      height: MediaQuery.of(context).size.height / 4,
      decoration: BoxDecoration(
        border: Border.all(color: colors.outline, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: data.length,
        itemBuilder: (context, index) {
          final section = data[index];
          return Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: index < data.length - 1 ? BorderSide(color: colors.outline) : BorderSide.none,
              ),
            ),
            child: InkWell(
              onTap: () {
                if (section.completed == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TimedRaceResultsPage(
                        raceId: widget.id,
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditTimedRaceSectionPage(
                        sectionId: section.id!,
                        raceId: widget.id,
                      ),
                    ),
                  ).then((_) => setState(() => _loadSections()));
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        section.name,
                        style: Theme.of(context).textTheme.displaySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Show checkmark if completed
                    if (section.completed == 1)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.check_circle_outline,
                          color: Colors.green[700],
                          size: 24,
                        ),
                      ),
                    // Delete Button
                    if (section.completed != 1)
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: colors.primary,
                          size: 24,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          // Prevent deleting completed section
                          if (section.completed == 1) return;
                          _showDeleteSectionConfirmation(context, colors, section);
                        },
                      ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      color: colors.primary,
                      size: 28,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget addSectionWidget(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: colors.outline, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          sectionNameInputWidget(colors),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              plusButton(colors),
            ],
          ),
        ],
      ),
    );
  }

  Widget sectionNameInputWidget(ColorScheme colors) {
    return TextField(
      controller: _sectionNameController,
      style: Theme.of(context).textTheme.displayMedium,
      decoration: InputDecoration(
        labelText: 'name'.tr(),
        hintText: 'example_section'.tr(),
        labelStyle: Theme.of(context).textTheme.labelMedium,
        hintStyle: Theme.of(context).textTheme.labelSmall,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.primary),
        ),
      ),
    );
  }

  Widget plusButton(ColorScheme colors) {
    return Container(
      height: 60,
      width: 120,
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: IconButton(
        onPressed: () async {
          if (_sectionNameController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter a section name')),
            );
            return;
          }

          final section = TimedRaceSection(
            raceId: widget.id,
            name: _sectionNameController.text,
            result: 0,
            completed: 0,
          );
          await DatabaseHelper.instance.insertSection(section);
          setState(() {
            _loadSections();
            _sectionNameController.clear();
          });
        },
        icon: Icon(Icons.add, color: colors.secondary, size: 32),
      ),
    );
  }

  Widget endRaceButton(ColorScheme colors, Race race) {
    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width - 96,
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextButton(
        onPressed: () {
          _showEndRaceConfirmation(context, colors, race);
        },
        child: Text(
          "end_race".tr(),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, ColorScheme colors, Race race) async {
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
                  'delete_race_confirmation'.tr(),
                  style: Theme.of(context).textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: cancelButton(colors),
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
                          child: Text(
                            'delete'.tr(),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          onPressed: () {
                            DatabaseHelper.instance.deleteRace(race.id!);
                            Navigator.of(context).pop();
                            Navigator.pop(context);
                          },
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

  Future<void> _showEndRaceConfirmation(BuildContext context, ColorScheme colors, Race race) async {
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: cancelButton(colors),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextButton(
                          child: Text(
                            'end_race'.tr(),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          onPressed: () {
                            DatabaseHelper.instance.endRace(race.id!);
                            Navigator.of(context).pop();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomePage(),
                              ),
                            );
                          },
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

  Widget cancelButton(ColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.outline, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      height: 50,
      child: TextButton(
        child: Text(
          'cancel'.tr(),
          style: Theme.of(context).textTheme.displaySmall,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  // Method to show the info dialog
  Future<void> _showSectionInfoDialog(BuildContext context, ColorScheme colors) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'what_are_sections'.tr(),
            style: Theme.of(context).textTheme.displayMedium,
          ),
          content: SingleChildScrollView(
            child: Text(
              'sections_explanation'.tr(),
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
          actions: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                child: Text(
                  'OK'.tr(),
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        color: Colors.white,
                      ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
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

  Future<void> _showDeleteSectionConfirmation(
      BuildContext context, ColorScheme colors, TimedRaceSection section) async {
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
                  'delete_section_confirmation'.tr(args: [section.name]),
                  style: Theme.of(context).textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: cancelButton(colors),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextButton(
                          child: Text(
                            'delete'.tr(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onError),
                          ),
                          onPressed: () async {
                            Navigator.of(context).pop();
                            try {
                              await DatabaseHelper.instance.deleteSection(section.id!);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('section_deleted'.tr(args: [section.name]))),
                              );
                              setState(() {
                                _loadSections(); // Reload the list
                              });
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${'error_deleting_section'.tr()}: $e')),
                              );
                            }
                          },
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
}
