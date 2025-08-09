import 'package:flutter/material.dart';
import '../../common/colo_extension.dart';
import '../../models/workout_model.dart';
import '../../models/exercise_model.dart';
import '../../services/exercise_service.dart';
import 'workout_exercise_view.dart';

class WorkoutDetailView extends StatefulWidget {
  final WorkoutModel workout;
  final List<ExerciseModel> allExercises;

  const WorkoutDetailView({
    Key? key,
    required this.workout,
    required this.allExercises,
  }) : super(key: key);

  @override
  State<WorkoutDetailView> createState() => _WorkoutDetailViewState();
}

class _WorkoutDetailViewState extends State<WorkoutDetailView> {
  List<ExerciseModel> _catalog = [];
  bool _loadingCatalog = false;

  @override
  void initState() {
    super.initState();
    _loadExerciseCatalog();
  }

  Future<void> _loadExerciseCatalog() async {
    setState(() => _loadingCatalog = true);
    final catalog = await ExerciseService().getAllExercises();
    setState(() {
      _catalog = catalog;
      _loadingCatalog = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: TColor.lightGray,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              "assets/img/closed_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          widget.workout.name,
          style: TextStyle(
            color: TColor.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          InkWell(
            onTap: () {
              // TODO: More options
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: TColor.lightGray,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                "assets/img/more_btn.png",
                width: 15,
                height: 15,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: TColor.primaryG),
        ),
        child: Column(
          children: [
            // Header section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
              child: Column(
                children: [
                  Text(
                    widget.workout.name.toUpperCase(),
                    style: TextStyle(
                      color: TColor.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    widget.workout.description ?? "Workout được tạo tự động",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: TColor.white,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Workout stats
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Text(
                                "${widget.workout.exercises.length}",
                                style: TextStyle(
                                  color: TColor.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                "Bài tập",
                                style: TextStyle(
                                  color: TColor.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Text(
                                "${_calculateTotalTime()}",
                                style: TextStyle(
                                  color: TColor.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                "Phút",
                                style: TextStyle(
                                  color: TColor.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Text(
                                "${_calculateTotalCalories()}",
                                style: TextStyle(
                                  color: TColor.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                "Kcal",
                                style: TextStyle(
                                  color: TColor.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Exercise list
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: TColor.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Text(
                          "Bài tập",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "${widget.workout.exercises.length} bài tập",
                          style: TextStyle(
                            color: TColor.gray,
                            fontSize: 12,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Edit workout
                          },
                          child: Text(
                            "Chỉnh sửa",
                            style: TextStyle(
                              color: TColor.gray,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Exercise list
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: widget.workout.exercises.length,
                        itemBuilder: (context, index) {
                          final workoutExercise =
                              widget.workout.exercises[index];
                          final exercise =
                              _getExerciseById(workoutExercise.exerciseId);

                          return _buildExerciseRow(
                              exercise, workoutExercise, index);
                        },
                      ),
                    ),

                    // Start button
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: MaterialButton(
                        onPressed: () {
                          _startWorkout();
                        },
                        height: 50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        color: TColor.primaryColor1,
                        child: Text(
                          "Khởi đầu",
                          style: TextStyle(
                            color: TColor.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Get exercise by ID
  ExerciseModel _getExerciseById(String exerciseId) {
    // 1) Provided list (from parent)
    try {
      return widget.allExercises.firstWhere((ex) => ex.id == exerciseId);
    } catch (_) {}

    // 2) Local catalog we loaded (from Firestore)
    try {
      return _catalog.firstWhere((ex) => ex.id == exerciseId);
    } catch (_) {}

    // 3) Service fallback (default list)
    final exercise = ExerciseService().getExerciseById(exerciseId);
    if (exercise != null) return exercise;

    // 4) Last resort: placeholder
    return ExerciseModel(
      id: exerciseId,
      name: "Unknown Exercise",
      vietnameseName: "Bài tập không xác định",
      description: "Bài tập không xác định",
      exerciseType: "reps",
    );
  }

  // Calculate total workout time
  int _calculateTotalTime() {
    int totalSeconds = 0;

    for (var workoutExercise in widget.workout.exercises) {
      final exercise = _getExerciseById(workoutExercise.exerciseId);

      if (exercise.exerciseType == 'duration') {
        // Duration exercises: sum all set durations
        for (var set in workoutExercise.sets) {
          totalSeconds += set.duration ?? 30; // Default 30s if null
        }
      } else {
        // Reps exercises: estimate 2 seconds per rep
        for (var set in workoutExercise.sets) {
          totalSeconds += (set.reps ?? 10) * 2; // 2 seconds per rep
        }
      }

      // Add rest time between exercises (10s)
      totalSeconds += 10;
    }

    return (totalSeconds / 60).round(); // Convert to minutes
  }

  // Calculate estimated calories
  int _calculateTotalCalories() {
    // Simple estimation: 5 calories per minute
    return _calculateTotalTime() * 5;
  }

  // Build exercise row
  Widget _buildExerciseRow(
      ExerciseModel exercise, WorkoutExercise workoutExercise, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: TColor.lightGray,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          // Exercise image placeholder
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: TColor.gray.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              exercise.exerciseType == 'duration'
                  ? Icons.timer_outlined
                  : Icons.repeat,
              color: TColor.gray,
              size: 30,
            ),
          ),
          const SizedBox(width: 15),

          // Exercise info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.vietnameseName,
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getExerciseDescription(exercise, workoutExercise),
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Get exercise description
  String _getExerciseDescription(
      ExerciseModel exercise, WorkoutExercise workoutExercise) {
    if (exercise.exerciseType == 'duration') {
      final hasSet = workoutExercise.sets.isNotEmpty;
      final firstDuration =
          hasSet ? (workoutExercise.sets.first.duration ?? 30) : 30;
      return "${firstDuration}s";
    } else {
      final hasSet = workoutExercise.sets.isNotEmpty;
      final firstReps = hasSet ? workoutExercise.sets.first.reps : 10;
      return "x $firstReps";
    }
  }

  // Start workout
  void _startWorkout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutExerciseView(
          workout: widget.workout,
          allExercises: _catalog.isNotEmpty ? _catalog : widget.allExercises,
        ),
      ),
    );
  }
}
