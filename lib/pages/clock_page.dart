import 'dart:async';

import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class ClockPage extends StatefulWidget {
  const ClockPage({super.key});

  @override
  State<ClockPage> createState() => _ClockPageState();
}

class _ClockPageState extends State<ClockPage> {
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;
  bool _isRunning = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (!_isRunning) {
      final now = DateTime.now();
      setState(() {
        _hours = now.hour;
        _minutes = now.minute;
        _seconds = now.second;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Container()),
            clockWidget(colors),
            Expanded(child: Container()),
            startButton(colors),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget clockWidget(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        border: Border.all(color: colors.primary, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _timeUnit(colors, _hours, 23, _isRunning ? null : (val) => setState(() => _hours = val), 'hrs'),
          const SizedBox(width: 8),
          Text(':', style: TextStyle(color: colors.primary, fontSize: 24)),
          const SizedBox(width: 8),
          _timeUnit(colors, _minutes, 59, _isRunning ? null : (val) => setState(() => _minutes = val), 'min'),
          const SizedBox(width: 8),
          Text(':', style: TextStyle(color: colors.primary, fontSize: 24)),
          const SizedBox(width: 8),
          _timeUnit(colors, _seconds, 59, _isRunning ? null : (val) => setState(() => _seconds = val), 'sec'),
        ],
      ),
    );
  }

  Widget startButton(ColorScheme colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 60,
          width: 160,
          decoration: BoxDecoration(
            color: _isRunning ? colors.error : colors.primary,
            borderRadius: BorderRadius.circular(25),
          ),
          child: TextButton(
            onPressed: () {
              setState(() {
                _isRunning = !_isRunning;
                if (_isRunning) {
                  _startTimer();
                } else {
                  _stopTimer();
                }
              });
            },
            child: Text(
              _isRunning ? 'Stop' : 'Start',
              style: TextStyle(color: colors.onPrimary),
            ),
          ),
        ),
      ],
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(
        () {
          _seconds++;
          if (_seconds >= 60) {
            _seconds = 0;
            _minutes++;
            if (_minutes >= 60) {
              _minutes = 0;
              _hours++;
              if (_hours >= 24) {
                _hours = 0;
              }
            }
          }
        },
      );
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  Widget _timeUnit(ColorScheme colors, int value, int maxValue, ValueChanged<int>? onChanged, String label) {
    return Column(
      children: [
        SizedBox(
          width: 60, // Fixed width container
          child: NumberPicker(
            value: value,
            minValue: 0,
            maxValue: maxValue,
            itemCount: 1,
            itemHeight: 54,
            itemWidth: 60,
            axis: Axis.vertical,
            onChanged: onChanged ?? (val) {},
            textStyle: TextStyle(
              color: colors.onSurface,
              fontSize: 40,
            ),
            selectedTextStyle: TextStyle(
              color: colors.primary,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: colors.primary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
