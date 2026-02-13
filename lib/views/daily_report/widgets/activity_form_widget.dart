import 'package:flutter/material.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../core/utils/app_translations.dart';
import '../../../viewmodels/student_entry_view_model.dart';

class ActivityFormWidget extends StatelessWidget {
  final StudentEntryViewModel viewModel;
  final String locale;
  final Function(BuildContext, StudentEntryViewModel, String) onAddValue;
  final Function(BuildContext, StudentEntryViewModel, String) onAddTitle;

  const ActivityFormWidget({
    super.key,
    required this.viewModel,
    required this.locale,
    required this.onAddValue,
    required this.onAddTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, AppTranslations.translate('title', locale)),
        SizedBox(height: SizeTokens.p8),
        DropdownButtonFormField<String>(
          value:
              viewModel.activityTitles.any(
                (e) => e.title == viewModel.titleController.text,
              )
              ? viewModel.titleController.text
              : null,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Theme.of(context).primaryColor,
          ),
          borderRadius: BorderRadius.circular(SizeTokens.r16),
          elevation: 8,
          dropdownColor: Colors.white,
          decoration: InputDecoration(
            hintText: AppTranslations.translate('title', locale),
            prefixIcon: Icon(
              Icons.title,
              color: Theme.of(context).primaryColor,
            ),
          ),
          items: viewModel.activityTitles
              .where((e) => e.title != null && e.title!.isNotEmpty)
              .map((e) => e.title!)
              .toSet()
              .map((val) {
                return DropdownMenuItem<String>(value: val, child: Text(val));
              })
              .toList(),
          onChanged: (val) {
            if (val != null) viewModel.setTitle(val);
          },
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => onAddTitle(context, viewModel, locale),
            icon: const Icon(Icons.add, size: 16),
            label: Text(
              AppTranslations.translate('add_new_title', locale),
              style: TextStyle(fontSize: SizeTokens.f12),
            ),
          ),
        ),
        SizedBox(height: SizeTokens.p8),
        _buildSectionTitle(context, AppTranslations.translate('value', locale)),
        SizedBox(height: SizeTokens.p8),
        DropdownButtonFormField<String>(
          value:
              viewModel.activityValues.any(
                (e) => e.value == viewModel.selectedActivityValue,
              )
              ? viewModel.selectedActivityValue
              : null,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Theme.of(context).primaryColor,
          ),
          borderRadius: BorderRadius.circular(SizeTokens.r16),
          elevation: 8,
          dropdownColor: Colors.white,
          decoration: InputDecoration(
            hintText: AppTranslations.translate('value', locale),
            prefixIcon: Icon(
              Icons.assessment_outlined,
              color: Theme.of(context).primaryColor,
            ),
          ),
          items: viewModel.activityValues
              .where((e) => e.value != null && e.value!.isNotEmpty)
              .map((e) => e.value!)
              .toSet()
              .map((val) {
                return DropdownMenuItem<String>(value: val, child: Text(val));
              })
              .toList(),
          onChanged: (val) => viewModel.setSelectedActivityValue(val),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => onAddValue(context, viewModel, locale),
            icon: const Icon(Icons.add_circle_outline, size: 16),
            label: Text(
              AppTranslations.translate('add_new_value', locale),
              style: TextStyle(fontSize: SizeTokens.f12),
            ),
          ),
        ),
        SizedBox(height: SizeTokens.p8),
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
}
