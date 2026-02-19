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
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SizeTokens.p24,
            vertical: SizeTokens.p12,
          ),
          child: Text(
            AppTranslations.translate('class_groups', locale),
            style: TextStyle(
              fontSize: SizeTokens.f18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade900,
            ),
          ),
        ),
        if (isLoading)
          SizedBox(
            height: SizeTokens.h48,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (classes == null || classes!.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeTokens.p24),
            child: Text(
              AppTranslations.translate('no_classes_available', locale),
              style: TextStyle(
                fontSize: SizeTokens.f14,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          SizedBox(
            height: SizeTokens.h48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: SizeTokens.p24),
              itemCount: classes!.length,
              separatorBuilder: (context, index) =>
                  SizedBox(width: SizeTokens.p12),
              itemBuilder: (context, index) {
                final classItem = classes![index];
                final isSelected = selectedClass?.id == classItem.id;

                return GestureDetector(
                  onTap: () => onClassTap(classItem),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeTokens.p20,
                      vertical: SizeTokens.p12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(SizeTokens.r24),
                      border: Border.all(
                        color: isSelected ? primaryColor : Colors.grey.shade300,
                        width: 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        classItem.groupName ?? '-',
                        style: TextStyle(
                          fontSize: SizeTokens.f14,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : Colors.blueGrey.shade700,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
