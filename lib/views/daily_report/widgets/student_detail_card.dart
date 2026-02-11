import 'package:flutter/material.dart';
import 'package:gym_kid_smart/core/responsive/size_tokens.dart';
import 'package:gym_kid_smart/core/utils/app_translations.dart';
import 'package:gym_kid_smart/models/daily_student_model.dart';
import 'package:gym_kid_smart/viewmodels/landing_view_model.dart';

import 'package:provider/provider.dart';

class StudentDetailCard extends StatelessWidget {
  final DailyStudentModel item;
  final VoidCallback? onEdit;

  const StudentDetailCard({super.key, required this.item, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final locale = context.read<LandingViewModel>().locale.languageCode;
    String displayTitle = item.title ?? '';
    String displayValue = item.value ?? '';

    if (item.medicamentId != null && displayTitle.isEmpty) {
      displayTitle = AppTranslations.translate('medicament', locale);
      displayValue = '#${item.medicamentId}';
    }

    if (item.teacherNote != null || item.parentNote != null) {
      if (displayTitle.isEmpty) {
        displayTitle = AppTranslations.translate('noteLogs', locale);
      }
      displayValue = '';
    }

    if (item.recipient != null) {
      if (displayTitle.isEmpty) {
        displayTitle = AppTranslations.translate('receiving', locale);
      }
      displayValue = item.time ?? '';
    }

    return Container(
      padding: EdgeInsets.all(SizeTokens.p16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                child: Text(
                  displayTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: SizeTokens.f16,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Row(
                children: [
                  if (item.status != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeTokens.p8,
                        vertical: SizeTokens.p4,
                      ),
                      decoration: BoxDecoration(
                        color: item.status == 1
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(SizeTokens.r8),
                      ),
                      child: Text(
                        item.status == 1 ? 'Hazır' : 'Bekleniyor',
                        style: TextStyle(
                          color: item.status == 1
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: SizeTokens.f12,
                        ),
                      ),
                    ),
                  if (onEdit != null)
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        size: SizeTokens.i20,
                        color: Colors.grey,
                      ),
                      onPressed: onEdit,
                    ),
                ],
              ),
            ],
          ),
          if (displayValue.isNotEmpty) ...[
            SizedBox(height: SizeTokens.p8),
            Text(
              displayValue,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
          if (item.recipient != null && item.recipient!.isNotEmpty) ...[
            SizedBox(height: SizeTokens.p8),
            Row(
              children: [
                Icon(Icons.person, size: SizeTokens.i16, color: Colors.grey),
                SizedBox(width: SizeTokens.p4),
                Text(
                  item.recipient!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.black87),
                ),
              ],
            ),
          ],
          if (item.teacherNote != null && item.teacherNote!.isNotEmpty) ...[
            SizedBox(height: SizeTokens.p8),
            Text(
              '${AppTranslations.translate('teacher', locale)}: ${item.teacherNote}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.black87),
            ),
          ],
          if (item.parentNote != null && item.parentNote!.isNotEmpty) ...[
            SizedBox(height: SizeTokens.p8),
            Text(
              '${AppTranslations.translate('parent', locale)}: ${item.parentNote}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.black87),
            ),
          ],
          if (item.note != null && item.note!.isNotEmpty) ...[
            SizedBox(height: SizeTokens.p8),
            Text(
              'Not: ${item.note}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
          if (item.creator != null) ...[
            SizedBox(height: SizeTokens.p8),
            const Divider(),
            SizedBox(height: SizeTokens.p4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.person_outline,
                  size: SizeTokens.i16,
                  color: Colors.grey,
                ),
                SizedBox(width: SizeTokens.p4),
                Text(
                  '${item.creator?.name ?? ''} ${item.creator?.surname ?? ''}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
