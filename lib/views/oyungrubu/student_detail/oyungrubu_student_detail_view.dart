import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../core/utils/app_translations.dart';
import '../../../models/oyungrubu_student_model.dart';
import '../../../viewmodels/oyungrubu_student_history_view_model.dart';
import '../../../viewmodels/splash_view_model.dart';
import '../student_history/widgets/student_edit_bottom_sheet.dart';
import '../student_history/widgets/student_history_header.dart';
import 'student_profile_detail_view.dart';
import 'student_package_detail_view.dart';
import 'student_activity_detail_view.dart';

class OyunGrubuStudentDetailView extends StatefulWidget {
  final OyunGrubuStudentModel student;

  const OyunGrubuStudentDetailView({super.key, required this.student});

  @override
  State<OyunGrubuStudentDetailView> createState() =>
      _OyunGrubuStudentDetailViewState();
}

class _OyunGrubuStudentDetailViewState
    extends State<OyunGrubuStudentDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OyunGrubuStudentHistoryViewModel>().init(widget.student);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<OyunGrubuStudentHistoryViewModel, SplashViewModel>(
      builder: (context, viewModel, splashVM, child) {
        final locale = splashVM.locale.languageCode;
        final primaryColor = Theme.of(context).colorScheme.primary;
        final currentStudent = viewModel.student ?? widget.student;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: const Color(0xFFF5F6FA),
            body: Column(
              children: [
                // Header
                StudentHistoryHeader(
                  student: currentStudent,
                  locale: locale,
                  onBackTap: () => Navigator.pop(context),
                  onEditTap: () => _showEditBottomSheet(context, locale),
                ),

                // Grid options
                Expanded(
                  child: viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : viewModel.errorMessage != null
                      ? _buildErrorState(viewModel, locale)
                      : _buildOptionGrid(
                          context,
                          currentStudent,
                          locale,
                          primaryColor,
                          viewModel,
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionGrid(
    BuildContext context,
    OyunGrubuStudentModel student,
    String locale,
    Color primaryColor,
    OyunGrubuStudentHistoryViewModel viewModel,
  ) {
    final items = [
      _GridItem(
        icon: Icons.person_outline_rounded,
        label: AppTranslations.translate('profile', locale),
        subtitle: AppTranslations.translate('personal_info', locale),
        color: const Color(0xFF6C63FF),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StudentProfileDetailView(student: student),
          ),
        ),
      ),
      _GridItem(
        icon: Icons.inventory_2_outlined,
        label: AppTranslations.translate('packages', locale),
        subtitle: AppTranslations.translate('active_and_past', locale),
        color: const Color(0xFFFF6B6B),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StudentPackageDetailView(student: student),
          ),
        ),
      ),
      _GridItem(
        icon: Icons.timeline_rounded,
        label: AppTranslations.translate('activity', locale),
        subtitle: AppTranslations.translate('lesson_history', locale),
        color: const Color(0xFF4CAF50),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StudentActivityDetailView(student: student),
          ),
        ),
      ),
      _GridItem(
        icon: Icons.edit_note_rounded,
        label: AppTranslations.translate('edit', locale),
        subtitle: AppTranslations.translate('update_info', locale),
        color: const Color(0xFFFF9800),
        onTap: () => _showEditBottomSheet(context, locale),
      ),
    ];

    return ListView(
      padding: EdgeInsets.fromLTRB(
        SizeTokens.p24,
        SizeTokens.p24,
        SizeTokens.p24,
        SizeTokens.p32,
      ),
      children: [
        // Section title
        Row(
          children: [
            Container(
              width: SizeTokens.r4,
              height: SizeTokens.h20,
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF),
                borderRadius: BorderRadius.circular(SizeTokens.r4),
              ),
            ),
            SizedBox(width: SizeTokens.p10),
            Text(
              AppTranslations.translate('quick_actions', locale),
              style: TextStyle(
                fontSize: SizeTokens.f16,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        SizedBox(height: SizeTokens.p16),

        // 2x2 Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: SizeTokens.p16,
            crossAxisSpacing: SizeTokens.p16,
            childAspectRatio: 1.0,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildGridCard(item, primaryColor);
          },
        ),

        // Quick stats
        SizedBox(height: SizeTokens.p24),
        _buildQuickStatsRow(viewModel, locale),
      ],
    );
  }

  Widget _buildGridCard(_GridItem item, Color primaryColor) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SizeTokens.r20),
          border: Border.all(color: Colors.grey.shade100, width: 1),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: item.color.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(SizeTokens.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(SizeTokens.p12),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(SizeTokens.r16),
                ),
                child: Icon(item.icon, color: item.color, size: SizeTokens.i24),
              ),
              const Spacer(),
              // Title
              Text(
                item.label,
                style: TextStyle(
                  fontSize: SizeTokens.f16,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: SizeTokens.p4),
              // Subtitle
              Text(
                item.subtitle,
                style: TextStyle(
                  fontSize: SizeTokens.f10,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatsRow(
    OyunGrubuStudentHistoryViewModel viewModel,
    String locale,
  ) {
    return Container(
      padding: EdgeInsets.all(SizeTokens.p16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.check_circle_outline_rounded,
              value: viewModel.attendedCount.toString(),
              label: AppTranslations.translate('attended', locale),
              color: const Color(0xFF4CAF50),
            ),
          ),
          _buildVerticalDivider(),
          Expanded(
            child: _buildStatItem(
              icon: Icons.cancel_outlined,
              value: viewModel.absentCount.toString(),
              label: AppTranslations.translate('absent', locale),
              color: const Color(0xFFF44336),
            ),
          ),
          _buildVerticalDivider(),
          Expanded(
            child: _buildStatItem(
              icon: Icons.schedule_rounded,
              value: viewModel.postponeCount.toString(),
              label: AppTranslations.translate('postponed', locale),
              color: const Color(0xFFFF9800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: SizeTokens.h48,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: SizeTokens.i18),
        SizedBox(height: SizeTokens.p6),
        Text(
          value,
          style: TextStyle(
            fontSize: SizeTokens.f20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: SizeTokens.p2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: SizeTokens.f10,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildErrorState(
    OyunGrubuStudentHistoryViewModel viewModel,
    String locale,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(SizeTokens.p32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: SizeTokens.i64,
              color: Colors.red.shade300,
            ),
            SizedBox(height: SizeTokens.p16),
            Text(
              AppTranslations.translate(viewModel.errorMessage!, locale),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: SizeTokens.f16,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: SizeTokens.p24),
            ElevatedButton.icon(
              onPressed: viewModel.onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(AppTranslations.translate('retry', locale)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBottomSheet(BuildContext context, String locale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StudentEditBottomSheet(locale: locale),
    );
  }
}

class _GridItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  _GridItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}
