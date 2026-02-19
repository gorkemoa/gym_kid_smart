import 'package:flutter/material.dart';
import '../../../../core/responsive/size_tokens.dart';
import '../../../../core/utils/app_translations.dart';
import '../../../../models/oyungrubu_class_model.dart';

class OyunGrubuClassSection extends StatelessWidget {
  final List<OyunGrubuClassModel>? classes;
  final bool isLoading;
  final String locale;
  final OyunGrubuClassModel? selectedClass;
  final Function(OyunGrubuClassModel) onClassTap;

  const OyunGrubuClassSection({
    super.key,
    required this.classes,
    required this.isLoading,
    required this.locale,
    required this.selectedClass,
    required this.onClassTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    if (isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: SizeTokens.p24),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (classes == null || classes!.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(SizeTokens.p24),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(SizeTokens.p24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(SizeTokens.r16),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            children: [
              Icon(
                Icons.groups_outlined,
                size: SizeTokens.i48,
                color: Colors.grey.shade300,
              ),
              SizedBox(height: SizeTokens.p12),
              Text(
                AppTranslations.translate('no_classes_available', locale),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: SizeTokens.f14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.p24,
        vertical: SizeTokens.p12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label
          Row(
            children: [
              Container(
                width: SizeTokens.r4,
                height: SizeTokens.h20,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF),
                  borderRadius: BorderRadius.circular(SizeTokens.r4),
                ),
              ),
              SizedBox(width: SizeTokens.p10),
              Text(
                AppTranslations.translate('class_groups', locale),
                style: TextStyle(
                  fontSize: SizeTokens.f16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          SizedBox(height: SizeTokens.p12),

          // Class cards — Wrap layout
          Wrap(
            spacing: SizeTokens.p10,
            runSpacing: SizeTokens.p10,
            children: classes!.map((classItem) {
              final isSelected = selectedClass?.id == classItem.id;
              return _buildClassChip(
                context,
                classItem,
                isSelected,
                primaryColor,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildClassChip(
    BuildContext context,
    OyunGrubuClassModel classItem,
    bool isSelected,
    Color primaryColor,
  ) {
    return GestureDetector(
      onTap: () => onClassTap(classItem),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: SizeTokens.p16,
          vertical: SizeTokens.p12,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    primaryColor,
                    // ignore: deprecated_member_use
                    primaryColor.withOpacity(0.8),
                  ],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(SizeTokens.r12),
          border: isSelected ? null : Border.all(color: Colors.grey.shade200),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: primaryColor.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.groups_rounded,
              color: isSelected ? Colors.white : primaryColor,
              size: SizeTokens.i18,
            ),
            SizedBox(width: SizeTokens.p8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  classItem.groupName ?? '-',
                  style: TextStyle(
                    fontSize: SizeTokens.f12,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : Colors.blueGrey.shade800,
                  ),
                ),
                SizedBox(height: SizeTokens.p2),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeTokens.p6,
                    vertical: SizeTokens.p2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        // ignore: deprecated_member_use
                        ? Colors.white.withOpacity(0.2)
                        // ignore: deprecated_member_use
                        : const Color(0xFF6C63FF).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(SizeTokens.r4),
                  ),
                  child: Text(
                    _getPostponementLabel(classItem.postponementMode, locale),
                    style: TextStyle(
                      fontSize: SizeTokens.f10,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          // ignore: deprecated_member_use
                          ? Colors.white.withOpacity(0.9)
                          : const Color(0xFF6C63FF),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getPostponementLabel(String? mode, String locale) {
    if (mode == 'extend_week') {
      return AppTranslations.translate('postponement_mode_extend_week', locale);
    }
    return AppTranslations.translate('postponement_mode_normal', locale);
  }
}
