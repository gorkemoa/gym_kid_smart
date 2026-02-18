import 'package:flutter/material.dart';
import '../../../../core/responsive/size_tokens.dart';
import '../../../../core/utils/app_translations.dart';

class OyunGrubuHomeHeader extends StatelessWidget {
  final String? userName;
  final String locale;
  final VoidCallback onProfileTap;
  final VoidCallback onLogoutTap;

  const OyunGrubuHomeHeader({
    super.key,
    required this.userName,
    required this.locale,
    required this.onProfileTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: EdgeInsets.fromLTRB(
        SizeTokens.p24,
        SizeTokens.p16,
        SizeTokens.p24,
        SizeTokens.p24,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor,
            // ignore: deprecated_member_use
            primaryColor.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(SizeTokens.r32),
          bottomRight: Radius.circular(SizeTokens.r32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/app-logo.jpg',
                    height: SizeTokens.h32,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.child_care,
                      size: SizeTokens.i32,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: SizeTokens.p12),
                  Text(
                    AppTranslations.translate('oyun_grubu', locale),
                    style: TextStyle(
                      fontSize: SizeTokens.f18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildHeaderIconButton(
                    icon: Icons.person_outline_rounded,
                    onTap: onProfileTap,
                  ),
                  SizedBox(width: SizeTokens.p8),
                  _buildHeaderIconButton(
                    icon: Icons.logout_rounded,
                    onTap: onLogoutTap,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: SizeTokens.p24),

          // Greeting
          Text(
            '${AppTranslations.translate('welcome', locale)},',
            style: TextStyle(
              fontSize: SizeTokens.f14,
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: SizeTokens.p4),
          Text(
            userName ?? '',
            style: TextStyle(
              fontSize: SizeTokens.f28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: SizeTokens.p8),
          Text(
            AppTranslations.translate('home_subtitle', locale),
            style: TextStyle(
              fontSize: SizeTokens.f14,
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          SizedBox(height: SizeTokens.p16),
        ],
      ),
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(SizeTokens.p10),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(SizeTokens.r12),
        ),
        child: Icon(icon, color: Colors.white, size: SizeTokens.i20),
      ),
    );
  }
}
