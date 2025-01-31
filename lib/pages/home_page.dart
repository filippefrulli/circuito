import 'package:circuito/pages/clock_page.dart';
import 'package:circuito/pages/completed_races_page.dart';
import 'package:circuito/pages/races/create_race_page.dart';
import 'package:circuito/pages/settings/settings_page.dart';
import 'package:circuito/pages/third_page.dart';
import 'package:circuito/widgets/page_title.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragEnd: (DragEndDetails details) {
          if (details.primaryVelocity! > 0) {
            // Swiped right
            setState(() {
              if (_selectedIndex > 0) {
                _selectedIndex--;
              }
            });
          } else if (details.primaryVelocity! < 0) {
            // Swiped left
            setState(() {
              if (_selectedIndex < 2) {
                _selectedIndex++;
              }
            });
          }
        },
        child: IndexedStack(
          index: _selectedIndex,
          children: const [
            ClockPage(),
            HomeContent(),
            ThirdPage(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: colors.primary,
          unselectedItemColor: colors.outline,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.timer),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_car),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
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
          const SizedBox(height: 64),
          topBar(colors),
          const SizedBox(height: 64),
          middleButtons(colors),
          const SizedBox(height: 24),
          completedRacesButton(colors),
          Expanded(
            child: Container(),
          ),
          //isContinue == 1 ? continueRaceButton(colors) :
          newRaceButton(colors),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget topBar(ColorScheme colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleWidget(
          intro: 'welcome'.tr(),
          title: 'Lorenzo',
        ),
        settingsButton(colors),
      ],
    );
  }

  Widget settingsButton(ColorScheme colors) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(25),
      ),
      child: IconButton(
        icon: Icon(
          Icons.settings,
          color: colors.secondary,
          size: 28,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SettingsPage(),
            ),
          );
        },
      ),
    );
  }

  middleButtons(ColorScheme colors) {
    return Row(
      children: [
        centerButton(colors, Icons.car_rental, 'my_garage'.tr(), '/garage'),
        const SizedBox(
          width: 24,
        ),
        centerButton(colors, Icons.home, 'my_circuits'.tr(), '/circuits'),
      ],
    );
  }

  Widget centerButton(ColorScheme colors, IconData icon, String text, String route) {
    return Container(
      height: (MediaQuery.of(context).size.width / 2) - 82,
      width: (MediaQuery.of(context).size.width / 2) - 44,
      decoration: BoxDecoration(
        border: Border.all(
          color: colors.primary,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextButton(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Expanded(
              child: Container(),
            ),
            Icon(
              icon,
              color: colors.primary,
              size: 32,
            ),
            Expanded(
              child: Container(),
            ),
            Text(
              text,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
          ],
        ),
        onPressed: () {
          Navigator.pushNamed(
            context,
            route,
          );
        },
      ),
    );
  }

  Widget completedRacesButton(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 70,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: colors.primary,
          width: 2,
        ),
      ),
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CompletedRacesPage(),
            ),
          );
        },
        child: Row(
          children: [
            Text(
              'my_races'.tr(),
              style: Theme.of(context).textTheme.displayMedium,
            ),
            Expanded(
              child: Container(),
            ),
            Icon(
              Icons.chevron_right,
              color: colors.primary,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }

  Widget newRaceButton(ColorScheme colors) {
    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width - 96,
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextButton(
        onPressed: () => {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateRacePage(),
            ),
          ),
        },
        child: Text(
          "new_race".tr(),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget continueRaceButton(ColorScheme colors) {
    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width - 96,
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextButton(
        onPressed: () => {},
        child: Text(
          "continue_race".tr(),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
