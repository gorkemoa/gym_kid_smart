import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../core/utils/color_utils.dart';
import '../../../viewmodels/landing_view_model.dart';
import '../../../viewmodels/settings_view_model.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<LandingViewModel, SettingsViewModel>(
      builder: (context, landingVM, settingsVM, child) {
        final settings = settingsVM.settings;
        final primaryColor = ColorUtils.fromHex(
          settings?.mainColor ?? '#f9991c',
        );

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LanguageButton(
              title: 'Türkçe',
              isSelected: landingVM.locale.languageCode == 'tr',
              onTap: () => landingVM.changeLanguage('tr'),
              activeColor: primaryColor,
            ),
            SizedBox(width: SizeTokens.p16),
            _LanguageButton(
              title: 'English',
              isSelected: landingVM.locale.languageCode == 'en',
              onTap: () => landingVM.changeLanguage('en'),
              activeColor: primaryColor,
            ),
          ],
        );
      },
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;

  const _LanguageButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SizeTokens.p24,
          vertical: SizeTokens.p12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(SizeTokens.r12),
          border: Border.all(
            color: isSelected ? activeColor : Colors.white,
            width: 2,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: SizeTokens.f16,
          ),
        ),
      ),
    );
  }
}
