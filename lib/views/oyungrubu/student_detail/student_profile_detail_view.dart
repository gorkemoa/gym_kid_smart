import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../core/utils/app_translations.dart';
import '../../../models/oyungrubu_student_model.dart';
import '../../../viewmodels/oyungrubu_student_history_view_model.dart';
import '../../../viewmodels/splash_view_model.dart';
import '../student_history/widgets/student_history_header.dart';
import '../student_history/widgets/student_history_info.dart';
import '../student_history/widgets/student_history_stats.dart';

class StudentProfileDetailView extends StatelessWidget {
  final OyunGrubuStudentModel student;

  const StudentProfileDetailView({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Consumer2<OyunGrubuStudentHistoryViewModel, SplashViewModel>(
      builder: (context, viewModel, splashVM, child) {
        final locale = splashVM.locale.languageCode;
        final currentStudent = viewModel.student ?? student;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: const Color(0xFFF5F6FA),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  StudentHistoryHeader(
                    student: currentStudent,
                    locale: locale,
                    onBackTap: () => Navigator.pop(context),
                  ),

                  // Stats
                  if (!viewModel.isLoading && viewModel.errorMessage == null)
                    StudentHistoryStats(
                      attendedCount: viewModel.attendedCount,
                      absentCount: viewModel.absentCount,
                      postponeCount: viewModel.postponeCount,
                      makeupBalance: viewModel.makeupBalance,
                      locale: locale,
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
                          Icons.person_rounded,
                          size: SizeTokens.i20,
                          color: Colors.grey.shade700,
                        ),
                        SizedBox(width: SizeTokens.p8),
                        Text(
                          AppTranslations.translate('profile_info', locale),
                          style: TextStyle(
                            fontSize: SizeTokens.f16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Student Info
                  StudentHistoryInfo(
                    student: currentStudent,
                    locale: locale,
                  ),

                  SizedBox(height: SizeTokens.p32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
