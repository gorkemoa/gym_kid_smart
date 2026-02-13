import 'package:flutter/material.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../core/utils/app_translations.dart';
import '../../../viewmodels/student_entry_view_model.dart';
import '../../../core/network/api_result.dart';

class SocialFormWidget extends StatelessWidget {
  final StudentEntryViewModel viewModel;
  final String locale;
  final Function(BuildContext, StudentEntryViewModel, String) onAddValue;

  const SocialFormWidget({
    super.key,
    required this.viewModel,
    required this.locale,
    required this.onAddValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, AppTranslations.translate('title', locale)),
        SizedBox(height: SizeTokens.p8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: viewModel.titleController,
                decoration: InputDecoration(
                  hintText: AppTranslations.translate('title', locale),
                  prefixIcon: Icon(
                    Icons.diversity_3_outlined,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
            if (viewModel.socialTitles.isNotEmpty)
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.history,
                  color: Theme.of(context).primaryColor,
                ),
                onSelected: (val) => viewModel.setTitle(val),
                itemBuilder: (context) => viewModel.socialTitles
                    .map(
                      (t) => PopupMenuItem<String>(
                        value: t.title,
                        child: Text(t.title ?? ''),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => _handleSaveTemplate(context),
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
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value:
                    viewModel.activityValues.any(
                      (e) => e.value == viewModel.selectedActivityValue,
                    )
                    ? viewModel.selectedActivityValue
                    : null,
                decoration: InputDecoration(
                  hintText: AppTranslations.translate('value', locale),
                  prefixIcon: Icon(
                    Icons.star_outline,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                items: viewModel.activityValues
                    .where((e) => e.value != null && e.value!.isNotEmpty)
                    .map((e) => e.value!)
                    .toSet() // Remove duplicates
                    .map((val) {
                      return DropdownMenuItem<String>(
                        value: val,
                        child: Text(val),
                      );
                    })
                    .toList(),
                onChanged: (val) => viewModel.setSelectedActivityValue(val),
              ),
            ),
          ],
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

  Future<void> _handleSaveTemplate(BuildContext context) async {
    final result = await viewModel.saveSocialTitleAsTemplate();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result is Success
                ? AppTranslations.translate('save_success', locale)
                : (result as Failure).message,
          ),
          backgroundColor: result is Success ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
