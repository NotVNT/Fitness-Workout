import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../common/colo_extension.dart';
import '../../common_widget/round_button.dart';
import '../../common_widget/setting_row.dart';
import '../../common_widget/title_subtitle_cell.dart';
import '../../common_widget/language_selector.dart';
import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';

import '../../services/workout_reminder_service.dart';

import 'personal_data_view.dart';
import 'achievement_view.dart';
import 'activity_history_view.dart';
import 'privacy_policy_view.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/activity_log_service.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override


  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  final TextEditingController _goalController = TextEditingController();
  bool _isEditingGoal = false;

  TimeOfDay? _workoutReminder;

  @override
  void initState() {
    super.initState();
    _loadReminder();
  }

  Future<void> _loadReminder() async {
    final res = await WorkoutReminderService.load();
    if (!mounted) return;
    setState(() {
      _workoutReminder =
          res == null ? null : TimeOfDay(hour: res.h, minute: res.m);
    });
  }

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

  // Danh sách otherArr
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

  // Hàm chỉnh sửa target weight
  void _editTargetWeight(String currentTargetWeight) {
    _goalController.text = currentTargetWeight.replaceAll('kg', '');
    setState(() {
      _isEditingGoal = true;
    });
  }

  // Hàm lưu target weight
  void _saveGoal() {
    // TODO: Implement save target weight to database
    setState(() {
      _isEditingGoal = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mục tiêu cân nặng đã được cập nhật!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Hàm hủy chỉnh sửa target weight
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
              targetWeight: (userData['targetWeight'] ?? 0.0).toDouble(),
            );
          }

          // Sử dụng UserModel để lấy thông tin
          String fullName = user?.fullName ?? "User";
          String targetWeight = user?.targetWeight != null &&
                  user!.targetWeight > 0
              ? "${user.targetWeight.toInt()}kg"
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
                                    onTap: () =>
                                        _editTargetWeight(targetWeight),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            targetWeight,
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
                          AppLocalizations.of(context)?.settings ?? "Settings",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Phần đổi ngôn ngữ
                        const LanguageSelector(),
                        const SizedBox(height: 15),
                        // Phần thông báo
                        Text(
                          AppLocalizations.of(context)?.notification ??
                              "Notification",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                ),
                              ),
                              // Nút chọn giờ nhắc tập luyện thay cho nút bật/tắt
                              GestureDetector(
                                onTap: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: _workoutReminder ??
                                        const TimeOfDay(hour: 7, minute: 0),
                                  );
                                  if (picked != null) {
                                    await WorkoutReminderService.save(
                                        picked.hour, picked.minute);
                                    await ActivityLogService.logReminderSet(picked);
                                    if (!mounted) return;
                                    setState(() => _workoutReminder = picked);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Chọn giờ tập luyện thành công: ${picked.format(context)}')),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: TColor.secondaryG),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Chọn giờ',
                                        style: TextStyle(
                                          color: TColor.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (_workoutReminder != null) ...[
                                        const SizedBox(width: 8),
                                        Text(
                                          _workoutReminder!.format(context),
                                          style: TextStyle(
                                            color: TColor.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ]
                                    ],
                                  ),
                                ),
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
