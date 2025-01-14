import 'package:circuito/objects/race.dart';
import 'package:circuito/utils/database.dart';
import 'package:circuito/widgets/page_title.dart';
import 'package:flutter/material.dart';

class EditLapsRacePage extends StatefulWidget {
  final int id;

  const EditLapsRacePage({
    super.key,
    required this.id,
  });

  @override
  State<EditLapsRacePage> createState() => _EditLapsRacePageState();
}

class _EditLapsRacePageState extends State<EditLapsRacePage> {
  late Future<Race> _raceFuture;

  @override
  void initState() {
    super.initState();
    _raceFuture = DatabaseHelper.instance.getRaceById(widget.id);
  }

  @override
  void dispose() {
    super.dispose();
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
          const SizedBox(height: 32),
          topBar(colors, race),
        ],
      ),
    );
  }

  Widget topBar(ColorScheme colors, Race race) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleWidget(
          intro: '',
          title: race.name,
        ),
      ],
    );
  }
}
