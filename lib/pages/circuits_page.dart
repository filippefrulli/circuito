import 'package:circuito/objects/circuit.dart';
import 'package:circuito/utils/database.dart';
import 'package:circuito/widgets/page_title.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CircuitsPage extends StatefulWidget {
  const CircuitsPage({super.key});

  @override
  State<CircuitsPage> createState() => _CircuitsPageState();
}

class _CircuitsPageState extends State<CircuitsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pageBody(),
    );
  }

  Widget pageBody() {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            topBar(colors),
            const SizedBox(height: 32),
            circuitsList(colors),
            const SizedBox(height: 32),
            addCircuitButton(colors),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget topBar(ColorScheme colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleWidget(
          intro: 'my_pl'.tr(),
          title: 'circuits'.tr(),
        ),
        Expanded(
          child: Container(),
        ),
      ],
    );
  }

  Widget circuitsList(ColorScheme colors) {
    return Expanded(
      child: FutureBuilder<List<Circuit>>(
        future: DatabaseHelper.instance.getCircuits(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No circuits yet',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return circuitItem(snapshot.data![index], colors);
            },
          );
        },
      ),
    );
  }

  Widget circuitItem(Circuit circuit, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: colors.primary, width: 2),
        borderRadius: const BorderRadius.all(Radius.circular(25)),
      ),
      child: Text(
        circuit.name,
        style: Theme.of(context).textTheme.displayMedium,
      ),
    );
  }

  Widget addCircuitButton(ColorScheme colors) {
    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width - 96,
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextButton(
        onPressed: () => {_showAddCircuitDialog(colors)},
        child: Text(
          "add_circuit".tr(),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Future<void> _showAddCircuitDialog(ColorScheme colors) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'add_circuit'.tr(),
            style: Theme.of(context).textTheme.displayMedium,
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
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
                _clearControllers();
                Navigator.pop(context);
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
                  if (_formKey.currentState!.validate()) {
                    final circuit = Circuit(
                      name: _nameController.text,
                    );
                    await DatabaseHelper.instance.insertCircuit(circuit);
                    _clearControllers();
                    Navigator.pop(context);
                    setState(() {});
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

  void _clearControllers() {
    _nameController.clear();
  }
}
