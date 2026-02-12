import 'package:flutter/material.dart';
import '../../../models/notice_model.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../core/utils/app_translations.dart';
import '../../notice_detail/notice_detail_view.dart';

class NoticeCard extends StatelessWidget {
  final NoticeModel notice;
  final String locale;

  const NoticeCard({super.key, required this.notice, required this.locale});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NoticeDetailView(notice: notice),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: SizeTokens.p16),
        padding: EdgeInsets.all(SizeTokens.p16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SizeTokens.r12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.campaign_rounded,
                  size: SizeTokens.i20,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                SizedBox(width: SizeTokens.p12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notice.title ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: SizeTokens.f16,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        notice.noticeDate ?? '',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: SizeTokens.f12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: SizeTokens.p12),
            Text(
              notice.description ?? '',
              style: TextStyle(
                color: Colors.black87.withOpacity(0.8),
                height: 1.4,
                fontSize: SizeTokens.f14,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: SizeTokens.p12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  AppTranslations.translate('read_more', locale),
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: SizeTokens.f12,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: SizeTokens.i16,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
