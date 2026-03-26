import 'package:circuito/services/race_timer_service.dart';
import 'package:circuito/utils/navigation.dart';
import 'package:flutter/material.dart';

/// Persistent overlay banner shown at the top of the screen whenever a race
/// timer is running but the race page is not currently visible.
/// Tapping it navigates back to the active race page.
class RaceTimerBanner extends StatelessWidget {
  const RaceTimerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: RaceTimerService.instance,
      builder: (context, _) {
        final service = RaceTimerService.instance;
        if (!service.isRunning || service.isRacePageVisible) {
          return const SizedBox.shrink();
        }

        return Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          right: 16,
          child: GestureDetector(
            onTap: () {
              final builder = service.racePageBuilder;
              if (builder != null) {
                appNavigatorKey.currentState?.push(
                  MaterialPageRoute(builder: builder),
                );
              }
            },
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[700]!, width: 2),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer, color: Colors.green[400], size: 18),
                    const SizedBox(width: 8),
                    Text(
                      service.displayLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontFamily: 'Raleway',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      service.displayTimeString,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Raleway',
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
