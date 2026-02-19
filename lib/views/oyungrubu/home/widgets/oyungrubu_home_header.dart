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
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        SizeTokens.p24,
        topPadding + SizeTokens.p12,
        SizeTokens.p24,
        SizeTokens.p32,
      ),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(SizeTokens.r32),
          bottomRight: Radius.circular(SizeTokens.r32),
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppTranslations.translate('welcome', locale)},',
                      style: TextStyle(
                        fontSize: SizeTokens.f14,
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: SizeTokens.p4),
                    Text(
                      userName ?? '',
                      style: TextStyle(
                        fontSize: SizeTokens.f24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _buildHeaderButton(
                    icon: Icons.notifications_none_rounded,
                    onTap: () {}, // TODO: Add notifications later
                    hasBadge: true,
                  ),
                  SizedBox(width: SizeTokens.p12),
                  _buildHeaderButton(
                    icon: Icons.logout_rounded,
                    onTap: onLogoutTap,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
    bool hasBadge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(SizeTokens.p10),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(SizeTokens.r12),
              border: Border.all(
                // ignore: deprecated_member_use
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: SizeTokens.i20),
          ),
          if (hasBadge)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
