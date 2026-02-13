import 'package:flutter/material.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../models/calendar_detail_model.dart';
import '../../../core/utils/time_utils.dart';

class TimeTableCard extends StatelessWidget {
  final TimeTableItem item;
  final bool isAuthorized;
  final VoidCallback onDelete;
  final String locale;

  const TimeTableCard({
    super.key,
    required this.item,
    required this.isAuthorized,
    required this.onDelete,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      margin: EdgeInsets.only(bottom: SizeTokens.p12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r8),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: SizeTokens.p4,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(SizeTokens.r8),
                  bottomLeft: Radius.circular(SizeTokens.r8),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(SizeTokens.p12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.lesson?.title ?? "",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: SizeTokens.f14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (isAuthorized)
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.red[400],
                              size: SizeTokens.i16,
                            ),
                            onPressed: onDelete,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                    SizedBox(height: SizeTokens.p4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: SizeTokens.i12,
                          color: Colors.grey[500],
                        ),
                        SizedBox(width: SizeTokens.p4),
                        Text(
                          "${TimeUtils.formatTime(item.startTime)} - ${TimeUtils.formatTime(item.endTime)}",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: SizeTokens.f12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (item.description != null &&
                        item.description!.isNotEmpty) ...[
                      SizedBox(height: SizeTokens.p8),
                      Text(
                        item.description!,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: SizeTokens.f12,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
