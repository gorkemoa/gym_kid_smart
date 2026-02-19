import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../core/utils/app_translations.dart';
import '../../../models/oyungrubu_student_model.dart';
import '../../../viewmodels/oyungrubu_student_history_view_model.dart';
import '../../../viewmodels/splash_view_model.dart';
import '../student_history/widgets/student_history_header.dart';
import '../student_history/widgets/student_history_stats.dart';
import '../student_history/widgets/student_history_info.dart';

class StudentProfileDetailView extends StatelessWidget {
  final OyunGrubuStudentModel student;

  const StudentProfileDetailView({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Consumer2<OyunGrubuStudentHistoryViewModel, SplashViewModel>(
      builder: (context, viewModel, splashVM, child) {
        final locale = splashVM.locale.languageCode;
        final currentStudent = viewModel.student ?? student;
        final primaryColor = Theme.of(context).colorScheme.primary;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: const Color(0xFFF5F6FA),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // Gradient header
                  StudentHistoryHeader(
                    student: currentStudent,
                    locale: locale,
                    onBackTap: () => Navigator.pop(context),
                  ),

                  // Stats section
                  if (!viewModel.isLoading)
                    StudentHistoryStats(
                      attendedCount: viewModel.attendedCount,
                      absentCount: viewModel.absentCount,
                      postponeCount: viewModel.postponeCount,
                      makeupBalance: viewModel.makeupBalance,
                      locale: locale,
                    ),

                  // Section title
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      SizeTokens.p24,
                      SizeTokens.p16,
                      SizeTokens.p24,
                      SizeTokens.p12,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: SizeTokens.r4,
                          height: SizeTokens.h20,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(SizeTokens.r4),
                          ),
                        ),
                        SizedBox(width: SizeTokens.p10),
                        Icon(
                          Icons.person_outline_rounded,
                          size: SizeTokens.i18,
                          color: Colors.grey.shade700,
                        ),
                        SizedBox(width: SizeTokens.p8),
                        Text(
                          AppTranslations.translate('personal_info', locale),
                          style: TextStyle(
                            fontSize: SizeTokens.f16,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Info section
                  StudentHistoryInfo(student: currentStudent, locale: locale),

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
