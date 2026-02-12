import 'package:flutter/material.dart';
import '../../../core/responsive/size_tokens.dart';
import '../../../core/utils/app_translations.dart';
import '../../../viewmodels/student_entry_view_model.dart';

class ReceivingFormWidget extends StatelessWidget {
  final StudentEntryViewModel viewModel;
  final String locale;
  final VoidCallback onTimeTap;

  const ReceivingFormWidget({
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
          AppTranslations.translate('recipient', locale),
        ),
        SizedBox(height: SizeTokens.p8),
        TextField(
          controller: viewModel.recipientController,
          decoration: InputDecoration(
            hintText: AppTranslations.translate('recipient', locale),
            prefixIcon: Icon(
              Icons.person_outline,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        SizedBox(height: SizeTokens.p16),
        _buildSectionTitle(context, AppTranslations.translate('time', locale)),
        SizedBox(height: SizeTokens.p8),
        TextField(
          controller: viewModel.timeController,
          readOnly: true,
          onTap: onTimeTap,
          decoration: InputDecoration(
            hintText: AppTranslations.translate('time', locale),
            prefixIcon: Icon(
              Icons.access_time,
              color: Theme.of(context).primaryColor,
            ),
            suffixIcon: const Icon(Icons.arrow_drop_down),
          ),
        ),
        SizedBox(height: SizeTokens.p16),
        _buildSectionTitle(context, AppTranslations.translate('note', locale)),
        SizedBox(height: SizeTokens.p8),
        TextField(
          controller: viewModel.noteController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: AppTranslations.translate('note', locale),
            prefixIcon: Icon(
              Icons.note_alt_outlined,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        if (viewModel.user.role == 'teacher' ||
            viewModel.user.role == 'superadmin') ...[
          SizedBox(height: SizeTokens.p24),
          _buildStatusToggle(context),
        ],
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

  Widget _buildStatusToggle(BuildContext context) {
    final isReady = viewModel.receivingStatus == 1;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.p16,
        vertical: SizeTokens.p12,
      ),
      decoration: BoxDecoration(
        color: isReady
            ? Colors.green.withOpacity(0.05)
            : Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(SizeTokens.r12),
        border: Border.all(
          color: isReady
              ? Colors.green.withOpacity(0.2)
              : Theme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppTranslations.translate('status', locale),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: SizeTokens.f14,
                    color: isReady
                        ? Colors.green.shade700
                        : Theme.of(context).primaryColor,
                  ),
                ),
                Text(
                  isReady
                      ? AppTranslations.translate('ready_to_receive', locale)
                      : AppTranslations.translate('not_ready', locale),
                  style: TextStyle(
                    color: isReady
                        ? Colors.green
                        : Theme.of(context).primaryColor,
                    fontSize: SizeTokens.f12,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isReady,
            onChanged: (val) => viewModel.setReceivingStatus(val ? 1 : 0),
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }
}
