import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

/// Provides step counting with a mock mode for emulator/testing.
class StepCounterProvider with ChangeNotifier {
  int _stepsToday = 0;
  bool _isMock = true;
  Timer? _mockTimer;
  DateTime _currentDay = DateTime.now();
  StreamSubscription<StepCount>? _stepSub;
  int?
      _baselineSteps; // steps at the moment of subscription (to compute daily delta)

  int get stepsToday => _stepsToday;
  bool get isMock => _isMock;

  /// Initialize the provider. By default runs in mock mode for emulator.
  void initialize({bool isMock = true}) {
    _isMock = isMock;
    _currentDay = _stripToDate(DateTime.now());
    if (_isMock) {
      _startMockTicker();
    } else {
      _startRealPedometer();
    }
  }

  void setMock(bool enabled) {
    if (_isMock == enabled) return;
    stop();
    _isMock = enabled;
    if (_isMock) {
      _startMockTicker();
    } else {
      _startRealPedometer();
    }
    notifyListeners();
  }

  void addSteps(int delta) {
    _maybeResetForNewDay();
    _stepsToday = (_stepsToday + delta).clamp(0, 1000000000);
    notifyListeners();
  }

  void resetToday() {
    _stepsToday = 0;
    notifyListeners();
  }

  void stop() {
    _mockTimer?.cancel();
    _mockTimer = null;
    _stepSub?.cancel();
    _stepSub = null;
  }

  void _startMockTicker() {
    final random = Random();
    _mockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _maybeResetForNewDay();
      // Simulate 2-4 steps per second so progress looks alive on emulator
      _stepsToday += 2 + random.nextInt(3);
      notifyListeners();
    });
  }

  Future<void> _startRealPedometer() async {
    // Request permission if needed (Android Q+ activity recognition)
    await Permission.activityRecognition.request();
    // Some devices return permanentlyDenied if in emulator; guard anyway
    if (await Permission.activityRecognition.isDenied) {
      // Fallback to mock if not granted
      _isMock = true;
      _startMockTicker();
      notifyListeners();
      return;
    }

    _baselineSteps = null;
    _stepSub = Pedometer.stepCountStream.listen((StepCount event) {
      _maybeResetForNewDay();
      // Many devices emit a cumulative step count since boot or since last reset.
      // We compute daily steps as (current - baseline at start of day/provider start).
      final current = event.steps;
      _baselineSteps ??= current;
      final computed = current - (_baselineSteps ?? 0);
      _stepsToday = computed.clamp(0, 1000000000);
      notifyListeners();
    }, onError: (Object err) {
      // If sensor not available, fallback to mock to keep UI functional
      _isMock = true;
      _startMockTicker();
      notifyListeners();
    });
  }

  void _maybeResetForNewDay() {
    final today = _stripToDate(DateTime.now());
    if (!_isSameDate(today, _currentDay)) {
      _currentDay = today;
      _stepsToday = 0;
    }
  }

  DateTime _stripToDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
