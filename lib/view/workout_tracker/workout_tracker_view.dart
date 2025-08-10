import 'package:fitness/common/colo_extension.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common_widget/round_button.dart';
import '../../common_widget/upcoming_workout_row.dart';
import '../../common_widget/icon_text_button.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/user_provider.dart';
import '../../services/workout_service.dart';
import '../../services/exercise_service.dart';
import '../../models/workout_model.dart';
import '../../models/exercise_model.dart';
import '../workout_detail/workout_detail_view.dart';

class WorkoutTrackerView extends StatefulWidget {
  const WorkoutTrackerView({super.key});

  @override
  State<WorkoutTrackerView> createState() => _WorkoutTrackerViewState();
}

class _WorkoutTrackerViewState extends State<WorkoutTrackerView> {
  List<WorkoutModel> userWorkouts = [];

  List<ExerciseModel> allExercises = [];
  bool isLoadingWorkouts = true;
  // Upcoming workouts list (if available). Currently left empty to avoid compile errors when not populated.
  List<WorkoutModel> upcomingWorkouts = [];

  // Weekly chart data (Sun..Sat), values 0..100
  List<double> weeklyActual = List.filled(7, 0);
  List<double> weeklyPlanned = List.filled(7, 0);


  List latestArr = [
    {
      "image": "assets/img/Workout1.png",
      "title": "fullbodyWorkout",
      "time": "Today, 03:00pm"
    },
    {
      "image": "assets/img/Workout2.png",
      "title": "upperbodyWorkout",
      "time": "June 05, 02:00pm"
    },
  ];


  List whatArr = [
    {
      "image": "assets/img/what_1.png",
      "title": "fullbodyWorkout",
      "exercises": "11 exercises",
      "time": "32mins"
    },
    {
      "image": "assets/img/what_2.png",
      "title": "lowerbodyWorkout",
      "exercises": "12 exercises",
      "time": "40mins"
    },
    {
      "image": "assets/img/what_3.png",
      "title": "abWorkout",
      "exercises": "14 exercises",
      "time": "20mins"
    }
  ];

  @override
  void initState() {
    super.initState();
    _loadUserWorkouts();
    _loadExercises();
  }

  // Load workouts của user từ Firestore
  Future<void> _loadUserWorkouts() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.user != null) {
        print(
            '🏋️ WorkoutTracker: Đang load workouts hôm nay cho user ${userProvider.user!.fullName}');

        final allWorkouts =
            await WorkoutService.getUserWorkouts(userProvider.user!.id);

        // Lọc chỉ workouts hôm nay
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final todayWorkouts = allWorkouts.where((workout) {
          final d = workout.startTime;
          final only = DateTime(d.year, d.month, d.day);
          return only == today;
        }).toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime));

        // Xác định "Bài tập sắp tới":
        // - Nếu hôm nay CHƯA hoàn thành -> dùng workout hôm nay
        // - Nếu hôm nay ĐÃ hoàn thành -> dùng workout của NGÀY MAI (nếu có)
        WorkoutModel? upcoming;
        if (todayWorkouts.isNotEmpty) {
          final todayW = todayWorkouts.first;
          if (todayW.status != 'completed') {
            upcoming = todayW;
          } else {
            // Tìm workout của ngày mai
            final tomorrow = today.add(const Duration(days: 1));
            upcoming = allWorkouts.firstWhere(
              (w) {
                final d = w.startTime;
                return d.year == tomorrow.year &&
                    d.month == tomorrow.month &&
                    d.day == tomorrow.day;
              },
              orElse: () {
                // Fallback theo dayNumber kế tiếp
                final nextDayNumber = ((todayW.dayNumber ?? 0) % 7) + 1;
                try {
                  return allWorkouts.firstWhere((w) => w.dayNumber == nextDayNumber);
                } catch (_) {
                  return todayW; // cuối cùng vẫn hiển thị hôm nay để không rỗng
                }
              },
            );
          }
        } else {
          // Không có workout hôm nay: chọn workout gần nhất trong tương lai (nếu có)
          try {
            upcoming = (allWorkouts
                  ..sort((a, b) => a.startTime.compareTo(b.startTime)))
                .firstWhere((w) => w.startTime.isAfter(today));
          } catch (_) {
            upcoming = null;
          }
        }

        // Cập nhật dữ liệu biểu đồ tuần trước khi setState
        _recomputeWeeklyChart(allWorkouts);
        setState(() {
          userWorkouts = todayWorkouts;
          upcomingWorkouts = upcoming != null ? [upcoming] : [];
          isLoadingWorkouts = false;
        });
      } else {
        setState(() {
          isLoadingWorkouts = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingWorkouts = false;
      });
    }
  }

  // Load all exercises
  Future<void> _loadExercises() async {
    try {
      final exerciseService = ExerciseService();
      allExercises = await exerciseService.getAllExercises();
      print('🏋️ WorkoutTracker: Đã load ${allExercises.length} exercises');
    } catch (e) {
      print('🏋️ WorkoutTracker: Lỗi load exercises: $e');
      // Fallback to empty list
      allExercises = [];
    }
  }
  // Tính dữ liệu biểu đồ theo tuần (CN..T7)
  void _recomputeWeeklyChart(List<WorkoutModel> all) {
    // Xác định tuần hiện tại: lấy ngày Chủ nhật làm mốc bắt đầu
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7)); // Chủ nhật
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    // Bộ đếm planned và completed theo ngày 0..6
    final planned = List<int>.filled(7, 0);
    final completed = List<int>.filled(7, 0);

    for (final w in all) {
      final d = w.startTime;
      if (d.isBefore(startOfWeek) || !d.isBefore(endOfWeek)) continue;
      final dayIndex = d.weekday % 7; // CN=0..T7=6
      planned[dayIndex] += 1;
      if (w.status == 'completed') completed[dayIndex] += 1;
    }

    // Chuyển thành % (0..100). Nếu không có planned -> 0
    final actualPct = List<double>.generate(7, (i) {
      if (planned[i] == 0) return 0;
      return (completed[i] / planned[i]) * 100.0;
    });

    setState(() {
      weeklyPlanned = planned.map((c) => c > 0 ? 100.0 : 0.0).toList();
      weeklyActual = actualPct;
    });
  }


  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Container(
      decoration:
          BoxDecoration(gradient: LinearGradient(colors: TColor.primaryG)),
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
              // pinned: true,
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
                AppLocalizations.of(context)?.workoutTracker ??
                    "Workout Tracker",
                style: TextStyle(
                    color: TColor.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
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
            SliverAppBar(
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
              leadingWidth: 0,
              leading: const SizedBox(),
              expandedHeight: media.width * 0.5,
              flexibleSpace: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                height: media.width * 0.5,
                width: double.maxFinite,
                child: LineChart(
                  LineChartData(
                    lineTouchData: LineTouchData(
                      enabled: true,
                      handleBuiltInTouches: false,
                      touchCallback:
                          (FlTouchEvent event, LineTouchResponse? response) {
                        if (response == null || response.lineBarSpots == null) {
                          return;
                        }
                        // if (event is FlTapUpEvent) {
                        //   final spotIndex =
                        //       response.lineBarSpots!.first.spotIndex;
                        //   showingTooltipOnSpots.clear();
                        //   setState(() {
                        //     showingTooltipOnSpots.add(spotIndex);
                        //   });
                        // }
                      },
                      mouseCursorResolver:
                          (FlTouchEvent event, LineTouchResponse? response) {
                        if (response == null || response.lineBarSpots == null) {
                          return SystemMouseCursors.basic;
                        }
                        return SystemMouseCursors.click;
                      },
                      getTouchedSpotIndicator:
                          (LineChartBarData barData, List<int> spotIndexes) {
                        return spotIndexes.map((index) {
                          return TouchedSpotIndicatorData(
                            FlLine(
                              color: Colors.transparent,
                            ),
                            FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) =>
                                  FlDotCirclePainter(
                                radius: 3,
                                color: Colors.white,
                                strokeWidth: 3,
                                strokeColor: TColor.secondaryColor1,
                              ),
                            ),
                          );
                        }).toList();
                      },
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (touchedSpot) =>
                            TColor.secondaryColor1,
                        tooltipRoundedRadius: 20,
                        getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                          return lineBarsSpot.map((lineBarSpot) {
                            return LineTooltipItem(
                              "${lineBarSpot.x.toInt()} mins ago",
                              const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    lineBarsData: lineBarsData1,
                    minY: -0.5,
                    maxY: 110,
                    titlesData: FlTitlesData(
                        show: true,
                        leftTitles: AxisTitles(),
                        topTitles: AxisTitles(),
                        bottomTitles: AxisTitles(
                          sideTitles: bottomTitles,
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: rightTitles,
                        )),
                    gridData: FlGridData(
                      show: true,
                      drawHorizontalLine: true,
                      horizontalInterval: 25,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: TColor.white.withValues(alpha: 0.15),
                          strokeWidth: 2,
                        );
                      },
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
              color: TColor.white,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25), topRight: Radius.circular(25))),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                        color: TColor.gray.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(3)),
                  ),
                  SizedBox(
                    height: media.width * 0.05,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15),
                    decoration: BoxDecoration(
                      color: TColor.primaryColor2.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Lịch tập hằng ngày",
                          style: TextStyle(
                              color: TColor.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          width: 70,
                          height: 25,
                          child: RoundButton(
                            icon: Icons.check,
                            iconSize: 16,
                            type: RoundButtonType.bgGradient,
                            onPressed: () async {
                            // Mở Lịch tập hằng ngày thực tế (7 ngày đã tạo)
                            final userProvider = Provider.of<UserProvider>(context, listen: false);
                            final user = userProvider.user;
                            if (user == null) return;
                            final workouts = await WorkoutService.getUserWorkouts(user.id);
                            if (!mounted) return;
                            _showWeeklyScheduleBottomSheet(context, workouts);
                          },
                          ),
                        )
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
                        AppLocalizations.of(context)?.upcomingWorkout ??
                            "Upcoming Workout",
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
                  ListView.builder(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: upcomingWorkouts.length,
                      itemBuilder: (context, index) {
                        final w = upcomingWorkouts[index];
                        // Lấy tên bài tập (lọc trùng theo exerciseId)
                        final seen = <String>{};
                        final exerciseNames = w.exercises
                            .where((we) {
                              if (seen.contains(we.exerciseId)) return false;
                              seen.add(we.exerciseId);
                              return we.exercise != null;
                            })
                            .map((we) => we.exercise!.vietnameseName.isNotEmpty
                                ? we.exercise!.vietnameseName
                                : we.exercise!.name)
                            .toList();
                        final map = {
                          "image": _getWorkoutIcon(w.workoutType ?? ''),
                          "title": w.name,
                          "time": _formatWorkoutTime(w.startTime),
                          "exerciseNames": exerciseNames,
                        };
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WorkoutDetailView(
                                  workout: w,
                                  allExercises: allExercises,
                                  isPreviewOnly: true,
                                ),
                              ),
                            );
                          },
                          child: UpcomingWorkoutRow(wObj: map),
                        );
                      }),
                  SizedBox(
                    height: media.width * 0.05,
                  ),
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
                    ],
                  ),
                  // Hiển thị workouts thực từ Firestore
                  isLoadingWorkouts
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        )
                      : userWorkouts.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.fitness_center_outlined,
                                    size: 60,
                                    color: TColor.white.withValues(alpha: 0.7),
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    "Chưa có bài tập hôm nay",
                                    style: TextStyle(
                                      color: TColor.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Hãy cập nhật thông tin BMI để tạo bài tập cho hôm nay",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color:
                                          TColor.white.withValues(alpha: 0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: userWorkouts.length,
                              itemBuilder: (context, index) {
                                final workout = userWorkouts[index];
                                return _buildWorkoutCard(workout, index);
                              }),
                  SizedBox(
                    height: media.width * 0.1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Build workout card từ WorkoutModel
  Widget _buildWorkoutCard(WorkoutModel workout, int index) {
    // Tính tổng thời gian ước tính
    int totalMinutes = _calculateWorkoutDuration(workout);

    // Format thời gian
    String timeText = _formatWorkoutTime(workout.startTime);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: TColor.white,

        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),

          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          print('🏋️ Clicked workout: ${workout.name}');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkoutDetailView(
                workout: workout,
                allExercises: allExercises,
              ),
            ),
          );
        },
        child: Row(
          children: [
            // Workout icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: TColor.primaryG),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                _getWorkoutIconData(workout.workoutType ?? 'mixed'),
                color: TColor.white,
                size: 24,

              ),
            ),
            const SizedBox(width: 15),

            // Workout info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _cleanTitle(workout.name),
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${workout.exercises.length} bài tập",
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${totalMinutes} phút",
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Status and time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(workout.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (workout.status == 'completed') ...[
                        Icon(Icons.check, size: 12, color: TColor.white),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        _getStatusText(workout.status),
                        style: TextStyle(
                          color: TColor.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeText,
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Tính thời gian workout (phút)
  int _calculateWorkoutDuration(WorkoutModel workout) {
    int totalSeconds = 0;

    for (var exercise in workout.exercises) {
      for (var set in exercise.sets) {
        if (set.duration != null && set.duration! > 0) {
          totalSeconds += set.duration!;
        } else {
          // Ước tính 3 giây mỗi rep
          totalSeconds += (set.reps * 3);
        }
        // Thêm thời gian nghỉ (1 phút)
        totalSeconds += (set.restTime ?? 60).clamp(60, 60);
      }
    }

    return (totalSeconds / 60).ceil();
  }

  // Get workout icon path
  String _getWorkoutIcon(String workoutType) {
    switch (workoutType) {
      case 'lose_weight':
        return "assets/img/what_1.png";
      case 'gain_muscle':
        return "assets/img/what_2.png";
      case 'maintain':
        return "assets/img/what_3.png";
      default:
        return "assets/img/what_1.png";
    }
  }

  // Get workout icon data
  IconData _getWorkoutIconData(String workoutType) {
    switch (workoutType) {
      case 'lose_weight':
        return Icons.local_fire_department;
      case 'gain_muscle':
        return Icons.fitness_center;
      case 'maintain':
        return Icons.balance;
      default:
        return Icons.fitness_center;
    }
  }

  // Get status color
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

  void _showWeeklyScheduleBottomSheet(BuildContext ctx, List<WorkoutModel> all) {
    // Lọc 7 ngày theo dayNumber 1-7 và sắp xếp tăng dần
    final sorted = List<WorkoutModel>.from(all)
      ..sort((a, b) => (a.dayNumber ?? 0).compareTo(b.dayNumber ?? 0));
    final Map<int, WorkoutModel> perDay = {};
    for (final w in sorted) {
      final d = w.dayNumber ?? 0;
      if (d >= 1 && d <= 7 && !perDay.containsKey(d)) {
        perDay[d] = w;
      }
    }
    final week = [for (int d = 1; d <= 7; d++) if (perDay[d] != null) perDay[d]!];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Lịch tập 7 ngày', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: week.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final w = week[index];
                      final title = _cleanTitle(w.name);
                      final time = _formatWorkoutTime(w.startTime);
                      final isDone = w.status == 'completed';
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundColor: TColor.primaryColor1.withValues(alpha: 0.15),
                          child: Icon(_getWorkoutIconData(w.workoutType ?? 'mixed'), color: TColor.primaryColor1),
                        ),
                        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(time),
                        trailing: isDone
                            ? Row(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.check, color: Colors.green, size: 18), SizedBox(width: 6), Text('Hoàn thành')])
                            : const SizedBox.shrink(),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WorkoutDetailView(
                                workout: w,
                                allExercises: allExercises,
                                isPreviewOnly: true,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  // Get status text
  String _getStatusText(String status) {
    switch (status) {
      case 'planned':
        return 'Đã lên kế hoạch';
      case 'in_progress':
        return 'Đang thực hiện';
      case 'completed':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }

  // Format workout time
  String _formatWorkoutTime(DateTime? dateTime) {
    if (dateTime == null) return "Chưa xác định";

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final workoutDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (workoutDate == today) {
      return "Hôm nay, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } else {
      return "${dateTime.day}/${dateTime.month}, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    }
  }


  LineTouchData get lineTouchData1 => LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) =>
              Colors.blueGrey.withValues(alpha: 0.8),
        ),
      );

  List<LineChartBarData> get lineBarsData1 => [
        lineChartBarData1_1,
        lineChartBarData1_2,
      ];

  // Đường thực tế: % hoàn thành theo ngày
  LineChartBarData get lineChartBarData1_1 => LineChartBarData(
        isCurved: true,
        color: TColor.white,
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: [
          for (int i = 0; i < 7; i++) FlSpot((i + 1).toDouble(), weeklyActual[i].clamp(0, 100)),
        ],
      );

  // Đường kế hoạch: có bài tập (100) hay không (0) theo ngày
  LineChartBarData get lineChartBarData1_2 => LineChartBarData(
        isCurved: true,
        color: TColor.white.withValues(alpha: 0.5),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: [
          for (int i = 0; i < 7; i++) FlSpot((i + 1).toDouble(), weeklyPlanned[i].clamp(0, 100)),
        ],
      );

  SideTitles get rightTitles => SideTitles(
        getTitlesWidget: rightTitleWidgets,
        showTitles: true,
        interval: 20,
        reservedSize: 40,
      );

  Widget rightTitleWidgets(double value, TitleMeta meta) {
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0%';
        break;
      case 20:
        text = '20%';
        break;
      case 40:
        text = '40%';
        break;
      case 60:
        text = '60%';
        break;
      case 80:
        text = '80%';
        break;
      case 100:
        text = '100%';
        break;
      default:
        return Container();
    }

    return Text(text,
        style: TextStyle(
          color: TColor.white,
          fontSize: 12,
        ),
        textAlign: TextAlign.center);
  }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 1,
        getTitlesWidget: (value, meta) =>
            bottomTitleWidgets(value, meta, context),
      );

  Widget bottomTitleWidgets(
      double value, TitleMeta meta, BuildContext context) {
    var style = TextStyle(
      color: TColor.white,
      fontSize: 12,
    );
    Widget text;
    switch (value.toInt()) {
      case 1:
        text = Text(AppLocalizations.of(context)?.sun ?? 'Sun', style: style);
        break;
      case 2:
        text = Text(AppLocalizations.of(context)?.mon ?? 'Mon', style: style);
        break;
      case 3:
        text = Text(AppLocalizations.of(context)?.tue ?? 'Tue', style: style);
        break;
      case 4:
        text = Text(AppLocalizations.of(context)?.wed ?? 'Wed', style: style);
        break;
      case 5:
        text = Text(AppLocalizations.of(context)?.thu ?? 'Thu', style: style);
        break;
      case 6:
        text = Text(AppLocalizations.of(context)?.fri ?? 'Fri', style: style);
        break;
      case 7:
        text = Text(AppLocalizations.of(context)?.sat ?? 'Sat', style: style);
        break;
      default:
        text = const Text('');
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: text,
    );
  }

  // Remove the Vietnamese weekday word "Thứ ..." from titles for cleaner display
  String _cleanTitle(String title) {
    return title
        .replaceAll(RegExp(r"\s*-?\s*Thứ\s*[A-Za-zÀ-ỹ]+", caseSensitive: false), '')
        .trim();
  }

}
