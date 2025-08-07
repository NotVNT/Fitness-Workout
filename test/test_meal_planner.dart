import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../lib/providers/meal_plan_provider.dart';
import '../lib/providers/user_provider.dart';
import '../lib/providers/language_provider.dart';
import '../lib/view/meal_planner/meal_planner_view.dart';
import '../lib/common/colo_extension.dart';
import '../lib/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ChangeNotifierProvider(
            create: (context) => UserProvider()..initializeTestData()),
        ChangeNotifierProvider(create: (context) => MealPlanProvider()),
      ],
      child: const TestMealPlannerApp(),
    ),
  );
}

class TestMealPlannerApp extends StatelessWidget {
  const TestMealPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          title: 'Test Meal Planner',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            fontFamily: "Poppins",
          ),
          locale: languageProvider.currentLocale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('vi', ''),
          ],
          home: const TestMealPlannerHome(),
        );
      },
    );
  }
}

class TestMealPlannerHome extends StatelessWidget {
  const TestMealPlannerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Meal Planner'),
        backgroundColor: TColor.primaryColor1,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Test Meal Planner Feature',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MealPlannerView(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.primaryColor1,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'Mở Kế hoạch bữa ăn',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Tạo user demo
                final userProvider =
                    Provider.of<UserProvider>(context, listen: false);
                userProvider.setDemoUser();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.secondaryColor1,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'Tạo User Demo',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
