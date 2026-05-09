import 'package:circuito/objects/car.dart';
import 'package:circuito/objects/circuit.dart';
import 'package:circuito/objects/race.dart';
import 'package:circuito/pages/races/timed/edit_timed_race_page.dart';
import 'package:circuito/pages/races/laps/edit_laps_race_page.dart';
import 'package:circuito/utils/database.dart';
import 'package:circuito/utils/transitions.dart';
import 'package:circuito/widgets/app_button.dart';
import 'package:circuito/widgets/page_title.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SelectRaceTypePage extends StatefulWidget {
  final Car car;
  final Circuit circuit;

  const SelectRaceTypePage({
    super.key,
    required this.car,
    required this.circuit,
  });

  @override
  State<SelectRaceTypePage> createState() => _SelectRaceTypePageState();
}

class _SelectRaceTypePageState extends State<SelectRaceTypePage> {
  bool _isCreating = false;
  RaceType? _selectedType;

  Future<void> _createRace(RaceType type) async {
    if (_isCreating) return;
    setState(() => _isCreating = true);

    final dateStr = DateFormat('d MMM yyyy').format(DateTime.now());
    final name = '${widget.circuit.name} - $dateStr';

    final race = Race(
      name: name,
      car: widget.car.id!,
      circuit: widget.circuit.id!,
      type: type.id,
      status: 0,
      createdAt: DateTime.now().toIso8601String(),
    );

    final id = await DatabaseHelper.instance.insertRace(race);

    if (!mounted) return;
    if (type == RaceType.timed) {
      Navigator.pushReplacement(context, slideRoute(EditTimedRacePage(id: id)));
    } else {
      Navigator.pushReplacement(context, slideRoute(EditLapsRacePage(id: id)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageTitleWidget(
                  intro: '',
                  title: 'select_type'.tr(),
                  showBackButton: true,
                ),
                const SizedBox(height: 32),
                _raceTypeCard(
                  colors: colors,
                  title: 'time_trial'.tr(),
                  description: 'time_trial_description'.tr(),
                  type: RaceType.timed,
                ),
                const SizedBox(height: 16),
                _raceTypeCard(
                  colors: colors,
                  title: 'lap_race'.tr(),
                  description: 'lap_race_description'.tr(),
                  type: RaceType.laps,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: _selectButton(colors),
            ),
          ],
        ),
      ),
    );
  }

  Widget _raceTypeCard({
    required ColorScheme colors,
    required String title,
    required String description,
    required RaceType type,
  }) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: _isCreating ? null : () => setState(() => _selectedType = type),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : null,
          border: Border.all(color: colors.primary, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? colors.onPrimary : null,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isSelected ? colors.onPrimary : null,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectButton(ColorScheme colors) {
    final isEnabled = _selectedType != null && !_isCreating;
    return Stack(
      alignment: Alignment.center,
      children: [
        AppButton(
          label: 'select'.tr(),
          enabled: isEnabled,
          onPressed: () => _createRace(_selectedType!),
        ),
        if (_isCreating)
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5,
            ),
          ),
      ],
    );
  }
}
