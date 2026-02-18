import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/notice_model.dart';
import '../../../viewmodels/notice_detail_view_model.dart';
import '../../../viewmodels/landing_view_model.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../core/utils/app_translations.dart';
import '../../../core/ui_components/common_widgets.dart';
import '../../../core/utils/time_utils.dart';

class NoticeDetailView extends StatelessWidget {
  final NoticeModel notice;

  const NoticeDetailView({super.key, required this.notice});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NoticeDetailViewModel()..init(notice),
      child: const _NoticeDetailContent(),
    );
  }
}

class _NoticeDetailContent extends StatelessWidget {
  const _NoticeDetailContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NoticeDetailViewModel>();
    final locale = context.watch<LandingViewModel>().locale.languageCode;
    final notice = viewModel.notice;

    if (notice == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: BaseAppBar(
        title: Text(
          AppTranslations.translate('notice_detail', locale),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: SizeTokens.f16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(SizeTokens.p20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Section
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: SizeTokens.p12,
                vertical: SizeTokens.p6,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(SizeTokens.r8),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: SizeTokens.i16,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(width: SizeTokens.p8),
                  Text(
                    TimeUtils.formatDateTime(notice.noticeDate),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: SizeTokens.p8),
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Text(
                    notice.status == 0
                        ? AppTranslations.translate('passive', locale)
                        : AppTranslations.translate('active', locale),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: notice.status == 0 ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: SizeTokens.p20),

            // Title
            Text(
              notice.title ?? '',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: Colors.black87,
                height: 1.2,
              ),
            ),
            SizedBox(height: SizeTokens.p24),

            // Subtle Divider
            Container(
              height: 1,
              width: SizeTokens.p40,
              color: Theme.of(context).primaryColor.withOpacity(0.3),
            ),
            SizedBox(height: SizeTokens.p24),

            // Description Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(SizeTokens.p20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(SizeTokens.r12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: SelectableText(
                notice.description ?? '',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.black87.withOpacity(0.75),
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
