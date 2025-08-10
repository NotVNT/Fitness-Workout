import 'package:fitness/common_widget/round_button.dart';
import 'package:fitness/common_widget/workout_row.dart';
import 'package:fitness/common_widget/icon_text_button.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import '../../helpers/calorie_helper.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../common/colo_extension.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/user_provider.dart';
import '../../services/workout_service.dart';
import '../../models/workout_model.dart';
import 'activity_tracker_view.dart';
import 'finished_workout_view.dart';
import 'notification_view.dart';
import '../bmi_edit/height_input_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Dữ liệu 'Bài tập gần đây' sẽ được lấy từ Workout Tracker (đã hoàn thành)
  List lastWorkoutArr = [];
  List<int> showingTooltipOnSpots = [0];
  // Dữ liệu biểu đồ tuần (CN..T7)
  List<double> weeklyActual = List.filled(7, 0);
  List<double> weeklyPlanned = List.filled(7, 0);


  // Calo đốt cháy hôm nay (từ workout đã hoàn thành)
  int _caloriesBurnedToday = 0;
  final int _burnTarget = 500; // mục tiêu mặc định 500 kcal/ngày


  StreamSubscription<List<WorkoutModel>>? _recentSub;

  @override
  void initState() {
    super.initState();
    // Load user data when the home view initializes
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.loadUserData();
      _subscribeRecentCompletedWorkouts();
      _loadWeeklyProgress();
      _loadTodayCalories();
    });
  }
  void _subscribeRecentCompletedWorkouts() {
    _recentSub?.cancel();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (user == null) return;
    _recentSub = WorkoutService.recentCompletedWorkoutsStream(user.id, limit: 3)
        .listen((recents) {
      if (!mounted) return;
      setState(() {
        lastWorkoutArr = recents.map((w) {
          return {
            "name": _localizeWorkoutName(_cleanTitle(w.name)),
            "image": _iconFromType(w.workoutType),
            "kcal": (w.caloriesBurned ?? 0).toString(),
            "time": (w.duration ?? _estimateDurationFromExercises(w)).toString(),
            "progress": 1.0,
          };
        }).toList();
      });
    });
  }

  @override
  void dispose() {
    _recentSub?.cancel();
    super.dispose();
  }


  Future<void> _showBMIEditDialog() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HeightInputView(),
      ),
    ).then((_) {
      // Refresh user data when returning from the flow
      if (mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.loadUserData();
      }
    });
  }

  // Gọi helper để lấy kcal đã đốt hôm nay
  Future<void> _loadTodayCalories() async {
    final total = await CalorieHelper.loadTodayBurnedCalories(context);
    if (!mounted) return;
    setState(() => _caloriesBurnedToday = total);
  }

  List<FlSpot> get allSpots => const [
        FlSpot(0, 20),
        FlSpot(1, 25),
        FlSpot(2, 40),
        FlSpot(3, 50),
        FlSpot(4, 35),
        FlSpot(5, 40),
        FlSpot(6, 30),
        FlSpot(7, 20),
        FlSpot(8, 25),
        FlSpot(9, 40),
        FlSpot(10, 50),
        FlSpot(11, 35),
        FlSpot(12, 50),
        FlSpot(13, 60),
        FlSpot(14, 40),
        FlSpot(15, 50),
        FlSpot(16, 20),
        FlSpot(17, 25),
        FlSpot(18, 40),
        FlSpot(19, 50),
        FlSpot(20, 35),
        FlSpot(21, 80),
        FlSpot(22, 30),
        FlSpot(23, 20),
        FlSpot(24, 25),
        FlSpot(25, 40),
        FlSpot(26, 50),
        FlSpot(27, 35),
        FlSpot(28, 50),
        FlSpot(29, 60),
        FlSpot(30, 40)
      ];

  // Tính dữ liệu biểu đồ tuần (CN..T7)
  Future<void> _loadWeeklyProgress() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (user == null) return;

    final all = await WorkoutService.getUserWorkouts(user.id);

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    final planned = List<int>.filled(7, 0);
    final completed = List<int>.filled(7, 0);

    for (final w in all) {
      final d = w.startTime;
      if (d.isBefore(startOfWeek) || !d.isBefore(endOfWeek)) continue;
      final dayIndex = d.weekday % 7; // CN=0..T7=6
      planned[dayIndex] += 1;
      if (w.status == 'completed') completed[dayIndex] += 1;
    }

    final actualPct = List<double>.generate(7, (i) {
      if (planned[i] == 0) return 0;
      return (completed[i] / planned[i]) * 100.0;
    });

    if (!mounted) return;
    setState(() {
      weeklyPlanned = planned.map((c) => c > 0 ? 100.0 : 0.0).toList();
      weeklyActual = actualPct;
    });
  }


  String _iconFromType(String? workoutType) {
    switch (workoutType) {
      case 'lose_weight':
        return 'assets/img/Workout1.png';
      case 'gain_muscle':
        return 'assets/img/Workout2.png';
      case 'maintain':
        return 'assets/img/Workout3.png';
      default:
        return 'assets/img/Workout1.png';
    }
  }

  int _estimateDurationFromExercises(WorkoutModel w) {
    int totalSeconds = 0;
    for (final ex in w.exercises) {
      for (final set in ex.sets) {
        if (set.duration != null && set.duration! > 0) {
          totalSeconds += set.duration!;
        } else {
          totalSeconds += (set.reps * 3);
        }
        // Thời gian nghỉ cố định 1 phút
        totalSeconds += (set.restTime ?? 60).clamp(60, 60);
      }
    }
    return (totalSeconds / 60).ceil();
  }

  String _cleanTitle(String title) {
    return title.replaceAll(RegExp(r"\s*-?\s*Thứ\s*[A-Za-zÀ-ỹ]+", caseSensitive: false), '').trim();
  }
  String _localizeWorkoutName(String title) {
    // Convert Vietnamese 'Ngày <n>' to English 'Day <n>' when locale is EN
    if (Localizations.localeOf(context).languageCode == 'en') {
      final match = RegExp(r'^Ngày\s*(\d+)').firstMatch(title);
      if (match != null) {
        return 'Day ${match.group(1)}';
      }
    }
    return title;
  }




  List waterArr = [
    {"title": "6am - 8am", "subtitle": "600ml"},
    {"title": "9am - 11am", "subtitle": "500ml"},
    {"title": "11am - 2pm", "subtitle": "1000ml"},
    {"title": "2pm - 4pm", "subtitle": "700ml"},
    {"title": "4pm - now", "subtitle": "900ml"},
  ];

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    final lineBarsData = [
      LineChartBarData(
        showingIndicators: showingTooltipOnSpots,
        spots: allSpots,
        isCurved: false,
        barWidth: 3,
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(colors: [
            TColor.primaryColor2.withValues(alpha: 0.4),
            TColor.primaryColor1.withValues(alpha: 0.1),
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        dotData: FlDotData(show: false),
        gradient: LinearGradient(
          colors: TColor.primaryG,
        ),
      ),
    ];

    final tooltipsOnBar = lineBarsData[0];

    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)?.welcomeBack ??
                              "Welcome Back,",
                          style: TextStyle(color: TColor.gray, fontSize: 12),
                        ),
                        Consumer<UserProvider>(
                          builder: (context, userProvider, child) {
                            return Text(
                              userProvider.user?.fullName ??
                                  (AppLocalizations.of(context)?.stefaniWong ??
                                      "User"),
                              style: TextStyle(
                                  color: TColor.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700),
                            );
                          },
                        ),
                      ],
                    ),
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationView(),
                            ),
                          );
                        },
                        icon: Image.asset(
                          "assets/img/notification_active.png",
                          width: 25,
                          height: 25,
                          fit: BoxFit.fitHeight,
                        )),
                  ],
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Container(
                  height: media.width * 0.4,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: TColor.primaryG),
                      borderRadius: BorderRadius.circular(media.width * 0.075)),
                  child: Stack(alignment: Alignment.center, children: [
                    Image.asset(
                      "assets/img/bg_dots.png",
                      height: media.width * 0.4,
                      width: double.maxFinite,
                      fit: BoxFit.fitHeight,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 25, horizontal: 25),
                      child: Consumer<UserProvider>(
                        builder: (context, userProvider, child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)?.bmi ??
                                        "BMI (Body Mass Index)",
                                    style: TextStyle(
                                        color: TColor.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    (() {
                                      final loc = AppLocalizations.of(context);
                                      final u = userProvider;
                                      if (u.user == null || u.user!.weight <= 0 || u.user!.height <= 0) {
                                        return loc?.noBMIData ?? 'No BMI data available';
                                      }
                                      final bmiValue = u.bmi;
                                      if (bmiValue < 18.5) {
                                        return loc?.youAreUnderweight ?? 'You are underweight';
                                      } else if (bmiValue < 25) {
                                        return loc?.youHaveNormalWeight ?? 'You have a normal weight';
                                      } else if (bmiValue < 30) {
                                        return loc?.youAreOverweight ?? 'You are overweight';
                                      } else {
                                        return loc?.youAreObese ?? 'You are obese';
                                      }
                                    })(),
                                    style: TextStyle(
                                        color:
                                            TColor.white.withValues(alpha: 0.7),
                                        fontSize: 12),
                                  ),
                                  SizedBox(
                                    height: media.width * 0.05,
                                  ),
                                  SizedBox(
                                      width: 120,
                                      height: 35,
                                      child: RoundButton(
                                          icon: Icons.edit,
                                          iconSize: 16,
                                          type: RoundButtonType.bgSGradient,
                                          onPressed: _showBMIEditDialog))
                                ],
                              ),
                              AspectRatio(
                                aspectRatio: 1,
                                child: PieChart(
                                  PieChartData(
                                    pieTouchData: PieTouchData(
                                      touchCallback: (FlTouchEvent event,
                                          pieTouchResponse) {},
                                    ),
                                    startDegreeOffset: 250,
                                    borderData: FlBorderData(
                                      show: false,
                                    ),
                                    sectionsSpace: 1,
                                    centerSpaceRadius: 0,
                                    sections: showingSections(),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    )
                  ]),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  decoration: BoxDecoration(
                    color: TColor.primaryColor2.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)?.todayTarget ??
                            "Today Target",
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
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ActivityTrackerView(),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                // Should Do Section Title
                Text(
                  AppLocalizations.of(context)?.shouldDo ?? "Should Do",
                  style: TextStyle(
                      color: TColor.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: media.width * 0.02,
                ),
                // Water Advice Row
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 2)
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: TColor.secondaryG),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          Icons.water_drop,
                          color: TColor.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)?.waterAdvice ??
                                  "Drink enough water",
                              style: TextStyle(
                                  color: TColor.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 5),
                            ShaderMask(
                              blendMode: BlendMode.srcIn,
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                        colors: TColor.primaryG,
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight)
                                    .createShader(Rect.fromLTRB(
                                        0, 0, bounds.width, bounds.height));
                              },
                              child: Text(
                                "2-3 ${AppLocalizations.of(context)?.litersPerDay ?? "liters per day"}",
                                style: TextStyle(
                                    color: TColor.white.withValues(alpha: 0.7),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              (Localizations.localeOf(context).languageCode == 'en')
                                  ? 'Drinking enough water helps keep you healthy and boosts metabolism'
                                  : 'Uống đủ nước giúp cơ thể khỏe mạnh và tăng cường trao đổi chất',
                              style: TextStyle(
                                color: TColor.gray,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                // Sleep Advice Row
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 2)
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: TColor.primaryG),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          Icons.bedtime,
                          color: TColor.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)?.sleepAdvice ??
                                  "Get 8 hours of sleep a day",
                              style: TextStyle(
                                  color: TColor.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 5),
                            ShaderMask(
                              blendMode: BlendMode.srcIn,
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                        colors: TColor.primaryG,
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight)
                                    .createShader(Rect.fromLTRB(
                                        0, 0, bounds.width, bounds.height));
                              },
                              child: Text(
                                (Localizations.localeOf(context).languageCode == 'en')
                                    ? '8 hours/day'
                                    : '8 tiếng/ngày',
                                style: TextStyle(
                                    color: TColor.white.withValues(alpha: 0.7),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              (Localizations.localeOf(context).languageCode == 'en')
                                  ? 'Getting enough sleep helps your body recover and improves mental health'
                                  : 'Ngủ đủ giấc giúp cơ thể phục hồi và tăng cường sức khỏe tinh thần',
                              style: TextStyle(
                                color: TColor.gray,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Row(
                  children: [
                    Expanded(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: double.maxFinite,
                          constraints: BoxConstraints(
                            minHeight: media.width * 0.35,
                            maxHeight: media.width * 0.42,
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 12),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 2)
                              ]),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  AppLocalizations.of(context)?.calories ??
                                      "Calories",
                                  style: TextStyle(
                                      color: TColor.black,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700),
                                ),
                                ShaderMask(
                                  blendMode: BlendMode.srcIn,
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                            colors: TColor.primaryG,
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight)
                                        .createShader(Rect.fromLTRB(
                                            0, 0, bounds.width, bounds.height));
                                  },
                                  child: Text(
                                    (Localizations.localeOf(context).languageCode == 'en')
                                        ? 'Burned $_caloriesBurnedToday calories'
                                        : 'Đã giảm được $_caloriesBurnedToday calories',
                                    style: TextStyle(
                                        color: TColor.white.withValues(alpha: 0.9),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Flexible(
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: SizedBox(
                                      width: media.width * 0.2,
                                      height: media.width * 0.2,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                            width: media.width * 0.15,
                                            height: media.width * 0.15,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                  colors: TColor.primaryG),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      media.width * 0.075),
                                            ),
                                            child: FittedBox(
                                              child: Text(
                                                "${(_burnTarget - _caloriesBurnedToday).clamp(0, _burnTarget)}${AppLocalizations.of(context)?.kCalLeft ?? "kCal\ncòn lại"}",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: TColor.white,
                                                    fontSize: 11),
                                              ),
                                            ),
                                          ),
                                          SimpleCircularProgressBar(
                                            progressStrokeWidth: 10,
                                            backStrokeWidth: 10,
                                            progressColors: TColor.primaryG,
                                            backColor: Colors.grey.shade100,
                                            valueNotifier: ValueNotifier(((_caloriesBurnedToday / _burnTarget) * 100).clamp(0, 100).toDouble()),
                                            startAngle: -180,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ]),
                        ),
                      ],
                    ))
                  ],
                ),
                SizedBox(
                  height: media.width * 0.1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        AppLocalizations.of(context)?.workoutProgress ??
                            "Tiến độ tập luyện",
                        style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
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
                            value: AppLocalizations.of(context)?.weekly ?? 'Weekly',
                            items: [
                              DropdownMenuItem(
                                value: AppLocalizations.of(context)?.weekly ?? 'Weekly',
                                child: Text(AppLocalizations.of(context)?.weekly ?? 'Weekly'),
                              ),
                            ],
                            onChanged: null,
                            icon: Icon(Icons.expand_more, color: TColor.white),
                            hint: Text(
                              AppLocalizations.of(context)?.weekly ?? 'Weekly',
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
                // Chú thích (legend)
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 16, bottom: 6),
                  child: Row(
                    children: [
                      Container(width: 10, height: 10, decoration: BoxDecoration(
                        gradient: LinearGradient(colors: TColor.primaryG),
                        shape: BoxShape.circle,
                      )),
                      const SizedBox(width: 6),
                      Text(
                        Localizations.localeOf(context).languageCode == 'en'
                            ? 'Actual'
                            : 'Thực tế',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 16),
                      Container(width: 16, height: 10, alignment: Alignment.center,
                        child: Container(height: 2, width: 16, decoration: BoxDecoration(
                          color: TColor.secondaryColor1, borderRadius: BorderRadius.circular(2),
                        ))),
                      const SizedBox(width: 6),
                      Text(
                        Localizations.localeOf(context).languageCode == 'en'
                            ? 'Planned'
                            : 'Kế hoạch',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                    padding: const EdgeInsets.only(left: 15),
                    height: media.width * 0.5,
                    width: double.maxFinite,
                    child: LineChart(
                      LineChartData(
                        showingTooltipIndicators:
                            showingTooltipOnSpots.map((index) {
                          return ShowingTooltipIndicators([
                            LineBarSpot(
                              tooltipsOnBar,
                              lineBarsData.indexOf(tooltipsOnBar),
                              tooltipsOnBar.spots[index],
                            ),
                          ]);
                        }).toList(),
                        lineTouchData: LineTouchData(
                          enabled: true,
                          handleBuiltInTouches: false,
                          touchCallback: (FlTouchEvent event,
                              LineTouchResponse? response) {
                            if (response == null ||
                                response.lineBarSpots == null) {
                              return;
                            }
                            if (event is FlTapUpEvent) {
                              final spotIndex =
                                  response.lineBarSpots!.first.spotIndex;
                              showingTooltipOnSpots.clear();
                              setState(() {
                                showingTooltipOnSpots.add(spotIndex);
                              });
                            }
                          },
                          mouseCursorResolver: (FlTouchEvent event,
                              LineTouchResponse? response) {
                            if (response == null ||
                                response.lineBarSpots == null) {
                              return SystemMouseCursors.basic;
                            }
                            return SystemMouseCursors.click;
                          },
                          getTouchedSpotIndicator: (LineChartBarData barData,
                              List<int> spotIndexes) {
                            return spotIndexes.map((index) {
                              return TouchedSpotIndicatorData(
                                FlLine(
                                  color: Colors.transparent,
                                ),
                                FlDotData(
                                  show: true,
                                  getDotPainter:
                                      (spot, percent, barData, index) =>
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
                                  "${lineBarSpot.x.toInt()} ${AppLocalizations.of(context)?.minsAgo ?? "mins ago"}",
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
                        minY: 0,
                        maxY: 100,
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
                              color: TColor.gray.withValues(alpha: 0.15),
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
                    )),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        AppLocalizations.of(context)?.latestWorkout ??
                            "Latest Workout",
                        style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
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
                    itemCount: lastWorkoutArr.length,
                    itemBuilder: (context, index) {
                      var wObj = lastWorkoutArr[index] as Map? ?? {};
                      return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const FinishedWorkoutView(),
                              ),
                            );
                          },
                          child: WorkoutRow(wObj: wObj));
                    }),
                SizedBox(
                  height: media.width * 0.1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final bmi = userProvider.bmi;
    final bmiText = bmi > 0 ? bmi.toStringAsFixed(1) : "--";

    return List.generate(
      2,
      (i) {
        var color0 = userProvider.getBMIColor();

        switch (i) {
          case 0:
            return PieChartSectionData(
                color: color0,
                value: 33,
                title: '',
                radius: 55,
                titlePositionPercentageOffset: 0.55,
                badgeWidget: Text(
                  bmiText,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ));
          case 1:
            return PieChartSectionData(
              color: Colors.white,
              value: 75,
              title: '',
              radius: 45,
              titlePositionPercentageOffset: 0.55,
            );

          default:
            throw Error();
        }
      },
    );
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

  LineChartBarData get lineChartBarData1_1 => LineChartBarData(
        isCurved: true,
        gradient: LinearGradient(colors: [
          TColor.primaryColor2.withValues(alpha: 0.8),
          TColor.primaryColor1.withValues(alpha: 0.8),
        ]),
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: FlDotData(show: true),
        belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [
          TColor.primaryColor2.withValues(alpha: 0.25),
          TColor.primaryColor1.withValues(alpha: 0.05),
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        spots: [
          for (int i = 0; i < 7; i++) FlSpot((i + 1).toDouble(), weeklyActual[i].clamp(0, 100)),
        ],
      );

  LineChartBarData get lineChartBarData1_2 => LineChartBarData(
        isCurved: true,
        gradient: LinearGradient(colors: [
          TColor.secondaryColor2.withValues(alpha: 0.5),
          TColor.secondaryColor1.withValues(alpha: 0.5),
        ]),
        barWidth: 3,
        isStrokeCapRound: true,
        dashArray: [6, 6],
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
          color: TColor.gray,
          fontSize: 12,
        ),
        textAlign: TextAlign.center);
  }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    final style = TextStyle(color: TColor.gray, fontSize: 12);
    String label;
    switch (value.toInt()) {
      case 1:
        label = AppLocalizations.of(context)?.sun ?? 'CN';
        break;
      case 2:
        label = AppLocalizations.of(context)?.mon ?? 'T2';
        break;
      case 3:
        label = AppLocalizations.of(context)?.tue ?? 'T3';
        break;
      case 4:
        label = AppLocalizations.of(context)?.wed ?? 'T4';
        break;
      case 5:
        label = AppLocalizations.of(context)?.thu ?? 'T5';
        break;
      case 6:
        label = AppLocalizations.of(context)?.fri ?? 'T6';
        break;
      case 7:
        label = AppLocalizations.of(context)?.sat ?? 'T7';
        break;
      default:
        label = '';
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      child: Text(label, style: style),
    );
  }
}
