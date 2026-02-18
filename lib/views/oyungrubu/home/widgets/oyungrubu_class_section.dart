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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SizeTokens.p24,
            vertical: SizeTokens.p12,
          ),
          child: Row(
            children: [
              Container(
                width: SizeTokens.r4,
                height: SizeTokens.h24,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF),
                  borderRadius: BorderRadius.circular(SizeTokens.r4),
                ),
              ),
              SizedBox(width: SizeTokens.p12),
              Text(
                AppTranslations.translate('class_groups', locale),
                style: TextStyle(
                  fontSize: SizeTokens.f20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),

        if (isLoading)
          Padding(
            padding: EdgeInsets.symmetric(vertical: SizeTokens.p16),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (classes == null || classes!.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeTokens.p24,
              vertical: SizeTokens.p12,
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(SizeTokens.p20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(SizeTokens.r16),
                // ignore: deprecated_member_use
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.groups_outlined,
                    size: SizeTokens.i32,
                    color: Colors.grey.shade300,
                  ),
                  SizedBox(height: SizeTokens.p8),
                  Text(
                    AppTranslations.translate('no_classes_available', locale),
                    style: TextStyle(
                      fontSize: SizeTokens.f14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: SizeTokens.h100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: SizeTokens.p24),
              itemCount: classes!.length,
              itemBuilder: (context, index) {
                final classItem = classes![index];
                final isSelected = selectedClass?.id == classItem.id;

                return GestureDetector(
                  onTap: () => onClassTap(classItem),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    margin: EdgeInsets.only(right: SizeTokens.p12),
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeTokens.p20,
                      vertical: SizeTokens.p14,
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
                      borderRadius: BorderRadius.circular(SizeTokens.r16),
                      border: isSelected
                          ? null
                          : Border.all(color: Colors.grey.shade200),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.groups_rounded,
                              color: isSelected ? Colors.white : primaryColor,
                              size: SizeTokens.i20,
                            ),
                            SizedBox(width: SizeTokens.p8),
                            Text(
                              classItem.groupName ?? '-',
                              style: TextStyle(
                                fontSize: SizeTokens.f14,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.blueGrey.shade800,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: SizeTokens.p8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: SizeTokens.p8,
                            vertical: SizeTokens.p2,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                // ignore: deprecated_member_use
                                ? Colors.white.withOpacity(0.2)
                                // ignore: deprecated_member_use
                                : const Color(0xFF6C63FF).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(SizeTokens.r8),
                          ),
                          child: Text(
                            _getPostponementLabel(
                              classItem.postponementMode,
                              locale,
                            ),
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
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  String _getPostponementLabel(String? mode, String locale) {
    if (mode == 'extend_week') {
      return AppTranslations.translate('postponement_mode_extend_week', locale);
    }
    return AppTranslations.translate('postponement_mode_normal', locale);
  }
}
