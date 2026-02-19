import 'package:flutter/material.dart';
import '../../../../core/responsive/size_tokens.dart';
import '../../../../core/utils/app_translations.dart';

class OyunGrubuHomeHeader extends StatelessWidget {
  final String? userName;
  final String locale;
  final int studentCount;
  final int classCount;
  final int unreadCount;
  final VoidCallback onProfileTap;
  final VoidCallback onLogoutTap;
  final VoidCallback onNotificationsTap;

  const OyunGrubuHomeHeader({
    super.key,
    required this.userName,
    required this.locale,
    required this.studentCount,
    required this.classCount,
    required this.unreadCount,
    required this.onProfileTap,
    required this.onLogoutTap,
    required this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(
        SizeTokens.p24,
        topPadding + SizeTokens.p12,
        SizeTokens.p24,
        SizeTokens.p20,
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
          bottomLeft: Radius.circular(SizeTokens.r24),
          bottomRight: Radius.circular(SizeTokens.r24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar — Logo + Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    AppTranslations.translate('oyun_grubu', locale),
                    style: TextStyle(
                      fontSize: SizeTokens.f16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(width: SizeTokens.p8),
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
          SizedBox(height: SizeTokens.p16),

          // User greeting row with inline stats
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Greeting
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppTranslations.translate('welcome', locale)},',
                      style: TextStyle(
                        fontSize: SizeTokens.f12,
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.75),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: SizeTokens.p2),
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

              // Inline stat badges
              Row(
                children: [
                  _buildStatBadge(
                    icon: Icons.child_care_rounded,
                    value: studentCount.toString(),
                  ),
                  SizedBox(width: SizeTokens.p8),
                  _buildStatBadge(
                    icon: Icons.groups_rounded,
                    value: classCount > 0 ? classCount.toString() : '-',
                  ),
                ],
              ),
            ],
          ),
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
        padding: EdgeInsets.all(SizeTokens.p8),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(SizeTokens.r10),
        ),
        child: Icon(icon, color: Colors.white, size: SizeTokens.i20),
      ),
    );
  }

  Widget _buildStatBadge({required IconData icon, required String value}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.p10,
        vertical: SizeTokens.p6,
      ),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(SizeTokens.r10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: SizeTokens.i16),
          SizedBox(width: SizeTokens.p4),
          Text(
            value,
            style: TextStyle(
              fontSize: SizeTokens.f14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
