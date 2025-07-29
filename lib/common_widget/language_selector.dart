import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/colo_extension.dart';
import '../providers/language_provider.dart';
import '../l10n/app_localizations.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: TColor.lightGray,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Image.asset(
                "assets/img/more_btn.png", // Sử dụng icon có sẵn hoặc thay bằng icon ngôn ngữ
                width: 20,
                height: 20,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)?.language ?? "Language",
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      languageProvider.isVietnamese
                          ? (AppLocalizations.of(context)?.vietnamese ??
                              "Tiếng Việt")
                          : (AppLocalizations.of(context)?.english ??
                              "English"),
                      style: TextStyle(
                        color: TColor.gray,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => _showLanguageDialog(context, languageProvider),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: TColor.primaryG),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.language,
                    color: TColor.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageDialog(
      BuildContext context, LanguageProvider languageProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)?.selectLanguage ?? "Select Language",
            style: TextStyle(
              color: TColor.black,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(
                context,
                languageProvider,
                const Locale('vi'),
                AppLocalizations.of(context)?.vietnamese ?? "Tiếng Việt",
                "🇻🇳",
              ),
              const SizedBox(height: 10),
              _buildLanguageOption(
                context,
                languageProvider,
                const Locale('en'),
                AppLocalizations.of(context)?.english ?? "English",
                "🇺🇸",
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    LanguageProvider languageProvider,
    Locale locale,
    String languageName,
    String flag,
  ) {
    bool isSelected =
        languageProvider.currentLocale.languageCode == locale.languageCode;

    return InkWell(
      onTap: () {
        languageProvider.changeLanguage(locale);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.languageChanged ??
                "Language changed successfully"),
            backgroundColor: TColor.primaryColor1,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? TColor.primaryColor2.withOpacity(0.3)
              : TColor.lightGray,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: TColor.primaryColor1, width: 2)
              : null,
        ),
        child: Row(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                languageName,
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: TColor.primaryColor1,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
