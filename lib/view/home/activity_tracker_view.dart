
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';


import '../../common/colo_extension.dart';

import '../../common_widget/today_target_cell.dart';
import '../../common_widget/icon_text_button.dart';

import '../../common_widget/activity_progress_chart.dart';




import '../../models/exercise_model.dart';
import '../../models/workout_model.dart';
import '../../services/workout_service.dart';
import '../../providers/step_counter_provider.dart';

import '../../providers/user_provider.dart';

class ActivityTrackerView extends StatefulWidget {
  const ActivityTrackerView({super.key});

  @override
  State<ActivityTrackerView> createState() => _ActivityTrackerViewState();
}

class _ActivityTrackerViewState extends State<ActivityTrackerView> {
  List<ExerciseModel> exercises = [];

  WorkoutModel? todayWorkout;
  bool isLoadingTodayWorkout = true;



  @override
  void initState() {
    super.initState();
    _loadExercises();
    _loadTodayWorkout();
  }

  // Load exercises từ Firestore
  Future<void> _loadExercises() async {
    try {
      print('🏃 ActivityTracker: Đang load exercises từ Firestore...');

      final snapshot =
          await FirebaseFirestore.instance.collection('exercises').get();

      List<ExerciseModel> loadedExercises = [];
      for (var doc in snapshot.docs) {
        try {
          final exercise = ExerciseModel.fromFirestore(doc);
          loadedExercises.add(exercise);
        } catch (e) {
          print('🏃 ActivityTracker: Lỗi convert exercise ${doc.id}: $e');
        }
      }

      setState(() {
        exercises = loadedExercises;
      });

      print('🏃 ActivityTracker: Đã load ${exercises.length} exercises');
      for (var ex in exercises) {
        print('🏃 - ${ex.name} (${ex.vietnameseName}) - ${ex.exerciseType}');
      }
    } catch (e) {

      print('🏃 ActivityTracker: Lỗi load exercises: $e');
    }
  }

  // Load workout hôm nay
  Future<void> _loadTodayWorkout() async {
    try {
      print('🏃 ActivityTracker: Đang load workout hôm nay...');

      // Lấy userId từ UserProvider thay vì hardcode
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      String? userId = userProvider.user?.id;
      if (userId == null || userId.isEmpty) {
        // Thử load user data nếu chưa có
        await userProvider.loadUserData();
        userId = userProvider.user?.id;
        if (userId == null || userId.isEmpty) {
          setState(() {
            isLoadingTodayWorkout = false;
          });
          return;
        }
      }

      final workout = await WorkoutService.getTodayWorkout(userId);

      setState(() {
        todayWorkout = workout;
        isLoadingTodayWorkout = false;
      });

      if (workout != null) {
        print('🏃 ActivityTracker: Đã load workout hôm nay: ${workout.name}');
        print(
            '🏃 ActivityTracker: Workout có ${workout.exercises.length} bài tập');
      } else {
        print('🏃 ActivityTracker: Không có workout hôm nay');
      }
    } catch (e) {
      setState(() {
        isLoadingTodayWorkout = false;
      });
      print('🏃 ActivityTracker: Lỗi load workout hôm nay: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
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
                borderRadius: BorderRadius.circular(10)),
            child: Image.asset(
              "assets/img/black_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          (Localizations.localeOf(context).languageCode == 'en')
              ? 'Activity Tracker'
              : 'Theo dõi hoạt động',
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          InkWell(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: TColor.lightGray,
                  borderRadius: BorderRadius.circular(10)),
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
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    TColor.primaryColor2.withValues(alpha: 0.3),
                    TColor.primaryColor1.withValues(alpha: 0.3)
                  ]),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          (Localizations.localeOf(context).languageCode == 'en')
                              ? 'Today Target'
                              : 'Mục tiêu hôm nay',
                          style: TextStyle(
                              color: TColor.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: TColor.primaryG,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: MaterialButton(
                                onPressed: () {},
                                padding: EdgeInsets.zero,
                                height: 30,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)),
                                textColor: TColor.primaryColor1,
                                minWidth: double.maxFinite,
                                elevation: 0,
                                color: Colors.transparent,
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 15,
                                )),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TodayTargetCell(
                            icon: "assets/img/water.png",
                            value: "8L",
                            title: (Localizations.localeOf(context).languageCode == 'en') ? 'Drink water' : 'Uống nước',
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: Builder(builder: (context) {
                            final steps =
                                context.watch<StepCounterProvider>().stepsToday;
                            return TodayTargetCell(
                              icon: "assets/img/foot.png",
                              value: steps.toString(),
                              title: (Localizations.localeOf(context).languageCode == 'en') ? 'Steps' : 'Bước chân',
                            );
                          }),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(
                height: media.width * 0.05,
              ),

              // Section Bài tập hôm nay
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    (Localizations.localeOf(context).languageCode == 'en') ? 'Today Workout' : 'Bài tập hôm nay',
                    style: TextStyle(
                        color: TColor.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    onPressed: () {
                      // TODO: Navigate to all exercises
                    },
                    icon: Icon(
                      Icons.more_horiz,
                      color: TColor.gray,
                      size: 20,
                    ),
                  )
                ],
              ),
              SizedBox(
                height: media.width * 0.02,
              ),

              // Hiển thị workout hôm nay
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                decoration: BoxDecoration(
                  color: TColor.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 2)
                  ],
                ),
                child: isLoadingTodayWorkout
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : todayWorkout == null
                        ? Column(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 40,
                                color: TColor.gray,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                (Localizations.localeOf(context).languageCode == 'en') ? 'No workout for today' : 'Chưa có bài tập hôm nay',
                                style: TextStyle(
                                  color: TColor.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                (Localizations.localeOf(context).languageCode == 'en') ? 'Please update BMI to generate 7-day workouts' : 'Hãy cập nhật BMI để tạo bài tập 7 ngày',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: TColor.gray,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              // Header workout hôm nay
                              Container(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            colors: TColor.primaryG),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.today,
                                        color: TColor.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _cleanTitle(todayWorkout!.name),
                                            style: TextStyle(
                                              color: TColor.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            (Localizations.localeOf(context).languageCode == 'en')
                                                ? "${todayWorkout!.exercises.length} exercises"
                                                : "${todayWorkout!.exercises.length} bài tập",
                                            style: TextStyle(
                                              color: TColor.gray,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(todayWorkout!.status),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (todayWorkout!.status == 'completed') ...[
                                            Icon(Icons.check, size: 12, color: TColor.white),
                                            const SizedBox(width: 4),
                                          ],
                                          Text(
                                            _getStatusText(todayWorkout!.status),
                                            style: TextStyle(
                                              color: TColor.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Danh sách exercises của workout hôm nay (chọn 3 bài không trùng)
                              ...(() {
                                final seen = <String>{};
                                final selected = todayWorkout!.exercises.where((we) {
                                  if (seen.contains(we.exerciseId)) return false;
                                  seen.add(we.exerciseId);
                                  return true;
                                }).take(3).toList();
                                return selected.map((workoutExercise) {
                                  if (workoutExercise.exercise != null) {
                                    return _buildCompactExerciseCard(workoutExercise.exercise!);
                                  } else {
                                    // Nếu exercise null, tìm trong danh sách exercises đã load
                                    final exercise = exercises.firstWhere(
                                      (ex) => ex.id == workoutExercise.exerciseId,
                                      orElse: () => exercises.isNotEmpty
                                          ? exercises.first
                                          : ExerciseModel(
                                              id: workoutExercise.exerciseId,
                                              name: "Unknown Exercise",
                                              vietnameseName: "Không xác định",
                                              description: "Không xác định",
                                              exerciseType: "reps",
                                            ),
                                    );
                                    return _buildCompactExerciseCard(exercise);
                                  }
                                }).toList();
                              }()),
                            ],
                          ),
              ),

              SizedBox(
                height: media.width * 0.05,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    (Localizations.localeOf(context).languageCode == 'en') ? 'Activity Progress' : 'Tiến độ hoạt động',
                    style: TextStyle(
                        color: TColor.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  Container(
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: TColor.primaryG),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          items: [
                                (Localizations.localeOf(context).languageCode == 'en') ? 'Weekly' : 'Tuần',
                                (Localizations.localeOf(context).languageCode == 'en') ? 'Monthly' : 'Tháng'
                              ]
                              .map((name) => DropdownMenuItem(
                                    value: name,
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                          color: TColor.gray, fontSize: 14),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {},
                          icon: Icon(Icons.expand_more, color: TColor.white),
                          hint: Text(
                            (Localizations.localeOf(context).languageCode == 'en') ? 'Weekly' : 'Tuần',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: TColor.white, fontSize: 12),
                          ),
                        ),
                      )),
                ],
              ),
              SizedBox(
                height: media.width * 0.05,
              ),
              Container(
                height: media.width * 0.5,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 0),
                decoration: BoxDecoration(
                    color: TColor.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 3)
                    ]),
                child: ActivityProgressChart(
                  values: const [5, 10.5, 5, 7.5, 15, 5.5, 8.5],
                  labels: const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
                ),
              ),
              SizedBox(
                height: media.width * 0.05,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    (Localizations.localeOf(context).languageCode == 'en') ? 'Latest Workout' : 'Bài tập gần đây',
                    style: TextStyle(
                        color: TColor.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  IconTextButton(
                    icon: Icons.arrow_forward,
                    iconSize: 20,
                    onPressed: () {},
                  )
                ],
              ),

              SizedBox(
                height: media.width * 0.1,
              ),
            ],
          ),
        ),
      ),
    );
  }


  // Get exercise icon based on type
  IconData _getExerciseIcon(String exerciseType) {
    switch (exerciseType) {
      case 'duration':
        return Icons.timer_outlined;
      case 'reps':
        return Icons.repeat;
      default:
        return Icons.fitness_center;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'planned':
        return TColor.primaryColor1;
      case 'in_progress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return TColor.gray;
    }
  }

  // Xóa bớt cụm ' - Thứ ...' khỏi tiêu đề cho gọn
  String _cleanTitle(String title) {
    return title
        .replaceAll(RegExp(r"\s*-?\s*Thứ\s*[A-Za-zÀ-ỹ]+", caseSensitive: false), '')
        .trim();
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'planned':
        return 'Đã lên kế hoạch';
      case 'in_progress':
        return 'Đang thực hiện';
      case 'completed':
        return 'Đã hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }


  // Build compact exercise card cho Today Target section
  Widget _buildCompactExerciseCard(ExerciseModel exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: exercise.exerciseType == 'duration'
            ? TColor.primaryColor1.withValues(alpha: 0.1)
            : TColor.secondaryColor1.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: exercise.exerciseType == 'duration'
              ? TColor.primaryColor1.withValues(alpha: 0.3)
              : TColor.secondaryColor1.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          print('🏃 Clicked compact exercise: ${exercise.name}');
          // TODO: Navigate to exercise detail or start exercise
        },
        child: Row(
          children: [
            // Exercise icon
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: exercise.exerciseType == 'duration'
                      ? TColor.primaryG
                      : TColor.secondaryG,
                ),
                borderRadius: BorderRadius.circular(17.5),
              ),
              child: Icon(
                _getExerciseIcon(exercise.exerciseType),
                color: TColor.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),

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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    exercise.name,
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Exercise type badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: exercise.exerciseType == 'duration'
                    ? TColor.primaryColor1
                    : TColor.secondaryColor1,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                exercise.exerciseType == 'duration' ? 'Thời gian' : 'Số lần',
                style: TextStyle(
                  color: TColor.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
