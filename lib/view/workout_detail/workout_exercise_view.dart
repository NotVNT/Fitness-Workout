import 'dart:async';
import 'package:flutter/material.dart';
import '../../common/colo_extension.dart';
import '../../models/workout_model.dart';
import '../../models/exercise_model.dart';
import '../../services/exercise_service.dart';

import '../../services/workout_service.dart';


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
  int _restTime = 10; // 10 seconds rest between exercises
  bool _restForNextSet =
      false; // true = đang nghỉ để sang set tiếp theo (5 phút)


  // Display list limited to 3 unique exercises by exerciseId
  List<WorkoutExercise> _displayExercises = [];
  // Mapping from display index -> original index in workout.exercises
  List<int> _originalIndices = [];



  // Build display list once from the workout: 3 unique by exerciseId
  void _buildDisplayExercises() {
    final seen = <String>{};
    _displayExercises = [];
    _originalIndices = [];
    for (var i = 0; i < widget.workout.exercises.length; i++) {
      final we = widget.workout.exercises[i];
      if (seen.add(we.exerciseId)) {
        _displayExercises.add(we);
        _originalIndices.add(i);
        if (_displayExercises.length >= 3) break;
      }
    }
  }

  ExerciseModel? currentExercise;
  WorkoutExercise? currentWorkoutExercise;

  @override
  void initState() {
    super.initState();
    _buildDisplayExercises();
    _initializeCurrentExercise();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initializeCurrentExercise() {
    if (currentExerciseIndex < _displayExercises.length) {
      currentWorkoutExercise = _displayExercises[currentExerciseIndex];
      currentExercise = _getExerciseById(currentWorkoutExercise!.exerciseId);

      if (currentExercise!.exerciseType == 'duration') {
        final sets = currentWorkoutExercise!.sets;

        final idx = (currentSetIndex >= 0 && currentSetIndex < sets.length)
            ? currentSetIndex
            : 0;
        _currentTime = sets.isNotEmpty ? (sets[idx].duration ?? 30) : 30;

        // Tự động bắt đầu đếm khi là bài tập theo thời gian
        isPaused = false;
        _startTimer();
      } else {
        // Bài tập theo reps không dùng timer, đảm bảo tắt timer cũ nếu có
        _timer?.cancel();
        isPaused = false;
        _currentTime = 0; // không dùng _currentTime cho reps
      }

      setState(() {});
    } else {
      _timer?.cancel();
    }
  }

  ExerciseModel _getExerciseById(String exerciseId) {

    // Ưu tiên danh sách truyền từ parent (đã load Firestore với imageAsset)
    try {
      return widget.allExercises.firstWhere((ex) => ex.id == exerciseId);
    } catch (_) {}

    // Fallback: ExerciseService default list
    final exercise = ExerciseService().getExerciseById(exerciseId);
    if (exercise != null) return exercise;

    // Cuối cùng: placeholder
    return ExerciseModel(
      id: exerciseId,
      name: "Unknown Exercise",
      vietnameseName: "Bài tập không xác định",
      description: "Bài tập không xác định",
      exerciseType: "reps",
    );

  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restTime < 0) _restTime = 0;
      if (!isPaused) {
        setState(() {
          if (isResting) {
            _restTime--;
            if (_restTime <= 0) {

              if (_restForNextSet) {
                // Hết nghỉ giữa các set: sang set tiếp theo của cùng bài
                _restForNextSet = false;
                isResting = false;
                currentSetIndex++;
                // Nếu bài theo thời gian thì set lại thời gian từ set kế tiếp, nếu reps thì không cần
                if (currentExercise!.exerciseType == 'duration') {
                  final sets = currentWorkoutExercise!.sets;
                  final nextDur = (sets[currentSetIndex].duration ?? 30);
                  _currentTime = nextDur;
                  _timer?.cancel();
                  _startTimer();
                }
              } else {
                // Hết nghỉ giữa các bài: sang bài tiếp theo
                _nextExercise();
              }

            }
          } else {
            if (currentExercise!.exerciseType == 'duration') {
              _currentTime--;
              if (_currentTime <= 0) {
                _completeCurrentSet();

                return; // dừng xử lý tick này để tránh đếm chồng

              }
            }
            // Với bài reps không đếm, không thay đổi _currentTime ở đây
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


  Future<void> _completeCurrentSet() async {
    // Đánh dấu set hiện tại hoàn thành trong Firestore
    await _markCurrentSetCompletedInDb();

    // Nếu bài này còn set tiếp theo thì nghỉ 5 phút, còn không thì nghỉ 10s sang bài mới
    final sets = currentWorkoutExercise?.sets ?? [];
    final hasNextSet = currentSetIndex + 1 < sets.length;
    if (hasNextSet) {
      // Nghỉ 1 phút giữa các set
      setState(() {
        isResting = true;
        _restForNextSet = true;
        _restTime = 60; // 1 phút
      });
      _startTimer();
    } else {
      // Sang bài tiếp theo (nghỉ 10s)
      _startRestPeriod();
    }
  }

  void _startRestPeriod() {
    // Nghỉ giữa bài hiện tại và bài tiếp theo (1 phút)
    if (currentExerciseIndex < _displayExercises.length - 1) {
      setState(() {
        isResting = true;
        isPaused = false;
        _restForNextSet = false;
        _restTime = 60;
      });
      _startTimer(); // đảm bảo bắt đầu đếm nghỉ ngay

    } else {
      _completeWorkout();
    }
  }

  void _nextExercise() {
    currentExerciseIndex++;
    currentSetIndex = 0;

    if (currentExerciseIndex < _displayExercises.length) {
      setState(() {
        isResting = false;
        _restTime = 60;
      });
      _initializeCurrentExercise();
    } else {
      _completeWorkout();
    }
  }

  void _completeWorkout() async {
    _timer?.cancel();
    try {
      // Đánh dấu workout hoàn thành trên Firestore
      await WorkoutService.completeWorkout(widget.workout.userId, widget.workout.id);
    } catch (e) {
      debugPrint('Không thể đánh dấu workout hoàn thành: $e');
    }
    setState(() {
      isCompleted = true;
    });
  }

  void _skipExercise() {
    if (currentExerciseIndex < _displayExercises.length - 1) {
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
                          _displayExercises.length,
                      backgroundColor: TColor.lightGray,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(TColor.primaryColor1),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    "${currentExerciseIndex + 1}/${_displayExercises.length}",
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Exercise content (scrollable + responsive size to avoid overflow)
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxH = constraints.maxHeight;
                  final baseSize = media.width * 0.8;
                  final imageSize = baseSize > maxH * 0.5
                      ? maxH * 0.5
                      : baseSize; // <= 50% viewport height

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: maxH - 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          Container(
                            width: imageSize,
                            height: imageSize,
                            decoration: BoxDecoration(
                              color: TColor.lightGray,
                              borderRadius: BorderRadius.circular(20),
                            ),

                            child: () {
                              String raw =
                                  (currentExercise!.imageAsset ?? '').trim();
                              if (raw.length >= 2) {
                                final hasDouble =
                                    raw.startsWith('"') && raw.endsWith('"');
                                final hasSingle =
                                    raw.startsWith("'") && raw.endsWith("'");
                                if (hasDouble || hasSingle) {
                                  raw = raw.substring(1, raw.length - 1).trim();
                                }
                              }
                              if (raw.isNotEmpty) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    raw,
                                    fit: BoxFit.contain,
                                  ),
                                );
                              }
                              return Icon(
                                currentExercise!.exerciseType == 'duration'
                                    ? Icons.timer_outlined
                                    : Icons.repeat,
                                color: TColor.gray,
                                size: 100,
                              );
                            }(),

                          ),

                          const SizedBox(height: 24),

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

                          const SizedBox(height: 24),

                          // Timer/Counter
                          Text(
                            currentExercise!.exerciseType == 'duration'
                                ? _formatTime(_currentTime)
                                : "x ${currentWorkoutExercise!.sets.isNotEmpty ? currentWorkoutExercise!.sets.first.reps : 0}",
                            style: TextStyle(
                              color: TColor.black,
                              fontSize: 48,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 16),


                          const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  );
                },
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.self_improvement,
                color: TColor.white,
                size: 100,
              ),
              const SizedBox(height: 30),
              Text(
                "NGHỈ NGƠI",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TColor.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _formatTime(_restTime),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TColor.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 30),
              if (currentExerciseIndex + 1 < _displayExercises.length)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Tiếp theo: ${_getExerciseById(_displayExercises[currentExerciseIndex + 1].exerciseId).vietnameseName}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: TColor.white,
                      fontSize: 16,
                    ),
                  ),
                ),

              const SizedBox(height: 30),

              // Skip rest button
              MaterialButton(
                onPressed: () {
                  // Bỏ qua thời gian nghỉ, chuyển ngay sang bài tiếp theo
                  _timer?.cancel();
                  _nextExercise();
                },
                height: 50,
                minWidth: 200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                color: TColor.white,
                child: Text(
                  "BỎ QUA NGHỈ",
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
      ),
    );
  }

  Widget _buildCompletionScreen() {
    return Scaffold(
      backgroundColor: TColor.primaryColor1,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.celebration,
                color: TColor.white,
                size: 100,
              ),
              const SizedBox(height: 30),
              Text(
                "HOÀN THÀNH!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TColor.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Bạn đã hoàn thành workout",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: TColor.white,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 50),
              // Centered button
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
      ),
    );
  }


  Future<void> _markCurrentSetCompletedInDb() async {
    try {
      final sets = currentWorkoutExercise?.sets ?? [];
      if (currentExerciseIndex >= _displayExercises.length ||
          currentSetIndex >= sets.length) {
        return;
      }

      // Cập nhật local model trước để UI cảm nhận nhanh
      sets[currentSetIndex] = sets[currentSetIndex].copyWith(isCompleted: true);

      // Ghi lên Firestore: update workout.exercises array toàn bộ
      // Cần ánh xạ chỉ số hiển thị (đã lọc unique) sang chỉ số gốc trong workout
      final originalIdx = (currentExerciseIndex < _originalIndices.length)
          ? _originalIndices[currentExerciseIndex]
          : currentExerciseIndex;
      final updatedExercises = widget.workout.exercises.asMap().entries.map((e) {
        final idx = e.key;
        final we = e.value;
        if (idx == originalIdx) {
          return WorkoutExercise(
            exerciseId: we.exerciseId,
            exercise: we.exercise,
            sets: sets,
            notes: we.notes,
            order: we.order,
          );
        }
        return we;
      }).toList();

      final updatedWorkout =
          widget.workout.copyWith(exercises: updatedExercises);
      await WorkoutService.updateWorkout(updatedWorkout);
    } catch (e) {
      debugPrint('Không thể cập nhật set hoàn thành: $e');
    }
  }


  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }
}
