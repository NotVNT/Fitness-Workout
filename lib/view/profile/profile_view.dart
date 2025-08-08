import 'package:flutter/material.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../common/colo_extension.dart';
import '../../common_widget/round_button.dart';
import '../../common_widget/setting_row.dart';
import '../../common_widget/title_subtitle_cell.dart';
import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import 'personal_data_view.dart';
import 'achievement_view.dart';
import 'activity_history_view.dart';
import 'privacy_policy_view.dart';
import 'settings_view.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool positive = false;
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  final TextEditingController _goalController = TextEditingController();
  bool _isEditingGoal = false;

  // Liên hệ hỗ trợ
  final Uri _supportUri =
      Uri.parse('https://www.facebook.com/profile.php?id=61579017999960');

  // Danh sách accountArr sử dụng AppLocalizations
  List<Map<String, String>> get accountArr => [
        {
          "image": "assets/img/p_personal.png",
          "name": AppLocalizations.of(context)?.personalData ?? "Personal Data",
          "tag": "1"
        },
        {
          "image": "assets/img/p_achi.png",
          "name": AppLocalizations.of(context)?.achievement ?? "Achievement",
          "tag": "2"
        },
        {
          "image": "assets/img/p_activity.png",
          "name": AppLocalizations.of(context)?.activityHistory ??
              "Activity History",
          "tag": "3"
        },
        {
          "image": "assets/img/p_workout.png",
          "name": AppLocalizations.of(context)?.workoutProgress ??
              "Workout Progress",
          "tag": "4"
        }
      ];

  // Danh sách otherArr tích hợp cả hai nhánh
  List<Map<String, String>> get otherArr => [
        {
          "image": "assets/img/p_contact.png",
          "name": AppLocalizations.of(context)?.contactUs ?? "Contact Us",
          "tag": "5"
        },
        {
          "image": "assets/img/p_privacy.png",
          "name":
              AppLocalizations.of(context)?.privacyPolicy ?? "Privacy Policy",
          "tag": "6"
        },
        {
          "image": "assets/img/p_setting.png",
          "name": AppLocalizations.of(context)?.settings ?? "Settings",
          "tag": "7"
        },
        {
          "image": "assets/img/p_setting.png",
          "name":
              AppLocalizations.of(context)?.testUserData ?? "Test User Data",
          "tag": "8"
        },
      ];

  // Hàm đăng xuất
  Future<void> _logout() async {
    print('ProfileView: _logout() called');
    bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        print('ProfileView: Showing logout dialog');
        return AlertDialog(
          title: Text(AppLocalizations.of(context)?.logout ?? 'Đăng xuất'),
          content: Text(AppLocalizations.of(context)?.confirmLogout ??
              'Bạn có chắc chắn muốn đăng xuất?'),
          actions: [
            TextButton(
              onPressed: () {
                print('ProfileView: User cancelled logout');
                Navigator.of(context).pop(false);
              },
              child: Text(AppLocalizations.of(context)?.cancel ?? 'Hủy'),
            ),
            TextButton(
              onPressed: () {
                print('ProfileView: User confirmed logout');
                Navigator.of(context).pop(true);
              },
              child: Text(AppLocalizations.of(context)?.logout ?? 'Đăng xuất'),
            ),
          ],
        );
      },
    );

    print('ProfileView: shouldLogout = $shouldLogout');
    if (shouldLogout == true) {
      try {
        print('ProfileView: Calling authService.signOut()');
        await _authService.signOut();
        print('ProfileView: signOut() completed successfully');
        if (mounted) {
          print('ProfileView: Navigating to StartedView');
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/',
            (route) => false,
          );
        }
      } catch (e) {
        print('ProfileView: signOut() error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)?.logoutError ??
                  'Lỗi đăng xuất: ${_authService.getErrorMessage(e)}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Hàm chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    try {
      // Hiển thị dialog chọn nguồn ảnh
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Chọn ảnh'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Thư viện ảnh'),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Chụp ảnh'),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
              ],
            ),
          );
        },
      );

      if (source != null) {
        final XFile? image = await _picker.pickImage(
          source: source,
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 75,
        );

        if (image != null) {
          setState(() {
            _profileImage = File(image.path);
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ảnh đã được cập nhật!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Lỗi chọn ảnh';

        // Xử lý các lỗi phổ biến
        if (e.toString().contains('permission')) {
          errorMessage = 'Vui lòng cấp quyền truy cập trong cài đặt ứng dụng';
        } else if (e.toString().contains('camera')) {
          errorMessage = 'Không thể truy cập camera. Vui lòng kiểm tra quyền';
        } else if (e.toString().contains('gallery')) {
          errorMessage =
              'Không thể truy cập thư viện ảnh. Vui lòng kiểm tra quyền';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Hàm chỉnh sửa goal
  void _editGoal(String currentGoal) {
    _goalController.text = currentGoal;
    setState(() {
      _isEditingGoal = true;
    });
  }

  // Hàm lưu goal
  void _saveGoal() {
    // TODO: Implement save goal to database
    setState(() {
      _isEditingGoal = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mục tiêu đã được cập nhật!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Hàm hủy chỉnh sửa goal
  void _cancelEditGoal() {
    setState(() {
      _isEditingGoal = false;
    });
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _openSupportLink() async {
    try {
      final ok =
          await launchUrl(_supportUri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Không mở được đường link hỗ trợ'),
              backgroundColor: Colors.red),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Không mở được đường link hỗ trợ'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leadingWidth: 0,
        title: Text(
          AppLocalizations.of(context)?.profile ?? "Profile",
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
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: _authService.getCurrentUserDataStream(),
        builder: (context, snapshot) {
          print(
              'ProfileView - StreamBuilder state: ${snapshot.connectionState}');
          print('ProfileView - Has data: ${snapshot.hasData}');
          print('ProfileView - Data: ${snapshot.data}');
          print('ProfileView - Error: ${snapshot.error}');

          Map<String, dynamic>? userData = snapshot.data;
          UserModel? user;

          // Chuyển đổi Map thành UserModel nếu có dữ liệu
          if (userData != null) {
            user = UserModel(
              id: userData['id'] ?? '',
              email: userData['email'] ?? '',
              firstName: userData['firstName'] ?? '',
              lastName: userData['lastName'] ?? '',
              dateOfBirth: userData['dateOfBirth'] ?? '',
              gender: userData['gender'] ?? '',
              weight: (userData['weight'] ?? 0.0).toDouble(),
              height: (userData['height'] ?? 0.0).toDouble(),
              goal: userData['goal'] ?? '',
            );
          }

          // Sử dụng UserModel để lấy thông tin
          String fullName = user?.fullName ?? "User";
          String goal = user?.goal.isNotEmpty == true
              ? user!.goal
              : AppLocalizations.of(context)?.setYourGoal ?? "Set your goal";
          String height = user?.height != null && user!.height > 0
              ? "${user.height.toInt()}cm"
              : "0cm";
          String weight = user?.weight != null && user!.weight > 0
              ? "${user.weight.toInt()}kg"
              : "0kg";
          String age =
              user?.age != null && user!.age > 0 ? "${user.age}yo" : "0yo";

          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: _profileImage != null
                                  ? Image.file(
                                      _profileImage!,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      "assets/img/u2.png",
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: TColor.primaryColor1,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: TColor.white,
                                  size: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fullName,
                              style: TextStyle(
                                color: TColor.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            _isEditingGoal
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _goalController,
                                          style: TextStyle(
                                            color: TColor.gray,
                                            fontSize: 12,
                                          ),
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: "Nhập mục tiêu của bạn",
                                            hintStyle: TextStyle(
                                              color: TColor.gray
                                                  .withValues(alpha: 0.5),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: _saveGoal,
                                        icon: Icon(
                                          Icons.check,
                                          color: TColor.primaryColor1,
                                          size: 16,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                      IconButton(
                                        onPressed: _cancelEditGoal,
                                        icon: Icon(
                                          Icons.close,
                                          color: TColor.gray,
                                          size: 16,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  )
                                : GestureDetector(
                                    onTap: () => _editGoal(goal),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            goal,
                                            style: TextStyle(
                                              color: TColor.gray,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.edit,
                                          color: TColor.primaryColor1,
                                          size: 14,
                                        ),
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: TitleSubtitleCell(
                          title: height,
                          subtitle:
                              AppLocalizations.of(context)?.height ?? "Height",
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: TitleSubtitleCell(
                          title: weight,
                          subtitle:
                              AppLocalizations.of(context)?.weight ?? "Weight",
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: TitleSubtitleCell(
                          title: age,
                          subtitle: AppLocalizations.of(context)?.age ?? "Age",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      color: TColor.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 2),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)?.account ?? "Account",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: accountArr.length,
                          itemBuilder: (context, index) {
                            var iObj = accountArr[index];
                            return SettingRow(
                              icon: iObj["image"].toString(),
                              title: iObj["name"].toString(),
                              onPressed: () {
                                if (iObj["tag"] == "1") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const PersonalDataView(),
                                    ),
                                  );
                                } else if (iObj["tag"] == "2") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const AchievementView(),
                                    ),
                                  );
                                } else if (iObj["tag"] == "3") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ActivityHistoryView(),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                        // Đã chuyển tùy chỉnh ngôn ngữ sang màn Cài đặt
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      color: TColor.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 2),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)?.notification ??
                              "Notification",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 30,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/img/p_notification.png",
                                height: 15,
                                width: 15,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context)
                                          ?.popUpNotification ??
                                      "Pop-up Notification",
                                  style: TextStyle(
                                    color: TColor.black,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              CustomAnimatedToggleSwitch<bool>(
                                current: positive,
                                values: [false, true],
                                indicatorSize: const Size.square(30.0),
                                animationDuration:
                                    const Duration(milliseconds: 200),
                                animationCurve: Curves.linear,
                                onChanged: (b) => setState(() => positive = b),
                                iconBuilder: (context, local, global) {
                                  return const SizedBox();
                                },
                                onTap: (tapProperties) => setState(() =>
                                    positive = tapProperties.tapped?.value ??
                                        !positive),
                                iconsTappable: false,
                                wrapperBuilder: (context, global, child) {
                                  return Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Positioned(
                                        left: 10.0,
                                        right: 10.0,
                                        height: 30.0,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                                colors: TColor.secondaryG),
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(50.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                      child,
                                    ],
                                  );
                                },
                                foregroundIndicatorBuilder: (context, global) {
                                  return SizedBox.fromSize(
                                    size: const Size(10, 10),
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: TColor.white,
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(50.0),
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black38,
                                            spreadRadius: 0.05,
                                            blurRadius: 1.1,
                                            offset: Offset(0.0, 0.8),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      color: TColor.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 2),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)?.other ?? "Other",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: otherArr.length,
                          itemBuilder: (context, index) {
                            var iObj = otherArr[index];
                            return SettingRow(
                              icon: iObj["image"].toString(),
                              title: iObj["name"].toString(),
                              onPressed: () {
                                if (iObj["tag"] == "5") {
                                  _openSupportLink();
                                } else if (iObj["tag"] == "6") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const PrivacyPolicyView(),
                                    ),
                                  );
                                } else if (iObj["tag"] == "7") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SettingsView(),
                                    ),
                                  );
                                } else if (iObj["tag"] == "8") {
                                  // Xử lý cho mục Test User Data nếu cần
                                }
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 25),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: RoundButton(
                            title: AppLocalizations.of(context)?.logout ??
                                "Đăng xuất",
                            type: RoundButtonType.bgGradient,
                            onPressed: () => _logout(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
