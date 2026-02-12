import 'package:flutter/material.dart';
import 'package:gym_kid_smart/core/responsive/size_tokens.dart';
import 'package:gym_kid_smart/core/utils/app_translations.dart';
import 'package:gym_kid_smart/models/daily_student_model.dart';
import 'package:gym_kid_smart/viewmodels/landing_view_model.dart';

import 'package:provider/provider.dart';

class StudentDetailCard extends StatelessWidget {
  final DailyStudentModel item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const StudentDetailCard({
    super.key,
    required this.item,
    this.onEdit,
    this.onDelete,
  });

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
      padding: EdgeInsets.all(SizeTokens.p12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r8),
        border: Border.all(color: Colors.grey.shade200),
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
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.status != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeTokens.p8,
                        vertical: SizeTokens.p4,
                      ),
                      decoration: BoxDecoration(
                        color: item.status == 1
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(SizeTokens.r4),
                        border: Border.all(
                          color: item.status == 1
                              ? Colors.green.shade200
                              : Colors.orange.shade200,
                        ),
                      ),
                      child: Text(
                        item.status == 1 ? 'Hazır' : 'Bekleniyor',
                        style: TextStyle(
                          color: item.status == 1
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.w600,
                          fontSize: SizeTokens.f12,
                        ),
                      ),
                    ),
                  if (onEdit != null)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.edit_outlined,
                        size: SizeTokens.i16,
                        color: Colors.grey[500],
                      ),
                      onPressed: onEdit,
                    ),
                  if (onDelete != null)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.delete_outline,
                        size: SizeTokens.i16,
                        color: Colors.red[300],
                      ),
                      onPressed: onDelete,
                    ),
                ],
              ),
            ],
          ),
          if (displayValue.isNotEmpty) ...[
            SizedBox(height: SizeTokens.p4),
            Text(
              displayValue,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
          if (item.recipient != null && item.recipient!.isNotEmpty) ...[
            SizedBox(height: SizeTokens.p4),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: SizeTokens.i16,
                  color: Colors.grey[400],
                ),
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
            SizedBox(height: SizeTokens.p4),
            Text(
              '${AppTranslations.translate('teacher', locale)}: ${item.teacherNote}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.black87),
            ),
          ],
          if (item.parentNote != null && item.parentNote!.isNotEmpty) ...[
            SizedBox(height: SizeTokens.p4),
            Text(
              '${AppTranslations.translate('parent', locale)}: ${item.parentNote}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.black87),
            ),
          ],
          if (item.note != null && item.note!.isNotEmpty) ...[
            SizedBox(height: SizeTokens.p4),
            Text(
              'Not: ${item.note}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: Colors.grey[500],
              ),
            ),
          ],
          if (item.creator != null) ...[
            SizedBox(height: SizeTokens.p8),
            Divider(height: 1, color: Colors.grey.shade200),
            SizedBox(height: SizeTokens.p8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.person_outline,
                  size: SizeTokens.i16,
                  color: Colors.grey[400],
                ),
                SizedBox(width: SizeTokens.p4),
                Text(
                  '${item.creator?.name ?? ''} ${item.creator?.surname ?? ''}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
