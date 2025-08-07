import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../lib/common/colo_extension.dart';
import '../lib/view/meal_planner/meal_food_details_view.dart';

void main() {
  runApp(const SimpleMealTestApp());
}

class SimpleMealTestApp extends StatelessWidget {
  const SimpleMealTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SimpleUserProvider(),
      child: MaterialApp(
        title: 'Simple Meal Test',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const SimpleMealTestHome(),
      ),
    );
  }
}

class SimpleMealTestHome extends StatelessWidget {
  const SimpleMealTestHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Meal Food Details'),
        backgroundColor: TColor.primaryColor1,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Test Meal Food Details View',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'BMI: ${Provider.of<SimpleUserProvider>(context).bmi.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MealFoodDetailsView(
                      eObj: {"name": "Breakfast"},
                      onMealSelected: (meal) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã chọn: ${meal['name']}'),
                          ),
                        );
                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.primaryColor1,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'Test Meal Food Details',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SimpleUserProvider with ChangeNotifier {
  double _bmi = 26.0; // Test BMI for weight loss meals

  double get bmi => _bmi;

  void setBmi(double newBmi) {
    _bmi = newBmi;
    notifyListeners();
  }
}
