import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/responsive/size_tokens.dart';
import '../../../../core/utils/app_translations.dart';
import '../../../../viewmodels/oyungrubu_student_history_view_model.dart';

class StudentEditBottomSheet extends StatefulWidget {
  final String locale;

  const StudentEditBottomSheet({super.key, required this.locale});

  @override
  State<StudentEditBottomSheet> createState() => _StudentEditBottomSheetState();
}

class _StudentEditBottomSheetState extends State<StudentEditBottomSheet> {
  File? _selectedPhoto;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Consumer<OyunGrubuStudentHistoryViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          padding: EdgeInsets.fromLTRB(
            SizeTokens.p24,
            SizeTokens.p8,
            SizeTokens.p24,
            MediaQuery.of(context).viewInsets.bottom + SizeTokens.p24,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(SizeTokens.r24),
              topRight: Radius.circular(SizeTokens.r24),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: SizeTokens.p40,
                    height: SizeTokens.p4,
                    margin: EdgeInsets.only(bottom: SizeTokens.p16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(SizeTokens.r4),
                    ),
                  ),
                ),

                // Title
                Text(
                  AppTranslations.translate('edit_student', widget.locale),
                  style: TextStyle(
                    fontSize: SizeTokens.f20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: SizeTokens.p20),

                // Photo section
                Center(
                  child: GestureDetector(
                    onTap: () async {
                      final photo = await viewModel.pickPhoto();
                      if (photo != null) {
                        setState(() {
                          _selectedPhoto = photo;
                        });
                      }
                    },
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: SizeTokens.r32,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: _selectedPhoto != null
                              ? FileImage(_selectedPhoto!)
                              : (viewModel.student?.photo != null &&
                                      viewModel.student!.photo !=
                                          'default_student.jpg'
                                  ? NetworkImage(viewModel.student!.photo!)
                                      as ImageProvider
                                  : null),
                          child: _selectedPhoto == null &&
                                  (viewModel.student?.photo == null ||
                                      viewModel.student!.photo ==
                                          'default_student.jpg')
                              ? Icon(
                                  Icons.child_care_rounded,
                                  color: primaryColor,
                                  size: SizeTokens.i32,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(SizeTokens.p6),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: SizeTokens.i12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_selectedPhoto != null)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: SizeTokens.p6),
                      child: Text(
                        AppTranslations.translate(
                            'change_photo', widget.locale),
                        style: TextStyle(
                          fontSize: SizeTokens.f10,
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: SizeTokens.p20),

                // Name field
                _buildLabel(
                  AppTranslations.translate('name', widget.locale),
                ),
                SizedBox(height: SizeTokens.p8),
                TextField(
                  controller: viewModel.nameController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.person_outline_rounded,
                      size: SizeTokens.i20,
                    ),
                  ),
                ),
                SizedBox(height: SizeTokens.p16),

                // Surname field
                _buildLabel(
                  AppTranslations.translate('surname', widget.locale),
                ),
                SizedBox(height: SizeTokens.p8),
                TextField(
                  controller: viewModel.surnameController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.person_outline_rounded,
                      size: SizeTokens.i20,
                    ),
                  ),
                ),
                SizedBox(height: SizeTokens.p16),

                // Birth date field
                _buildLabel(
                  AppTranslations.translate('birth_date', widget.locale),
                ),
                SizedBox(height: SizeTokens.p8),
                TextField(
                  controller: viewModel.birthDateController,
                  readOnly: true,
                  onTap: () => _selectDate(context, viewModel),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.cake_outlined,
                      size: SizeTokens.i20,
                    ),
                    suffixIcon: Icon(
                      Icons.calendar_today_rounded,
                      size: SizeTokens.i16,
                    ),
                    hintText: AppTranslations.translate(
                        'select_date', widget.locale),
                  ),
                ),
                SizedBox(height: SizeTokens.p16),

                // Medications field
                _buildLabel(
                  AppTranslations.translate('medications', widget.locale),
                ),
                SizedBox(height: SizeTokens.p8),
                TextField(
                  controller: viewModel.medicationsController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.medication_outlined,
                      size: SizeTokens.i20,
                    ),
                  ),
                ),
                SizedBox(height: SizeTokens.p16),

                // Allergies field
                _buildLabel(
                  AppTranslations.translate('allergies', widget.locale),
                ),
                SizedBox(height: SizeTokens.p8),
                TextField(
                  controller: viewModel.allergiesController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.warning_amber_rounded,
                      size: SizeTokens.i20,
                    ),
                  ),
                ),
                SizedBox(height: SizeTokens.p24),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: viewModel.isUpdating
                        ? null
                        : () async {
                            final success =
                                await viewModel.updateStudentProfile(
                              photo: _selectedPhoto,
                            );
                            if (success && context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppTranslations.translate(
                                      'student_updated_success',
                                      widget.locale,
                                    ),
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                    child: viewModel.isUpdating
                        ? SizedBox(
                            height: SizeTokens.i20,
                            width: SizeTokens.i20,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            AppTranslations.translate(
                              'update_student',
                              widget.locale,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: SizeTokens.f14,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade700,
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    OyunGrubuStudentHistoryViewModel viewModel,
  ) async {
    final now = DateTime.now();
    final initialDate = viewModel.birthDateController.text.isNotEmpty
        ? DateTime.tryParse(viewModel.birthDateController.text) ?? now
        : now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: now,
    );

    if (picked != null) {
      viewModel.birthDateController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }
}
