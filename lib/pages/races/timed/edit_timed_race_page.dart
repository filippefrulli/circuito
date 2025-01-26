import 'package:circuito/objects/race.dart';
import 'package:circuito/objects/timed_race_section.dart';
import 'package:circuito/pages/races/timed/edit_timed_race_section_page.dart';
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
          return body(colors, race);
        },
      ),
    );
  }

  Widget body(ColorScheme colors, Race race) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const SizedBox(height: 64),
          topBar(colors, race),
          const SizedBox(height: 32),
          sectionsWidget(colors),
          Expanded(child: Container()),
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
      ],
    );
  }

  Widget sectionsWidget(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'sections'.tr(),
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 16),
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
    return Container(
      height: 250,
      decoration: BoxDecoration(
        border: Border.all(color: colors.outline, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: data.length,
        itemBuilder: (context, index) {
          final section = data[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditTimedRaceSectionPage(
                    id: section.id!,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: colors.outline),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    section.name,
                    style: Theme.of(context).textTheme.displaySmall,
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
}
