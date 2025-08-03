import 'package:fitness/common/colo_extension.dart';
import 'package:fitness/common/smooth_page_route.dart';
import 'package:fitness/view/on_boarding/on_boarding_view.dart';
import 'package:flutter/material.dart';

class StartedView extends StatefulWidget {
  const StartedView({super.key});

  @override
  State<StartedView> createState() => _StartedViewState();
}

class _StartedViewState extends State<StartedView> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: Container(
          width: media.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                TColor.white,
                TColor.primaryColor2.withOpacity(0.1),
                TColor.primaryColor1.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Logo/Icon area
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: TColor.primaryG,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: [
                    BoxShadow(
                      color: TColor.primaryColor1.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.fitness_center,
                  size: 60,
                  color: TColor.white,
                ),
              ),

              const SizedBox(height: 30),

              // App name
              Text(
                "FitLife",
                style: TextStyle(
                    color: TColor.black,
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5),
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                "Mọi người đều có thể tập luyện",
                style: TextStyle(
                  color: TColor.gray,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 10),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "Bắt đầu hành trình khỏe mạnh của bạn cùng chúng tôi",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: TColor.gray.withOpacity(0.8),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),

              const Spacer(),

              const SizedBox(height: 10),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: TColor.primaryG,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: TColor.primaryColor1.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () {
                          // Chuyển trang trực tiếp với animation mượt
                          Navigator.push(
                              context,
                              UltraSmoothPageRoute(
                                  child: const OnBoardingView()));
                        },
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Bắt đầu ngay",
                                style: TextStyle(
                                  color: TColor.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: TColor.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          )),
    );
  }
}
