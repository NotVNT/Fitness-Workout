# Tính năng Đa ngôn ngữ (Multi-language Feature)

## Mô tả
Ứng dụng Fitness đã được tích hợp tính năng đa ngôn ngữ hỗ trợ tiếng Việt và tiếng Anh. Ngôn ngữ mặc định của ứng dụng là **tiếng Việt**.

## Tính năng chính

### 1. Hỗ trợ 2 ngôn ngữ
- **Tiếng Việt (vi)** - Ngôn ngữ mặc định
- **Tiếng Anh (en)**

### 2. Nút chọn ngôn ngữ
- Được đặt trong màn hình **Profile** (tab cuối cùng)
- Hiển thị ngôn ngữ hiện tại
- Cho phép chuyển đổi ngôn ngữ dễ dàng

### 3. Lưu trữ lựa chọn
- Ngôn ngữ được lưu vào SharedPreferences
- Ứng dụng sẽ nhớ lựa chọn ngôn ngữ khi khởi động lại

## Cách sử dụng

### Thay đổi ngôn ngữ:
1. Mở ứng dụng
2. Chuyển đến tab **Profile** (biểu tượng người dùng ở cuối)
3. Tìm phần **Language/Ngôn ngữ** trong danh sách
4. Nhấn vào biểu tượng ngôn ngữ (🌐)
5. Chọn ngôn ngữ mong muốn:
   - 🇻🇳 Tiếng Việt
   - 🇺🇸 English
6. Ứng dụng sẽ tự động cập nhật ngôn ngữ

### Các màn hình đã được dịch:
- **Màn hình chính (Home)**: Welcome Back, Today Target, Check, Activity Status, Heart Rate, BMI
- **Màn hình Profile**: Profile, Account, Language settings
- **Màn hình Select**: Workout Tracker, Meal Planner, Sleep Tracker

## Cấu trúc kỹ thuật

### Files được thêm/sửa đổi:

1. **pubspec.yaml**
   - Thêm `flutter_localizations`, `shared_preferences`, `provider`
   - Bật `generate: true`

2. **l10n.yaml**
   - Cấu hình localization

3. **lib/l10n/**
   - `app_en.arb` - Bản dịch tiếng Anh
   - `app_vi.arb` - Bản dịch tiếng Việt
   - `app_localizations.dart` - Generated localization class

4. **lib/providers/language_provider.dart**
   - Provider quản lý state ngôn ngữ
   - Lưu/đọc từ SharedPreferences

5. **lib/common_widget/language_selector.dart**
   - Widget nút chọn ngôn ngữ
   - Dialog chọn ngôn ngữ với UI đẹp

6. **lib/main.dart**
   - Tích hợp Provider và Localization
   - Cấu hình supportedLocales

7. **Các view được cập nhật:**
   - `lib/view/home/home_view.dart`
   - `lib/view/profile/profile_view.dart`
   - `lib/view/main_tab/select_view.dart`

## Thêm ngôn ngữ mới

Để thêm ngôn ngữ mới (ví dụ: tiếng Pháp):

1. Tạo file `lib/l10n/app_fr.arb`
2. Thêm `Locale('fr')` vào `supportedLocales` trong `main.dart`
3. Cập nhật `LanguageProvider` để hỗ trợ ngôn ngữ mới
4. Chạy `flutter gen-l10n` để tạo lại localization files

## Thêm text mới cần dịch

1. Thêm key-value vào `app_en.arb` và `app_vi.arb`
2. Chạy `flutter gen-l10n`
3. Sử dụng `AppLocalizations.of(context)?.newKey ?? "fallback"`

## Lưu ý
- Ngôn ngữ mặc định là tiếng Việt
- Tất cả text đều có fallback bằng tiếng Anh
- Ứng dụng tự động lưu lựa chọn ngôn ngữ
- UI responsive và thân thiện với người dùng
