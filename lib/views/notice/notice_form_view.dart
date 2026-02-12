import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../models/notice_model.dart';
import '../../models/class_model.dart';
import '../../viewmodels/notice_form_view_model.dart';
import '../../viewmodels/landing_view_model.dart';
import '../../core/responsive/size_tokens.dart';
import '../../core/utils/app_translations.dart';
import '../../core/ui_components/common_widgets.dart';

class NoticeFormView extends StatelessWidget {
  final UserModel user;
  final NoticeModel? notice;
  final List<ClassModel> classes;
  final int? initialClassId;

  const NoticeFormView({
    super.key,
    required this.user,
    this.notice,
    required this.classes,
    this.initialClassId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          NoticeFormViewModel()
            ..init(user, notice: notice, initialClassId: initialClassId),
      child: _NoticeFormContent(isEdit: notice != null, classes: classes),
    );
  }
}

class _NoticeFormContent extends StatelessWidget {
  final bool isEdit;
  final List<ClassModel> classes;

  const _NoticeFormContent({required this.isEdit, required this.classes});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NoticeFormViewModel>();
    final locale = context.watch<LandingViewModel>().locale.languageCode;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: BaseAppBar(
        title: Text(
          AppTranslations.translate(
            isEdit ? 'edit_notice' : 'add_notice',
            locale,
          ),
          style: TextStyle(
            fontSize: SizeTokens.f18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(SizeTokens.p20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel(AppTranslations.translate('notice_title', locale)),
            SizedBox(height: SizeTokens.p8),
            _buildTextField(viewModel.titleController, Icons.title_rounded),

            SizedBox(height: SizeTokens.p20),

            _buildLabel(
              AppTranslations.translate('notice_description', locale),
            ),
            SizedBox(height: SizeTokens.p8),
            _buildTextField(
              viewModel.descriptionController,
              Icons.description_rounded,
              maxLines: 5,
            ),

            SizedBox(height: SizeTokens.p20),

            _buildLabel(AppTranslations.translate('select_class', locale)),
            SizedBox(height: SizeTokens.p8),
            _buildClassDropdown(context, viewModel, locale),

            SizedBox(height: SizeTokens.p20),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(AppTranslations.translate('date', locale)),
                      SizedBox(height: SizeTokens.p8),
                      _buildDatePicker(context, viewModel),
                    ],
                  ),
                ),
                SizedBox(width: SizeTokens.p16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(AppTranslations.translate('status', locale)),
                      SizedBox(height: SizeTokens.p16),
                      _buildStatusSwitch(context, viewModel, locale),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: SizeTokens.p40),

            if (viewModel.errorMessage != null)
              Padding(
                padding: EdgeInsets.only(bottom: SizeTokens.p16),
                child: Text(
                  viewModel.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            SizedBox(
              width: double.infinity,
              height: SizeTokens.h52,
              child: ElevatedButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () async {
                        final success = await viewModel.saveNotice();
                        if (success && context.mounted) {
                          Navigator.pop(context, true);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SizeTokens.r12),
                  ),
                  elevation: 0,
                ),
                child: viewModel.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        AppTranslations.translate('save', locale),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: SizeTokens.f14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(SizeTokens.p16),
        ),
      ),
    );
  }

  Widget _buildClassDropdown(
    BuildContext context,
    NoticeFormViewModel viewModel,
    String locale,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: SizeTokens.p12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: viewModel.selectedClassId,
          isExpanded: true,
          hint: Text(AppTranslations.translate('all', locale)),
          onChanged: (val) => viewModel.setClassId(val),
          items: [
            DropdownMenuItem(
              value: 0,
              child: Text(AppTranslations.translate('all', locale)),
            ),
            ...classes.map(
              (c) => DropdownMenuItem(value: c.id, child: Text(c.name ?? '')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, NoticeFormViewModel viewModel) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: viewModel.selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (date != null) viewModel.setDate(date);
      },
      child: Container(
        height: SizeTokens.h50,
        padding: EdgeInsets.symmetric(horizontal: SizeTokens.p16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SizeTokens.r12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: SizeTokens.i20,
              color: Colors.grey.shade400,
            ),
            SizedBox(width: SizeTokens.p12),
            Text(
              "${viewModel.selectedDate.day}.${viewModel.selectedDate.month}.${viewModel.selectedDate.year}",
              style: TextStyle(fontSize: SizeTokens.f14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSwitch(
    BuildContext context,
    NoticeFormViewModel viewModel,
    String locale,
  ) {
    return Container(
      height: SizeTokens.h50,
      padding: EdgeInsets.symmetric(horizontal: SizeTokens.p12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppTranslations.translate(
              viewModel.status == 1 ? 'active' : 'passive',
              locale,
            ),
            style: TextStyle(fontSize: SizeTokens.f14),
          ),
          Switch.adaptive(
            value: viewModel.status == 1,
            onChanged: (val) => viewModel.setStatus(val ? 1 : 0),
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}
