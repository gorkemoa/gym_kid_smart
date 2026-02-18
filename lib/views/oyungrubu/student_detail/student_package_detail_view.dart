import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../core/utils/app_translations.dart';
import '../../../models/oyungrubu_student_model.dart';
import '../../../viewmodels/oyungrubu_student_history_view_model.dart';
import '../../../viewmodels/splash_view_model.dart';
import '../student_history/widgets/student_history_header.dart';
import '../student_history/widgets/student_package_info_section.dart';

class StudentPackageDetailView extends StatelessWidget {
  final OyunGrubuStudentModel student;

  const StudentPackageDetailView({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Consumer2<OyunGrubuStudentHistoryViewModel, SplashViewModel>(
      builder: (context, viewModel, splashVM, child) {
        final locale = splashVM.locale.languageCode;
        final currentStudent = viewModel.student ?? student;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          body: SafeArea(
            child: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.errorMessage != null
                    ? _buildErrorState(viewModel, locale)
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            StudentHistoryHeader(
                              student: currentStudent,
                              locale: locale,
                              onBackTap: () => Navigator.pop(context),
                            ),

                            // Section Title
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                SizeTokens.p24,
                                SizeTokens.p24,
                                SizeTokens.p24,
                                SizeTokens.p8,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.inventory_2_rounded,
                                    size: SizeTokens.i20,
                                    color: Colors.grey.shade700,
                                  ),
                                  SizedBox(width: SizeTokens.p8),
                                  Text(
                                    AppTranslations.translate(
                                        'package_details', locale),
                                    style: TextStyle(
                                      fontSize: SizeTokens.f16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Package Info
                            if (viewModel.packageInfoList != null &&
                                (viewModel.packageInfoList!.isNotEmpty ||
                                    viewModel.makeupBalance > 0))
                              StudentPackageInfoSection(
                                packages: viewModel.packageInfoList!,
                                packageCount: viewModel.packageCount,
                                makeupBalance: viewModel.makeupBalance,
                                locale: locale,
                              )
                            else
                              _buildEmptyState(locale),

                            SizedBox(height: SizeTokens.p32),
                          ],
                        ),
                      ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String locale) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(SizeTokens.p48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: SizeTokens.i64,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: SizeTokens.p16),
            Text(
              AppTranslations.translate('no_active_packages', locale),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: SizeTokens.f16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
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
}
