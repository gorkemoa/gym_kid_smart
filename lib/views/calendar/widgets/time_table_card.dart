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
      margin: EdgeInsets.only(bottom: SizeTokens.p16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Time Indicator Bar
            Container(
              width: SizeTokens.p4,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(SizeTokens.r12),
                  bottomLeft: Radius.circular(SizeTokens.r12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(SizeTokens.p16),
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
                              fontSize: SizeTokens.f16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (isAuthorized)
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.red[400],
                              size: SizeTokens.i20,
                            ),
                            onPressed: onDelete,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                    SizedBox(height: SizeTokens.p8),
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
                      SizedBox(height: SizeTokens.p12),
                      Text(
                        item.description!,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: SizeTokens.f14,
                          height: 1.4,
                        ),
                      ),
                    ],
                    if (item.creator != null) ...[
                      SizedBox(height: SizeTokens.p12),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: SizeTokens.r10,
                            backgroundColor: primaryColor.withOpacity(0.1),
                            child: Icon(
                              Icons.person,
                              size: SizeTokens.i12,
                              color: primaryColor,
                            ),
                          ),
                          SizedBox(width: SizeTokens.p8),
                          Text(
                            "${item.creator!.name} ${item.creator!.surname}",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: SizeTokens.f12,
                            ),
                          ),
                        ],
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
