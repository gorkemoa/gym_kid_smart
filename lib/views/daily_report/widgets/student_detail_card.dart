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
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: SizeTokens.f14,
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
                        vertical: SizeTokens.p2,
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
                          fontSize: SizeTokens.f10,
                        ),
                      ),
                    ),
                  if (onEdit != null)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        Icons.edit_outlined,
                        size: SizeTokens.i16,
                        color: Colors.grey[400],
                      ),
                      onPressed: onEdit,
                    ),
                  if (onDelete != null)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.only(left: SizeTokens.p8),
                      constraints: const BoxConstraints(),
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
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: SizeTokens.f12,
                color: Colors.black87,
              ),
            ),
          ],
          if (item.recipient != null && item.recipient!.isNotEmpty) ...[
            SizedBox(height: SizeTokens.p6),
            Row(
              children: [
                Icon(
                  Icons.person_pin_circle_outlined,
                  size: SizeTokens.i12,
                  color: Colors.grey[400],
                ),
                SizedBox(width: SizeTokens.p4),
                Text(
                  item.recipient!,
                  style: TextStyle(
                    fontSize: SizeTokens.f12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],
          if ((item.teacherNote != null && item.teacherNote!.isNotEmpty) ||
              (item.parentNote != null && item.parentNote!.isNotEmpty) ||
              (item.note != null && item.note!.isNotEmpty)) ...[
            SizedBox(height: SizeTokens.p10),
            if (item.teacherNote != null && item.teacherNote!.isNotEmpty)
              _buildNoteBox(
                context,
                '${AppTranslations.translate('teacher', locale)}:',
                item.teacherNote!,
                Colors.amber.shade50,
                Colors.amber.shade700,
              ),
            if (item.parentNote != null && item.parentNote!.isNotEmpty)
              _buildNoteBox(
                context,
                '${AppTranslations.translate('parent', locale)}:',
                item.parentNote!,
                Colors.blue.shade50,
                Colors.blue.shade700,
              ),
            if (item.note != null && item.note!.isNotEmpty)
              _buildNoteBox(
                context,
                'Not:',
                item.note!,
                Colors.grey.shade50,
                Colors.grey.shade700,
                italic: true,
              ),
          ],
          if (item.creator != null) ...[
            SizedBox(height: SizeTokens.p12),
            Row(
              children: [
                const Expanded(child: Divider(height: 1)),
                Padding(
                  padding: EdgeInsets.only(left: SizeTokens.p8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.history_edu_outlined,
                        size: SizeTokens.i12,
                        color: Colors.grey[300],
                      ),
                      SizedBox(width: SizeTokens.p4),
                      Text(
                        '${item.creator?.name ?? ''} ${item.creator?.surname ?? ''}',
                        style: TextStyle(
                          fontSize: SizeTokens.f10,
                          color: Colors.grey[400],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoteBox(
    BuildContext context,
    String prefix,
    String note,
    Color bgColor,
    Color textColor, {
    bool italic = false,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: SizeTokens.p4),
      padding: EdgeInsets.all(SizeTokens.p8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(SizeTokens.r4),
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: SizeTokens.f12,
            color: Colors.black87,
            height: 1.4,
            fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          ),
          children: [
            TextSpan(
              text: '$prefix ',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
            TextSpan(text: note),
          ],
        ),
      ),
    );
  }
}
