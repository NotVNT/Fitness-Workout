import 'package:fitness/common_widget/on_boarding_page.dart';
import 'package:fitness/common/smooth_page_route.dart';
import 'package:fitness/view/login/signup_view.dart';
import 'package:flutter/material.dart';

import '../../common/colo_extension.dart';

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {
  int selectPage = 0;
  PageController controller = PageController();

  @override
  void initState() {
    super.initState();

    // Listener để update page indicator mượt hơn
    controller.addListener(() {
      final newPage = controller.page?.round() ?? 0;
      if (newPage != selectPage && mounted) {
        selectPage = newPage;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  List pageArr = [
    {
      "title": "Theo dõi mục tiêu",
      "subtitle":
          "Đừng lo lắng nếu bạn gặp khó khăn trong việc xác định mục tiêu. Chúng tôi có thể giúp bạn xác định và theo dõi mục tiêu của mình",
      "image": "assets/img/on_1.png"
    },
    {
      "title": "Đốt cháy calo",
      "subtitle":
          "Hãy tiếp tục đốt cháy để đạt được mục tiêu của bạn. Nó chỉ đau tạm thời, nếu bạn bỏ cuộc bây giờ, bạn sẽ đau đớn mãi mãi",
      "image": "assets/img/on_2.png"
    },
    {
      "title": "Ăn uống lành mạnh",
      "subtitle":
          "Hãy bắt đầu lối sống lành mạnh cùng chúng tôi. Chúng tôi có thể xác định chế độ ăn hàng ngày của bạn. Ăn uống lành mạnh thật thú vị",
      "image": "assets/img/on_3.png"
    },
    {
      "title": "Cải thiện giấc ngủ",
      "subtitle":
          "Cải thiện chất lượng giấc ngủ cùng chúng tôi. Giấc ngủ chất lượng tốt có thể mang lại tâm trạng tốt vào buổi sáng",
      "image": "assets/img/on_4.png"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: Stack(
        alignment: Alignment.bottomRight,
        children: [
          PageView.builder(
              controller: controller,
              itemCount: pageArr.length,
              // Cải thiện performance và animation
              physics: const BouncingScrollPhysics(),
              pageSnapping: true,
              itemBuilder: (context, index) {
                var pObj = pageArr[index] as Map? ?? {};
                return OnBoardingPage(pObj: pObj);
              }),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 70,
                  height: 70,
                  child: CircularProgressIndicator(
                    color: TColor.primaryColor1,
                    value: (selectPage + 1) / 4,
                    strokeWidth: 2,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      color: TColor.primaryColor1,
                      borderRadius: BorderRadius.circular(35)),
                  child: IconButton(
                    icon: Icon(
                      selectPage == 3 ? Icons.done : Icons.navigate_next,
                      color: TColor.white,
                    ),
                    onPressed: () {
                      if (selectPage < 3) {
                        selectPage = selectPage + 1;

                        controller.animateToPage(selectPage,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOutCubic);

                        setState(() {});
                      } else {
                        // Chuyển đến màn hình đăng ký
                        Navigator.push(context,
                            UltraSmoothPageRoute(child: const SignUpView()));
                      }
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
