import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../viewmodels/notice_view_model.dart';
import '../../viewmodels/landing_view_model.dart';
import '../../models/class_model.dart';
import '../../core/responsive/size_tokens.dart';
import '../../core/utils/app_translations.dart';
import '../../core/ui_components/common_widgets.dart';
import 'widgets/notice_card.dart';

class NoticeView extends StatelessWidget {
  final UserModel user;
  final bool showAppBar;

  const NoticeView({super.key, required this.user, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NoticeViewModel()..init(user),
      child: _NoticeContent(showAppBar: showAppBar),
    );
  }
}

class _NoticeContent extends StatelessWidget {
  final bool showAppBar;
  const _NoticeContent({required this.showAppBar});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NoticeViewModel>();
    final locale = context.watch<LandingViewModel>().locale.languageCode;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: showAppBar
          ? BaseAppBar(
              automaticallyImplyLeading: false,
              title: Text(
                AppTranslations.translate('announcements', locale),
                style: TextStyle(
                  fontSize: SizeTokens.f18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      body: Column(
        children: [
          if (viewModel.classes.isNotEmpty)
            _buildClassFilter(context, viewModel, locale),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => viewModel.refresh(),
              child: _buildBody(viewModel, locale),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassFilter(
    BuildContext context,
    NoticeViewModel viewModel,
    String locale,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.p20,
        vertical: SizeTokens.p12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_list_rounded,
            size: SizeTokens.i20,
            color: Colors.black54,
          ),
          SizedBox(width: SizeTokens.p12),
          Text(
            AppTranslations.translate('select_class', locale),
            style: TextStyle(
              fontSize: SizeTokens.f14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(width: SizeTokens.p16),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: SizeTokens.p12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(SizeTokens.r12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ClassModel?>(
                  value: viewModel.selectedClass,
                  isExpanded: true,
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Theme.of(context).primaryColor,
                  ),
                  items: [
                    DropdownMenuItem<ClassModel?>(
                      value: null,
                      child: Text(
                        AppTranslations.translate('all', locale),
                        style: TextStyle(
                          fontSize: SizeTokens.f14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    ...viewModel.classes.map((c) {
                      return DropdownMenuItem<ClassModel?>(
                        value: c,
                        child: Text(
                          c.name ?? '',
                          style: TextStyle(
                            fontSize: SizeTokens.f14,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    }),
                  ],
                  onChanged: (val) => viewModel.selectClass(val),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(NoticeViewModel viewModel, String locale) {
    if (viewModel.isLoading && viewModel.notices.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null && viewModel.notices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(viewModel.errorMessage!),
            SizedBox(height: SizeTokens.p16),
            ElevatedButton(
              onPressed: () => viewModel.onRetry(),
              child: Text(AppTranslations.translate('retry', locale)),
            ),
          ],
        ),
      );
    }

    if (viewModel.notices.isEmpty) {
      return Center(
        child: Text(AppTranslations.translate('no_notices', locale)),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(SizeTokens.p20),
      itemCount: viewModel.notices.length,
      itemBuilder: (context, index) {
        return NoticeCard(notice: viewModel.notices[index], locale: locale);
      },
    );
  }
}
