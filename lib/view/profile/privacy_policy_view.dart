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
        title: Text('Chính sách bảo mật',
            style: TextStyle(
                color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('1. Thông tin chúng tôi thu thập'),
              _bodyText(
                  '• Thông tin tài khoản (email, tên hiển thị)\n• Dữ liệu sức khỏe bạn nhập (chiều cao, cân nặng, mục tiêu, lịch luyện tập)\n• Dữ liệu sử dụng ứng dụng (tần suất, tính năng sử dụng)'),
              _sectionTitle('2. Mục đích sử dụng thông tin'),
              _bodyText(
                  '• Cung cấp, duy trì và cải thiện trải nghiệm tập luyện\n• Cá nhân hóa nội dung, gợi ý và kế hoạch\n• Hỗ trợ khách hàng và phòng chống lạm dụng'),
              _sectionTitle('3. Chia sẻ thông tin'),
              _bodyText(
                  'Chúng tôi không bán dữ liệu cá nhân. Dữ liệu chỉ được chia sẻ khi: (i) có sự đồng ý của bạn, (ii) tuân thủ pháp luật, hoặc (iii) với nhà cung cấp dịch vụ để vận hành hệ thống (tuân thủ bảo mật).'),
              _sectionTitle('4. Quyền của bạn'),
              _bodyText(
                  '• Xem, cập nhật, xóa dữ liệu cá nhân\n• Rút lại sự đồng ý xử lý dữ liệu\n• Liên hệ để yêu cầu hỗ trợ theo thông tin bên dưới'),
              _sectionTitle('5. Lưu trữ và bảo mật'),
              _bodyText(
                  'Chúng tôi áp dụng các biện pháp kỹ thuật và tổ chức hợp lý để bảo vệ dữ liệu. Tuy nhiên, không có phương thức truyền tải nào qua Internet an toàn tuyệt đối.'),
              _sectionTitle('6. Liên hệ'),
              _bodyText(
                  'Nếu bạn có thắc mắc về chính sách này, vui lòng liên hệ qua mục “Liên hệ với chúng tôi” trong trang Hồ sơ.'),
              const SizedBox(height: 16),
              Text('Cập nhật lần cuối: 08/2025',
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

