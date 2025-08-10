import 'package:flutter/material.dart';

import '../../common/colo_extension.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: TColor.black),
        title: Text(Localizations.localeOf(context).languageCode == 'en' ? 'Privacy Policy' : 'Chính sách bảo mật',
            style: TextStyle(
                color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(Localizations.localeOf(context).languageCode == 'en'
                  ? '1. Information We Collect'
                  : '1. Thông tin chúng tôi thu thập'),
              _bodyText(Localizations.localeOf(context).languageCode == 'en'
                  ? '• Account information (email, display name)\n• Health data you enter (height, weight, goals, workout schedule)\n• App usage data (frequency, features used)'
                  : '• Thông tin tài khoản (email, tên hiển thị)\n• Dữ liệu sức khỏe bạn nhập (chiều cao, cân nặng, mục tiêu, lịch luyện tập)\n• Dữ liệu sử dụng ứng dụng (tần suất, tính năng sử dụng)'),
              _sectionTitle(Localizations.localeOf(context).languageCode == 'en'
                  ? '2. How We Use Information'
                  : '2. Mục đích sử dụng thông tin'),
              _bodyText(Localizations.localeOf(context).languageCode == 'en'
                  ? '• Provide, maintain and improve workout experience\n• Personalize content, suggestions and plans\n• Customer support and abuse prevention'
                  : '• Cung cấp, duy trì và cải thiện trải nghiệm tập luyện\n• Cá nhân hóa nội dung, gợi ý và kế hoạch\n• Hỗ trợ khách hàng và phòng chống lạm dụng'),
              _sectionTitle(Localizations.localeOf(context).languageCode == 'en'
                  ? '3. Information Sharing'
                  : '3. Chia sẻ thông tin'),
              _bodyText(Localizations.localeOf(context).languageCode == 'en'
                  ? 'We do not sell personal data. Data is shared only when: (i) you consent, (ii) required by law, or (iii) with service providers to operate the system (under confidentiality).'
                  : 'Chúng tôi không bán dữ liệu cá nhân. Dữ liệu chỉ được chia sẻ khi: (i) có sự đồng ý của bạn, (ii) tuân thủ pháp luật, hoặc (iii) với nhà cung cấp dịch vụ để vận hành hệ thống (tuân thủ bảo mật).'),
              _sectionTitle(Localizations.localeOf(context).languageCode == 'en'
                  ? '4. Your Rights'
                  : '4. Quyền của bạn'),
              _bodyText(Localizations.localeOf(context).languageCode == 'en'
                  ? '• View, update, delete your personal data\n• Withdraw consent for data processing\n• Contact us for support using the information below'
                  : '• Xem, cập nhật, xóa dữ liệu cá nhân\n• Rút lại sự đồng ý xử lý dữ liệu\n• Liên hệ để yêu cầu hỗ trợ theo thông tin bên dưới'),
              _sectionTitle(Localizations.localeOf(context).languageCode == 'en'
                  ? '5. Data Retention & Security'
                  : '5. Lưu trữ và bảo mật'),
              _bodyText(Localizations.localeOf(context).languageCode == 'en'
                  ? 'We apply reasonable technical and organizational measures to protect data. However, no transmission method over the Internet is 100% secure.'
                  : 'Chúng tôi áp dụng các biện pháp kỹ thuật và tổ chức hợp lý để bảo vệ dữ liệu. Tuy nhiên, không có phương thức truyền tải nào qua Internet an toàn tuyệt đối.'),
              _sectionTitle(Localizations.localeOf(context).languageCode == 'en'
                  ? '6. Contact'
                  : '6. Liên hệ'),
              _bodyText(Localizations.localeOf(context).languageCode == 'en'
                  ? 'If you have any questions about this policy, please contact us via the “Contact Us” section in the Profile page.'
                  : 'Nếu bạn có thắc mắc về chính sách này, vui lòng liên hệ qua mục “Liên hệ với chúng tôi” trong trang Hồ sơ.'),
              const SizedBox(height: 16),
              Text(Localizations.localeOf(context).languageCode == 'en' ? 'Last updated: 08/2025' : 'Cập nhật lần cuối: 08/2025',
                  style: TextStyle(color: TColor.gray, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(text,
          style: TextStyle(
              color: TColor.black, fontSize: 14, fontWeight: FontWeight.w700)),
    );
  }

  Widget _bodyText(String text) {
    return Text(text, style: TextStyle(color: TColor.gray, fontSize: 13));
  }
}

