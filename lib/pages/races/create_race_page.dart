import 'package:circuito/objects/car.dart';
import 'package:circuito/objects/circuit.dart';
import 'package:circuito/objects/race.dart';
import 'package:circuito/pages/races/timed/edit_timed_race_page.dart';
import 'package:circuito/pages/races/laps/edit_laps_race_page.dart';
import 'package:circuito/utils/database.dart';
import 'package:circuito/widgets/page_title.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CreateRacePage extends StatefulWidget {
  const CreateRacePage({super.key});

  @override
  State<CreateRacePage> createState() => _CreateRacePageState();
}

class _CreateRacePageState extends State<CreateRacePage> {
  final TextEditingController _nameController = TextEditingController();
  String _raceName = '';

  Car? selectedCar;
  Circuit? selectedCircuit;
  RaceType? selectedType;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    setState(() {
      _raceName = _nameController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom,
          ),
          child: body(colors),
        ),
      ),
    );
  }

  Widget body(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              topBar(colors),
              const SizedBox(height: 32),
              raceNameInput(colors),
              selectCar(colors),
              selectCircuit(colors),
              selectType(colors),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              createRaceButton(colors),
              const SizedBox(height: 32),
            ],
          ),
        ],
      ),
    );
  }

  Widget topBar(ColorScheme colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleWidget(
          intro: 'create_new'.tr(),
          title: 'race'.tr(),
        ),
      ],
    );
  }

  Widget raceNameInput(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'race_name'.tr(),
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 8),
        Container(
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: colors.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _nameController,
            style: Theme.of(context).textTheme.displaySmall,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: InputBorder.none,
              hintText: 'enter_race_name'.tr(),
              hintStyle: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ),
      ],
    );
  }

  Widget selectCar(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text(
          'select_car'.tr(),
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<Car>>(
          future: DatabaseHelper.instance.getCars(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return noItems('no_cars'.tr(), colors);
            }
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(color: colors.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<Car>(
                value: selectedCar,
                isExpanded: true,
                hint: Text('select_car'.tr()),
                menuMaxHeight: 300,
                borderRadius: BorderRadius.circular(8),
                style: Theme.of(context).textTheme.displaySmall,
                icon: Icon(Icons.arrow_drop_down, color: colors.primary),
                itemHeight: 50,
                items: snapshot.data!.map((Car car) {
                  return DropdownMenuItem<Car>(
                    value: car,
                    child: Text(car.name),
                  );
                }).toList(),
                onChanged: (Car? value) {
                  setState(() {
                    selectedCar = value;
                  });
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget selectCircuit(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text(
          'select_circuit'.tr(),
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<Circuit>>(
          future: DatabaseHelper.instance.getCircuits(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return noItems('no_circuits'.tr(), colors);
            }
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(color: colors.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<Circuit>(
                value: selectedCircuit,
                isExpanded: true,
                hint: Text('select_circuit'.tr()),
                menuMaxHeight: 300,
                borderRadius: BorderRadius.circular(8),
                style: Theme.of(context).textTheme.displaySmall,
                icon: Icon(Icons.arrow_drop_down, color: colors.primary),
                itemHeight: 50,
                items: snapshot.data!.map((Circuit circuit) {
                  return DropdownMenuItem<Circuit>(
                    value: circuit,
                    child: Text(circuit.name),
                  );
                }).toList(),
                onChanged: (Circuit? value) {
                  setState(
                    () {
                      selectedCircuit = value;
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget selectType(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text(
          'select_type'.tr(),
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: colors.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<RaceType>(
            value: selectedType,
            isExpanded: true,
            hint: Text('select_type'.tr()),
            menuMaxHeight: 300,
            borderRadius: BorderRadius.circular(8),
            style: Theme.of(context).textTheme.displaySmall,
            icon: Icon(Icons.arrow_drop_down, color: colors.primary),
            itemHeight: 50,
            items: RaceType.values.map((RaceType type) {
              return DropdownMenuItem<RaceType>(
                value: type,
                child: Text(type.display.tr()),
              );
            }).toList(),
            onChanged: (RaceType? value) {
              setState(() {
                selectedType = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget noItems(String text, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: colors.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'no_cars'.tr(),
          style: Theme.of(context).textTheme.labelSmall,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget createRaceButton(ColorScheme colors) {
    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width - 96,
      decoration: BoxDecoration(
        color: isFormValid() ? colors.primary : colors.tertiary,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextButton(
        onPressed: () async {
          if (isFormValid()) {
            try {
              final race = Race(
                name: _nameController.text,
                car: selectedCar!.id!,
                circuit: selectedCircuit!.id!,
                type: selectedType!.id,
                status: 0,
                createdAt: DateTime.now().toIso8601String(),
              );

              final id = await DatabaseHelper.instance.insertRace(race);
              if (mounted) {
                if (selectedType == RaceType.timed) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditTimedRacePage(id: id),
                    ),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditLapsRacePage(id: id),
                    ),
                  );
                }
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error creating race: $e')),
                );
              }
            }
          }
        },
        child: Text(
          "create_race".tr(),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  bool isFormValid() {
    return _raceName.isNotEmpty && selectedCar != null && selectedCircuit != null && selectedType != null;
  }
}
