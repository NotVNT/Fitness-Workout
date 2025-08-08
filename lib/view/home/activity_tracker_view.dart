import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../common/colo_extension.dart';
import '../../common_widget/latest_activity_row.dart';
import '../../common_widget/today_target_cell.dart';
import '../../common_widget/icon_text_button.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/user_provider.dart';
import '../../models/exercise_model.dart';
import '../../models/workout_model.dart';
import '../../services/workout_service.dart';

class ActivityTrackerView extends StatefulWidget {
  const ActivityTrackerView({super.key});

  @override
  State<ActivityTrackerView> createState() => _ActivityTrackerViewState();
}

class _ActivityTrackerViewState extends State<ActivityTrackerView> {
  int touchedIndex = -1;
  List<ExerciseModel> exercises = [];
  bool isLoadingExercises = true;
  WorkoutModel? todayWorkout;
  bool isLoadingTodayWorkout = true;

  List latestArr = [
    {
      "image": "assets/img/pic_4.png",
      "title": "Drinking 300ml Water",
      "time": "About 1 minutes ago"
    },
    {
      "image": "assets/img/pic_5.png",
      "title": "Eat Snack (Fitbar)",
      "time": "About 3 hours ago"
    },
  ];

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
        isLoadingExercises = false;
      });

      print('🏃 ActivityTracker: Đã load ${exercises.length} exercises');
      for (var ex in exercises) {
        print('🏃 - ${ex.name} (${ex.vietnameseName}) - ${ex.exerciseType}');
      }
    } catch (e) {
      setState(() {
        isLoadingExercises = false;
      });
      print('🏃 ActivityTracker: Lỗi load exercises: $e');
    }
  }

  // Load workout hôm nay
  Future<void> _loadTodayWorkout() async {
    try {
      print('🏃 ActivityTracker: Đang load workout hôm nay...');

      // Cần userId - tạm thời hardcode, sau này lấy từ Provider
      const String userId =
          "RzvF1bJ52QQ9ubgovV7AeKnn4Ok2"; // TODO: Lấy từ UserProvider

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
          "Activity Tracker",
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
                          "Today Target",
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
                    const Row(
                      children: [
                        Expanded(
                          child: TodayTargetCell(
                            icon: "assets/img/water.png",
                            value: "8L",
                            title: "Water Intake",
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: TodayTargetCell(
                            icon: "assets/img/foot.png",
                            value: "2400",
                            title: "Foot Steps",
                          ),
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
                    "Bài tập hôm nay",
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
                                "Chưa có bài tập hôm nay",
                                style: TextStyle(
                                  color: TColor.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Hãy cập nhật BMI để tạo bài tập 7 ngày",
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
                                            todayWorkout!.name,
                                            style: TextStyle(
                                              color: TColor.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            "${todayWorkout!.exercises.length} bài tập",
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
                              ),
                              // Danh sách exercises của workout hôm nay
                              ...todayWorkout!.exercises
                                  .take(3)
                                  .map((workoutExercise) {
                                if (workoutExercise.exercise != null) {
                                  return _buildCompactExerciseCard(
                                      workoutExercise.exercise!);
                                } else {
                                  // Nếu exercise null, tìm trong danh sách exercises đã load
                                  final exercise = exercises.firstWhere(
                                    (ex) => ex.id == workoutExercise.exerciseId,
                                    orElse: () => exercises.isNotEmpty
                                        ? exercises.first
                                        : ExerciseModel(
                                            id: workoutExercise.exerciseId,
                                            name: "Unknown Exercise",
                                            vietnameseName:
                                                "Bài tập không xác định",
                                            description:
                                                "Bài tập không xác định",
                                            exerciseType: "reps",
                                          ),
                                  );
                                  return _buildCompactExerciseCard(exercise);
                                }
                              }),
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
                    "Activity  Progress",
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
                          items: ["Weekly", "Monthly"]
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
                            "Weekly",
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
                child: BarChart(BarChartData(
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => Colors.grey,
                      tooltipHorizontalAlignment: FLHorizontalAlignment.right,
                      tooltipMargin: 10,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String weekDay;
                        switch (group.x) {
                          case 0:
                            weekDay = 'Monday';
                            break;
                          case 1:
                            weekDay = 'Tuesday';
                            break;
                          case 2:
                            weekDay = 'Wednesday';
                            break;
                          case 3:
                            weekDay = 'Thursday';
                            break;
                          case 4:
                            weekDay = 'Friday';
                            break;
                          case 5:
                            weekDay = 'Saturday';
                            break;
                          case 6:
                            weekDay = 'Sunday';
                            break;
                          default:
                            throw Error();
                        }
                        return BarTooltipItem(
                          '$weekDay\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: (rod.toY - 1).toString(),
                              style: TextStyle(
                                color: TColor.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    touchCallback: (FlTouchEvent event, barTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            barTouchResponse == null ||
                            barTouchResponse.spot == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex =
                            barTouchResponse.spot!.touchedBarGroupIndex;
                      });
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: getTitles,
                        reservedSize: 38,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  barGroups: showingGroups(),
                  gridData: FlGridData(show: false),
                )),
              ),
              SizedBox(
                height: media.width * 0.05,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)?.latestWorkout ??
                        "Latest Workout",
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

  Widget getTitles(double value, TitleMeta meta) {
    var style = TextStyle(
      color: TColor.gray,
      fontWeight: FontWeight.w500,
      fontSize: 12,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = Text(AppLocalizations.of(context)?.sun ?? 'Sun', style: style);
        break;
      case 1:
        text = Text(AppLocalizations.of(context)?.mon ?? 'Mon', style: style);
        break;
      case 2:
        text = Text(AppLocalizations.of(context)?.tue ?? 'Tue', style: style);
        break;
      case 3:
        text = Text(AppLocalizations.of(context)?.wed ?? 'Wed', style: style);
        break;
      case 4:
        text = Text(AppLocalizations.of(context)?.thu ?? 'Thu', style: style);
        break;
      case 5:
        text = Text(AppLocalizations.of(context)?.fri ?? 'Fri', style: style);
        break;
      case 6:
        text = Text(AppLocalizations.of(context)?.sat ?? 'Sat', style: style);
        break;
      default:
        text = Text('', style: style);
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: text,
    );
  }

  List<BarChartGroupData> showingGroups() => List.generate(7, (i) {
        switch (i) {
          case 0:
            return makeGroupData(0, 5, TColor.primaryG,
                isTouched: i == touchedIndex);
          case 1:
            return makeGroupData(1, 10.5, TColor.secondaryG,
                isTouched: i == touchedIndex);
          case 2:
            return makeGroupData(2, 5, TColor.primaryG,
                isTouched: i == touchedIndex);
          case 3:
            return makeGroupData(3, 7.5, TColor.secondaryG,
                isTouched: i == touchedIndex);
          case 4:
            return makeGroupData(4, 15, TColor.primaryG,
                isTouched: i == touchedIndex);
          case 5:
            return makeGroupData(5, 5.5, TColor.secondaryG,
                isTouched: i == touchedIndex);
          case 6:
            return makeGroupData(6, 8.5, TColor.primaryG,
                isTouched: i == touchedIndex);
          default:
            return throw Error();
        }
      });

  BarChartGroupData makeGroupData(
    int x,
    double y,
    List<Color> barColor, {
    bool isTouched = false,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          gradient: LinearGradient(
              colors: barColor,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
          width: width,
          borderSide: isTouched
              ? const BorderSide(color: Colors.green)
              : const BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 20,
            color: TColor.lightGray,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
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
