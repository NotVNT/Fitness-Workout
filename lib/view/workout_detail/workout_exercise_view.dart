import 'dart:async';
import 'package:flutter/material.dart';
import '../../common/colo_extension.dart';
import '../../models/workout_model.dart';
import '../../models/exercise_model.dart';
import '../../services/exercise_service.dart';

class WorkoutExerciseView extends StatefulWidget {
  final WorkoutModel workout;
  final List<ExerciseModel> allExercises;

  const WorkoutExerciseView({
    Key? key,
    required this.workout,
    required this.allExercises,
  }) : super(key: key);

  @override
  State<WorkoutExerciseView> createState() => _WorkoutExerciseViewState();
}

class _WorkoutExerciseViewState extends State<WorkoutExerciseView> {
  int currentExerciseIndex = 0;
  int currentSetIndex = 0;
  bool isResting = false;
  bool isPaused = false;
  bool isCompleted = false;

  Timer? _timer;
  int _currentTime = 0;
  int _restTime = 10; // 10 seconds rest

  ExerciseModel? currentExercise;
  WorkoutExercise? currentWorkoutExercise;

  @override
  void initState() {
    super.initState();
    _initializeCurrentExercise();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initializeCurrentExercise() {
    if (currentExerciseIndex < widget.workout.exercises.length) {
      currentWorkoutExercise = widget.workout.exercises[currentExerciseIndex];
      currentExercise = _getExerciseById(currentWorkoutExercise!.exerciseId);

      if (currentExercise!.exerciseType == 'duration') {
        _currentTime =
            currentWorkoutExercise!.sets[currentSetIndex].duration ?? 30;
      } else {
        _currentTime = currentWorkoutExercise!.sets[currentSetIndex].reps ?? 10;
      }

      setState(() {});
    }
  }

  ExerciseModel _getExerciseById(String exerciseId) {
    try {
      // First try to find in provided exercises
      return widget.allExercises.firstWhere((ex) => ex.id == exerciseId);
    } catch (e) {
      // If not found, try ExerciseService
      final exerciseService = ExerciseService();
      final exercise = exerciseService.getExerciseById(exerciseId);
      if (exercise != null) {
        return exercise;
      }

      // Fallback to unknown exercise
      return ExerciseModel(
        id: exerciseId,
        name: "Unknown Exercise",
        vietnameseName: "Bài tập không xác định",
        description: "Bài tập không xác định",
        exerciseType: "reps",
      );
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isPaused) {
        setState(() {
          if (isResting) {
            _restTime--;
            if (_restTime <= 0) {
              _nextExercise();
            }
          } else {
            if (currentExercise!.exerciseType == 'duration') {
              _currentTime--;
              if (_currentTime <= 0) {
                _completeCurrentSet();
              }
            }
          }
        });
      }
    });
  }

  void _pauseTimer() {
    setState(() {
      isPaused = !isPaused;
    });
  }

  void _completeCurrentSet() {
    // Move to next set or exercise
    if (currentSetIndex < currentWorkoutExercise!.sets.length - 1) {
      // Next set of same exercise
      currentSetIndex++;
      if (currentExercise!.exerciseType == 'duration') {
        _currentTime =
            currentWorkoutExercise!.sets[currentSetIndex].duration ?? 30;
      } else {
        _currentTime = currentWorkoutExercise!.sets[currentSetIndex].reps ?? 10;
      }
      setState(() {});
    } else {
      // Start rest period before next exercise
      _startRestPeriod();
    }
  }

  void _startRestPeriod() {
    if (currentExerciseIndex < widget.workout.exercises.length - 1) {
      setState(() {
        isResting = true;
        _restTime = 10;
      });
    } else {
      _completeWorkout();
    }
  }

  void _nextExercise() {
    currentExerciseIndex++;
    currentSetIndex = 0;

    if (currentExerciseIndex < widget.workout.exercises.length) {
      setState(() {
        isResting = false;
        _restTime = 10;
      });
      _initializeCurrentExercise();
    } else {
      _completeWorkout();
    }
  }

  void _completeWorkout() {
    _timer?.cancel();
    setState(() {
      isCompleted = true;
    });
  }

  void _skipExercise() {
    if (currentExerciseIndex < widget.workout.exercises.length - 1) {
      _startRestPeriod();
    } else {
      _completeWorkout();
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    if (isCompleted) {
      return _buildCompletionScreen();
    }

    if (isResting) {
      return _buildRestScreen();
    }

    return Scaffold(
      backgroundColor: TColor.white,
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back, color: TColor.black),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (currentExerciseIndex + 1) /
                          widget.workout.exercises.length,
                      backgroundColor: TColor.lightGray,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(TColor.primaryColor1),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    "${currentExerciseIndex + 1}/${widget.workout.exercises.length}",
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Exercise content
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Exercise image placeholder
                  Container(
                    width: media.width * 0.8,
                    height: media.width * 0.8,
                    decoration: BoxDecoration(
                      color: TColor.lightGray,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      currentExercise!.exerciseType == 'duration'
                          ? Icons.timer_outlined
                          : Icons.repeat,
                      color: TColor.gray,
                      size: 100,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Exercise name
                  Text(
                    currentExercise!.vietnameseName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Timer/Counter
                  Text(
                    currentExercise!.exerciseType == 'duration'
                        ? _formatTime(_currentTime)
                        : "x $_currentTime",
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Set info
                  Text(
                    "Set ${currentSetIndex + 1}/${currentWorkoutExercise!.sets.length}",
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Control buttons
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Main action button
                  MaterialButton(
                    onPressed: () {
                      if (currentExercise!.exerciseType == 'duration') {
                        if (_timer?.isActive == true) {
                          _pauseTimer();
                        } else {
                          _startTimer();
                        }
                      } else {
                        _completeCurrentSet();
                      }
                    },
                    height: 60,
                    minWidth: double.infinity,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    color: TColor.primaryColor1,
                    child: Text(
                      currentExercise!.exerciseType == 'duration'
                          ? (isPaused ? "TIẾP TỤC" : "TẠM DỪNG")
                          : "XONG",
                      style: TextStyle(
                        color: TColor.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Secondary buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            // Previous exercise (if available)
                            if (currentExerciseIndex > 0) {
                              currentExerciseIndex--;
                              currentSetIndex = 0;
                              _initializeCurrentExercise();
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.skip_previous, color: TColor.gray),
                              const SizedBox(width: 5),
                              Text(
                                "TRƯỚC ĐÓ",
                                style: TextStyle(color: TColor.gray),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: _skipExercise,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "BỎ QUA",
                                style: TextStyle(color: TColor.gray),
                              ),
                              const SizedBox(width: 5),
                              Icon(Icons.skip_next, color: TColor.gray),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestScreen() {
    return Scaffold(
      backgroundColor: TColor.primaryColor1,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.self_improvement,
              color: TColor.white,
              size: 100,
            ),
            const SizedBox(height: 30),
            Text(
              "NGHỈ NGƠI",
              style: TextStyle(
                color: TColor.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _formatTime(_restTime),
              style: TextStyle(
                color: TColor.white,
                fontSize: 48,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 30),
            if (currentExerciseIndex + 1 < widget.workout.exercises.length)
              Text(
                "Tiếp theo: ${_getExerciseById(widget.workout.exercises[currentExerciseIndex + 1].exerciseId).vietnameseName}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TColor.white,
                  fontSize: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionScreen() {
    return Scaffold(
      backgroundColor: TColor.primaryColor1,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.celebration,
              color: TColor.white,
              size: 100,
            ),
            const SizedBox(height: 30),
            Text(
              "HOÀN THÀNH!",
              style: TextStyle(
                color: TColor.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Bạn đã hoàn thành workout",
              style: TextStyle(
                color: TColor.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 50),
            MaterialButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              height: 50,
              minWidth: 200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              color: TColor.white,
              child: Text(
                "HOÀN THÀNH",
                style: TextStyle(
                  color: TColor.primaryColor1,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }
}
