import 'package:circuito/objects/car.dart';
import 'package:circuito/objects/circuit.dart';
import 'package:circuito/pages/races/select_race_type_page.dart';
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
  Car? selectedCar;
  Circuit? selectedCircuit;

  int _carListVersion = 0;
  int _circuitListVersion = 0;

  final _carFormKey = GlobalKey<FormState>();
  final _carNameController = TextEditingController();
  final _carYearController = TextEditingController();

  final _circuitFormKey = GlobalKey<FormState>();
  final _circuitNameController = TextEditingController();

  @override
  void dispose() {
    _carNameController.dispose();
    _carYearController.dispose();
    _circuitNameController.dispose();
    super.dispose();
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
              selectCar(colors),
              selectCircuit(colors),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              nextButton(colors),
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
          showBackButton: true,
        ),
      ],
    );
  }

  Widget selectCar(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'select_car'.tr(),
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FutureBuilder<List<Car>>(
                key: ValueKey(_carListVersion),
                future: DatabaseHelper.instance.getCars(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _noItems('no_cars'.tr(), colors);
                  }
                  // Keep selected car in sync if the list changed
                  final cars = snapshot.data!;
                  if (selectedCar != null &&
                      !cars.any((c) => c.id == selectedCar!.id)) {
                    selectedCar = null;
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
                      items: cars.map((Car car) {
                        return DropdownMenuItem<Car>(
                          value: car,
                          child: Text(car.name),
                        );
                      }).toList(),
                      onChanged: (Car? value) {
                        setState(() => selectedCar = value);
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            _addButton(colors, () => _showAddCarDialog(colors)),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget selectCircuit(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'select_circuit'.tr(),
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FutureBuilder<List<Circuit>>(
                key: ValueKey(_circuitListVersion),
                future: DatabaseHelper.instance.getCircuits(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _noItems('no_circuits'.tr(), colors);
                  }
                  final circuits = snapshot.data!;
                  if (selectedCircuit != null &&
                      !circuits.any((c) => c.id == selectedCircuit!.id)) {
                    selectedCircuit = null;
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
                      items: circuits.map((Circuit circuit) {
                        return DropdownMenuItem<Circuit>(
                          value: circuit,
                          child: Text(circuit.name),
                        );
                      }).toList(),
                      onChanged: (Circuit? value) {
                        setState(() => selectedCircuit = value);
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            _addButton(colors, () => _showAddCircuitDialog(colors)),
          ],
        ),
      ],
    );
  }

  Widget _addButton(ColorScheme colors, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.add, color: colors.onPrimary, size: 28),
      ),
    );
  }

  Widget _noItems(String text, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: colors.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelSmall,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget nextButton(ColorScheme colors) {
    final isValid = selectedCar != null && selectedCircuit != null;
    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width - 96,
      decoration: BoxDecoration(
        color: isValid ? colors.primary : colors.tertiary,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextButton(
        onPressed: isValid
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SelectRaceTypePage(
                      car: selectedCar!,
                      circuit: selectedCircuit!,
                    ),
                  ),
                );
              }
            : null,
        child: Text(
          'next'.tr(),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Future<void> _showAddCarDialog(ColorScheme colors) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            'add_car'.tr(),
            style: Theme.of(context).textTheme.displayMedium,
          ),
          content: Form(
            key: _carFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _carNameController,
                  decoration: InputDecoration(
                    labelText: 'Car Name',
                    labelStyle: Theme.of(context).textTheme.labelSmall,
                  ),
                  style: Theme.of(context).textTheme.displayMedium,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter car name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _carYearController,
                  decoration: InputDecoration(
                    labelText: 'Year',
                    labelStyle: Theme.of(context).textTheme.labelSmall,
                  ),
                  style: Theme.of(context).textTheme.displayMedium,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter year';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _carNameController.clear();
                _carYearController.clear();
                Navigator.pop(ctx);
              },
              child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(15),
              ),
              width: 80,
              child: TextButton(
                onPressed: () async {
                  if (_carFormKey.currentState!.validate()) {
                    final car = Car(
                      name: _carNameController.text,
                      year: int.parse(_carYearController.text),
                      image: 'assets/images/porsche.png',
                    );
                    final id = await DatabaseHelper.instance.insertCar(car);
                    _carNameController.clear();
                    _carYearController.clear();
                    Navigator.pop(ctx);
                    setState(() {
                      _carListVersion++;
                      selectedCar = Car(
                        id: id,
                        name: car.name,
                        year: car.year,
                        image: car.image,
                      );
                    });
                  }
                },
                child: Text(
                  'Save',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddCircuitDialog(ColorScheme colors) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            'add_circuit'.tr(),
            style: Theme.of(context).textTheme.displayMedium,
          ),
          content: Form(
            key: _circuitFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _circuitNameController,
                  decoration: InputDecoration(
                    labelText: 'Circuit Name',
                    labelStyle: Theme.of(context).textTheme.labelSmall,
                  ),
                  style: Theme.of(context).textTheme.displayMedium,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the circuit name';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _circuitNameController.clear();
                Navigator.pop(ctx);
              },
              child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(15),
              ),
              width: 80,
              child: TextButton(
                onPressed: () async {
                  if (_circuitFormKey.currentState!.validate()) {
                    final circuit = Circuit(
                      name: _circuitNameController.text,
                    );
                    final id =
                        await DatabaseHelper.instance.insertCircuit(circuit);
                    _circuitNameController.clear();
                    Navigator.pop(ctx);
                    setState(() {
                      _circuitListVersion++;
                      selectedCircuit = Circuit(
                        id: id,
                        name: circuit.name,
                      );
                    });
                  }
                },
                child: Text(
                  'Save',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
