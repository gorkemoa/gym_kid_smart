import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/size_tokens.dart';
import '../../core/ui_components/common_widgets.dart';
import '../../core/utils/app_translations.dart';
import '../../models/user_model.dart';
import '../../viewmodels/daily_report_view_model.dart';
import '../../viewmodels/login_view_model.dart';
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

class _DailyReportContent extends StatefulWidget {
  const _DailyReportContent();

  @override
  State<_DailyReportContent> createState() => _DailyReportContentState();
}

class _DailyReportContentState extends State<_DailyReportContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
          AppTranslations.translate('no_classes_found', locale),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    final filtered = viewModel.filteredClasses;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            SizeTokens.p16,
            SizeTokens.p16,
            SizeTokens.p16,
            SizeTokens.p8,
          ),
          child: TextField(
            controller: _searchController,
            onChanged: viewModel.updateSearchQuery,
            decoration: InputDecoration(
              hintText: AppTranslations.translate('search', locale),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: viewModel.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        viewModel.updateSearchQuery('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: SizeTokens.p16,
                vertical: SizeTokens.p12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SizeTokens.r16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SizeTokens.r16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SizeTokens.r16),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    AppTranslations.translate('no_classes_found', locale),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async => viewModel.refresh(),
                  child: GridView.builder(
                    padding: EdgeInsets.all(SizeTokens.p16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: SizeTokens.p16,
                      mainAxisSpacing: SizeTokens.p16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final classItem = filtered[index];
                      final user = context.read<LoginViewModel>().data?.data;
                      if (user == null) return const SizedBox.shrink();
                      return _buildClassCard(
                        context,
                        classItem,
                        viewModel,
                        user,
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildClassCard(
    BuildContext context,
    ClassModel classItem,
    DailyReportViewModel viewModel,
    UserModel user,
  ) {
    return Container(
      padding: EdgeInsets.all(SizeTokens.p12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(SizeTokens.r8),
          onTap: () {
            if (classItem.id != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentListView(
                    user: user,
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
                    top: Radius.circular(SizeTokens.r8),
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
