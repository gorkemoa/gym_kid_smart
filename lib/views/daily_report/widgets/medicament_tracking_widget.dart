import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../core/utils/app_translations.dart';
import '../../../viewmodels/student_detail_view_model.dart';
import '../../../viewmodels/landing_view_model.dart';
import '../../../models/student_medicament_model.dart';
import '../../../models/user_model.dart';

class MedicamentTrackingWidget extends StatelessWidget {
  final UserModel user;

  const MedicamentTrackingWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StudentDetailViewModel>();
    final locale = context.watch<LandingViewModel>().locale.languageCode;

    if (viewModel.medicaments.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(SizeTokens.p24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.medical_services_outlined,
                size: SizeTokens.i48,
                color: Colors.grey[300],
              ),
              SizedBox(height: SizeTokens.p12),
              Text(
                AppTranslations.translate('no_medicaments_found', locale),
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: SizeTokens.f14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.p12,
        vertical: SizeTokens.p8,
      ),
      itemCount: viewModel.medicaments.length,
      separatorBuilder: (context, index) => SizedBox(height: SizeTokens.p8),
      itemBuilder: (context, index) {
        final medicament = viewModel.medicaments[index];
        final isTaken =
            viewModel.allSectionsData['medicament']?.any(
              (d) => d.medicamentId == medicament.id,
            ) ??
            false;

        return _buildMedicamentCard(
          context,
          viewModel,
          medicament,
          isTaken,
          locale,
        );
      },
    );
  }

  Widget _buildMedicamentCard(
    BuildContext context,
    StudentDetailViewModel viewModel,
    StudentMedicamentModel medicament,
    bool isTaken,
    String locale,
  ) {
    Color statusColor;
    String statusText;

    switch (medicament.status) {
      case 0:
        statusColor = Colors.red;
        statusText = AppTranslations.translate('allergy', locale);
        break;
      case 1:
        statusColor = Colors.orange;
        statusText = AppTranslations.translate('important', locale);
        break;
      case 2:
      default:
        statusColor = Colors.blue;
        statusText = AppTranslations.translate('less_important', locale);
        break;
    }

    return Container(
      padding: EdgeInsets.all(SizeTokens.p12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicament.title ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: SizeTokens.f14,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: SizeTokens.p4),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeTokens.p6,
                        vertical: SizeTokens.p4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(SizeTokens.r4),
                        border: Border.all(color: statusColor.withOpacity(0.2)),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: SizeTokens.f10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (medicament.status != 0)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(SizeTokens.r4),
                    onTap: () {
                      viewModel.toggleMedicament(
                        medicamentId: medicament.id!,
                        userId: user.id ?? 0,
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeTokens.p8,
                        vertical: SizeTokens.p4,
                      ),
                      decoration: BoxDecoration(
                        color: isTaken
                            ? Colors.green.shade50
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(SizeTokens.r4),
                        border: Border.all(
                          color: isTaken
                              ? Colors.green.shade200
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isTaken
                                ? Icons.check_circle_rounded
                                : Icons.circle_outlined,
                            size: SizeTokens.i16,
                            color: isTaken ? Colors.green : Colors.grey[400],
                          ),
                          SizedBox(width: SizeTokens.p4),
                          Text(
                            isTaken ? 'Verildi' : 'Verilmedi',
                            style: TextStyle(
                              color: isTaken ? Colors.green : Colors.grey[500],
                              fontSize: SizeTokens.f10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (user.role == 'parent' || user.role == 'superadmin')
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () =>
                      _confirmDelete(context, viewModel, medicament, locale),
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red[300],
                    size: SizeTokens.i16,
                  ),
                ),
            ],
          ),
          if (medicament.value != null && medicament.value!.isNotEmpty) ...[
            SizedBox(height: SizeTokens.p8),
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: SizeTokens.i12,
                  color: Colors.grey[400],
                ),
                SizedBox(width: SizeTokens.p6),
                Text(
                  medicament.value!,
                  style: TextStyle(
                    fontSize: SizeTokens.f12,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          if (medicament.note != null && medicament.note!.isNotEmpty) ...[
            SizedBox(height: SizeTokens.p8),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(SizeTokens.p8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(SizeTokens.r4),
              ),
              child: Text(
                medicament.note!,
                style: TextStyle(
                  fontSize: SizeTokens.f12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    StudentDetailViewModel viewModel,
    StudentMedicamentModel medicament,
    String locale,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppTranslations.translate('delete_medicament', locale)),
        content: Text(
          AppTranslations.translate('confirm_delete_medicament', locale),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppTranslations.translate('cancel', locale)),
          ),
          TextButton(
            onPressed: () {
              viewModel.deleteMedicament(medicament.id!);
              Navigator.pop(context);
            },
            child: Text(
              AppTranslations.translate('delete', locale),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
