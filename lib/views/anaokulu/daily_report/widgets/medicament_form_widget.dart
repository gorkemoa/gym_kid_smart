import 'package:flutter/material.dart';
import '../../../../core/responsive/size_tokens.dart';
import '../../../../core/utils/app_translations.dart';
import '../../../../viewmodels/student_entry_view_model.dart';

class MedicamentFormWidget extends StatelessWidget {
  final StudentEntryViewModel viewModel;
  final String locale;
  final VoidCallback onTimeTap;

  const MedicamentFormWidget({
    super.key,
    required this.viewModel,
    required this.locale,
    required this.onTimeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          context,
          AppTranslations.translate('medicament_name', locale),
        ),
        SizedBox(height: SizeTokens.p8),
        TextField(
          controller: viewModel.titleController,
          decoration: InputDecoration(
            hintText: AppTranslations.translate('medicament_name_hint', locale),
            prefixIcon: Icon(
              Icons.medication_outlined,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        SizedBox(height: SizeTokens.p16),
        _buildSectionTitle(context, AppTranslations.translate('time', locale)),
        SizedBox(height: SizeTokens.p8),
        GestureDetector(
          onTap: onTimeTap,
          child: AbsorbPointer(
            child: TextField(
              controller: viewModel.timeController,
              decoration: InputDecoration(
                hintText: '00:00',
                prefixIcon: Icon(
                  Icons.access_time,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: SizeTokens.p16),
        _buildSectionTitle(
          context,
          AppTranslations.translate('status', locale),
        ),
        SizedBox(height: SizeTokens.p8),
        _buildStatusSelector(context),
        SizedBox(height: SizeTokens.p16),
        _buildSectionTitle(context, AppTranslations.translate('note', locale)),
        SizedBox(height: SizeTokens.p8),
        TextField(
          controller: viewModel.noteController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: AppTranslations.translate('note', locale),
            alignLabelWithHint: true,
            prefixIcon: Icon(
              Icons.note_alt_outlined,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildStatusSelector(BuildContext context) {
    final statuses = [
      {
        'value': 0,
        'label': AppTranslations.translate('allergy', locale),
        'color': Colors.red,
      },
      {
        'value': 1,
        'label': AppTranslations.translate('important', locale),
        'color': Theme.of(context).primaryColor,
      },
      {
        'value': 2,
        'label': AppTranslations.translate('less_important', locale),
        'color': Colors.blue,
      },
    ];

    return Row(
      children: statuses.map((status) {
        final isSelected = viewModel.medicamentStatus == status['value'];
        final color = status['color'] as Color;

        return Expanded(
          child: GestureDetector(
            onTap: () => viewModel.setMedicamentStatus(status['value'] as int),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: SizeTokens.p4),
              padding: EdgeInsets.symmetric(vertical: SizeTokens.p12),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.white,
                borderRadius: BorderRadius.circular(SizeTokens.r12),
                border: Border.all(
                  color: isSelected ? color : Colors.grey.shade300,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                status['label'] as String,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: SizeTokens.f12,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
