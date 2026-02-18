import 'package:flutter/material.dart';
import '../../../../core/responsive/size_tokens.dart';
import '../../../../core/utils/app_translations.dart';
import '../../../../viewmodels/student_entry_view_model.dart';

class NoteFormWidget extends StatelessWidget {
  final StudentEntryViewModel viewModel;
  final String locale;

  const NoteFormWidget({
    super.key,
    required this.viewModel,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTranslations.translate('enter_note', locale),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(height: SizeTokens.p12),
        TextField(
          controller: viewModel.noteController,
          maxLines: 12,
          decoration: InputDecoration(
            hintText: AppTranslations.translate('enter_note', locale),
            alignLabelWithHint: true,
            fillColor: Theme.of(context).cardColor,
          ),
        ),
      ],
    );
  }
}
