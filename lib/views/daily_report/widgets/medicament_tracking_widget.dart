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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(SizeTokens.p24),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.medical_services_outlined,
                size: SizeTokens.i64,
                color: Colors.blue[300],
              ),
            ),
            SizedBox(height: SizeTokens.p24),
            Text(
              AppTranslations.translate('no_medicaments_found', locale),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
                fontSize: SizeTokens.f16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(SizeTokens.p16),
      itemCount: viewModel.medicaments.length,
      separatorBuilder: (context, index) => SizedBox(height: SizeTokens.p16),
      itemBuilder: (context, index) {
        final medicament = viewModel.medicaments[index];
        // Check if there is a daily record matching this medicament by medicamentId
        final isTaken = viewModel.dailyData.any(
          (d) => d.medicamentId == medicament.id,
        );

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
      padding: EdgeInsets.all(SizeTokens.p16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicament.title ?? '',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: SizeTokens.p4),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeTokens.p8,
                        vertical: SizeTokens.p4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(SizeTokens.r8),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: SizeTokens.f12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (medicament.status != 0) // Allergies might not need "taking"
                IconButton(
                  onPressed: () {
                    viewModel.toggleMedicament(
                      medicamentId: medicament.id!,
                      userId: user.id ?? 0,
                    );
                  },
                  icon: Icon(
                    isTaken ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isTaken ? Colors.green : Colors.grey,
                    size: SizeTokens.i32,
                  ),
                ),
              if (user.role == 'parent' || user.role == 'superadmin')
                IconButton(
                  onPressed: () =>
                      _confirmDelete(context, viewModel, medicament, locale),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
            ],
          ),
          if (medicament.value != null && medicament.value!.isNotEmpty) ...[
            SizedBox(height: SizeTokens.p8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                SizedBox(width: SizeTokens.p8),
                Text(medicament.value!),
              ],
            ),
          ],
          if (medicament.note != null && medicament.note!.isNotEmpty) ...[
            SizedBox(height: SizeTokens.p8),
            Text(
              medicament.note!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
                fontStyle: FontStyle.italic,
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
