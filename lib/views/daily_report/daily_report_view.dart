import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/size_tokens.dart';
import '../../core/ui_components/common_widgets.dart';
import '../../core/utils/app_translations.dart';
import '../../models/user_model.dart';
import '../../viewmodels/daily_report_view_model.dart';
import '../../viewmodels/landing_view_model.dart';
import '../../models/class_model.dart';
import '../../views/daily_report/student_list_view.dart';

class DailyReportView extends StatelessWidget {
  final UserModel user;

  const DailyReportView({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          DailyReportViewModel()..init(user.schoolId ?? 1, user.userKey ?? ''),
      child: const _DailyReportContent(),
    );
  }
}

class _DailyReportContent extends StatelessWidget {
  const _DailyReportContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DailyReportViewModel>();
    final locale = context.watch<LandingViewModel>().locale.languageCode;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: BaseAppBar(
        title: Text(
          AppTranslations.translate('daily_report', locale),
          style: TextStyle(
            color: Colors.black,
            fontSize: SizeTokens.f16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _buildBody(context, viewModel, locale),
    );
  }

  Widget _buildBody(
    BuildContext context,
    DailyReportViewModel viewModel,
    String locale,
  ) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              viewModel.errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red, fontSize: SizeTokens.f16),
            ),
            SizedBox(height: SizeTokens.p16),
            ElevatedButton(
              onPressed: viewModel.refresh,
              child: Text(AppTranslations.translate('retry', locale)),
            ),
          ],
        ),
      );
    }

    if (viewModel.classes.isEmpty) {
      return Center(
        child: Text(
          AppTranslations.translate(
            'no_classes_found',
            locale,
          ), // Ensure translation exists or fallback
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => viewModel.refresh(),
      child: GridView.builder(
        padding: EdgeInsets.all(SizeTokens.p16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: SizeTokens.p16,
          mainAxisSpacing: SizeTokens.p16,
          childAspectRatio: 0.8,
        ),
        itemCount: viewModel.classes.length,
        itemBuilder: (context, index) {
          final classItem = viewModel.classes[index];
          return _buildClassCard(context, classItem, viewModel);
        },
      ),
    );
  }

  Widget _buildClassCard(
    BuildContext context,
    ClassModel classItem,
    DailyReportViewModel viewModel,
  ) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(SizeTokens.r16),
          onTap: () {
            if (classItem.id != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentListView(
                    user: viewModel.userKey != null
                        ? UserModel(
                            schoolId: viewModel.schoolId,
                            userKey: viewModel.userKey,
                          )
                        : UserModel(), // Fallback or handle appropriately
                    classId: classItem.id!,
                    className: classItem.name ?? '',
                  ),
                ),
              );
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(SizeTokens.r16),
                  ),
                  child: classItem.image != null && classItem.image!.isNotEmpty
                      ? Image.network(
                          classItem.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholder();
                          },
                        )
                      : _buildPlaceholder(),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.all(SizeTokens.p8),
                  child: Center(
                    child: Text(
                      classItem.name ?? '',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: SizeTokens.f14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Icon(
        Icons.class_outlined,
        size: SizeTokens.i48,
        color: Colors.grey[400],
      ),
    );
  }
}
