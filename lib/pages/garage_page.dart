import 'package:circuito/objects/car.dart';
import 'package:circuito/utils/database.dart';
import 'package:circuito/widgets/page_title.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class GaragePage extends StatefulWidget {
  const GaragePage({super.key});

  @override
  State<GaragePage> createState() => _GaragePageState();
}

class _GaragePageState extends State<GaragePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _yearController = TextEditingController();

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
            const SizedBox(height: 64),
            topBar(colors),
            const SizedBox(height: 32),
            carList(colors),
            const SizedBox(height: 32),
            addCarButton(colors),
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
          intro: 'my_sg'.tr(),
          title: 'garage'.tr(),
        ),
        Expanded(
          child: Container(),
        ),
      ],
    );
  }

  Widget carList(ColorScheme colors) {
    return Expanded(
      child: FutureBuilder<List<Car>>(
        future: DatabaseHelper.instance.getCars(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No cars yet',
                style: TextStyle(color: colors.onSurface),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return carItem(snapshot.data![index], colors);
            },
          );
        },
      ),
    );
  }

  Widget carItem(Car car, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: colors.primary, width: 2),
          borderRadius: const BorderRadius.all(Radius.circular(25)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              car.name,
              style: Theme.of(context).textTheme.displayMedium,
            ),
            Expanded(child: Container()),
            Container(
              width: 2,
              height: 24,
              color: colors.primary,
            ),
            const SizedBox(
              width: 16,
            ),
            Text(
              car.year.toString(),
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget addCarButton(ColorScheme colors) {
    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width - 96,
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextButton(
        onPressed: () => {_showAddCarDialog(colors)},
        child: Text(
          "add_car".tr(),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Future<void> _showAddCarDialog(ColorScheme colors) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'add_car'.tr(),
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
                  controller: _yearController,
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
                    final car = Car(
                      name: _nameController.text,
                      year: int.parse(_yearController.text),
                      image: 'assets/images/porsche.png',
                    );
                    await DatabaseHelper.instance.insertCar(car);
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
    _yearController.clear();
  }
}
