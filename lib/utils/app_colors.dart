import 'package:flutter/material.dart';

class AppColors {
  // Lap delta colours — F1-inspired, used in laps race pages
  static const Color lapFastest = Color(0xFF9B00FF); // purple — personal best
  static const Color lapGain    = Color(0xFF00C800); // green  — faster than reference
  static const Color lapLoss    = Color(0xFFE8002D); // red    — slower than reference

  // Race state colours used across race pages
  static const Color activeRaceBorder = Color(0xFF2E7D32); // green[800]
  static const Color startButton      = Color(0xFF2E7D32); // green[800]
  static const Color raceActiveGreen  = Color(0xFF43A047); // green[600] — "in progress" label
}
