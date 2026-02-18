import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../core/utils/app_translations.dart';
import '../../../models/user_model.dart';
import '../../../viewmodels/daily_report_view_model.dart';
import '../../../viewmodels/landing_view_model.dart';
import '../../../models/class_model.dart';
import 'student_list_view.dart';

class DailyReportBottomSheet extends StatelessWidget {
  final UserModel user;

  const DailyReportBottomSheet({super.key, required this.user});

  static void show(BuildContext context, UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DailyReportBottomSheet(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          DailyReportViewModel()..init(user.schoolId ?? 1, user.userKey ?? ''),
      child: _DailyReportBottomSheetContent(user: user),
    );
  }
}

class _DailyReportBottomSheetContent extends StatefulWidget {
  final UserModel user;
  const _DailyReportBottomSheetContent({required this.user});

  @override
  State<_DailyReportBottomSheetContent> createState() =>
      _DailyReportBottomSheetContentState();
}

class _DailyReportBottomSheetContentState
    extends State<_DailyReportBottomSheetContent> {
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

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SizeTokens.r24),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            margin: EdgeInsets.symmetric(vertical: SizeTokens.p12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeTokens.p20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppTranslations.translate('select_class', locale),
                  style: TextStyle(
                    fontSize: SizeTokens.f18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.grey[400]),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),

          // Search
          Padding(
            padding: EdgeInsets.all(SizeTokens.p16),
            child: TextField(
              controller: _searchController,
              onChanged: viewModel.updateSearchQuery,
              decoration: InputDecoration(
                hintText: AppTranslations.translate('search', locale),
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: SizeTokens.p16,
                  vertical: SizeTokens.p10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SizeTokens.r12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SizeTokens.r12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
          ),

          // Body
          Expanded(child: _buildBody(context, viewModel, locale)),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    DailyReportViewModel viewModel,
    String locale,
  ) {
    if (viewModel.isLoading)
      return const Center(child: CircularProgressIndicator());

    final filtered = viewModel.filteredClasses;
    if (filtered.isEmpty) {
      return Center(
        child: Text(AppTranslations.translate('no_classes_found', locale)),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(SizeTokens.p16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: SizeTokens.p12,
        mainAxisSpacing: SizeTokens.p12,
        childAspectRatio: 0.85,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final classItem = filtered[index];
        return _buildClassCard(context, classItem, viewModel);
      },
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
        borderRadius: BorderRadius.circular(SizeTokens.r12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(SizeTokens.r12),
        onTap: () {
          Navigator.pop(context); // Close BottomSheet
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentListView(
                user: widget.user,
                classId: classItem.id!,
                className: classItem.name ?? '',
              ),
            ),
          );
        },
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(SizeTokens.r12),
                ),
                child: classItem.image != null && classItem.image!.isNotEmpty
                    ? Image.network(
                        classItem.image!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Container(
                        color: Colors.grey[100],
                        child: Icon(
                          Icons.class_outlined,
                          size: SizeTokens.i32,
                          color: Colors.grey[300],
                        ),
                      ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  classItem.name ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: SizeTokens.f14,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
