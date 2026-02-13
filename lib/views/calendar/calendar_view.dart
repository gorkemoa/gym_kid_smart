import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/responsive/size_tokens.dart';
import '../../core/ui_components/common_widgets.dart';
import '../../viewmodels/calendar_view_model.dart';
import '../../viewmodels/login_view_model.dart';
import '../../viewmodels/landing_view_model.dart';
import '../../models/class_model.dart';
import '../../models/calendar_detail_model.dart';
import '../../models/user_model.dart';
import '../../core/utils/app_translations.dart';
import 'widgets/calendar_widget.dart';
import 'widgets/time_table_card.dart';
import 'widgets/meal_menu_card.dart';
import 'widgets/gallery_grid_item.dart';

class CalendarView extends StatelessWidget {
  final UserModel? user;
  final bool showAppBar;
  const CalendarView({super.key, this.user, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalendarViewModel(),
      child: _CalendarViewContent(user: user, showAppBar: showAppBar),
    );
  }
}

class _CalendarViewContent extends StatefulWidget {
  final UserModel? user;
  final bool showAppBar;
  const _CalendarViewContent({this.user, this.showAppBar = true});

  @override
  State<_CalendarViewContent> createState() => _CalendarViewContentState();
}

class _CalendarViewContentState extends State<_CalendarViewContent>
    with TickerProviderStateMixin {
  late TabController _tabController;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<CalendarViewModel>();
      final currentUser =
          widget.user ?? context.read<LoginViewModel>().data?.data;
      if (currentUser != null) {
        viewModel.init(currentUser);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CalendarViewModel>();
    final locale = context.watch<LandingViewModel>().locale.languageCode;
    final user = context.read<LoginViewModel>().data?.data;
    final isAuthorized = user?.role == 'superadmin' || user?.role == 'teacher';

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: widget.showAppBar
          ? BaseAppBar(
              title: Text(
                AppTranslations.translate('calendar', locale),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: SizeTokens.f18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              automaticallyImplyLeading: true,
              actions: [
                if (isAuthorized)
                  Padding(
                    padding: EdgeInsets.only(right: SizeTokens.p8),
                    child: TextButton.icon(
                      onPressed: () => _handleFabPressed(viewModel, locale),
                      icon: Icon(
                        _tabController.index == 2
                            ? Icons.add_a_photo_rounded
                            : _tabController.index == 1
                            ? Icons.restaurant_menu_rounded
                            : Icons.add_task_rounded,
                        color: Theme.of(context).primaryColor,
                        size: SizeTokens.i20,
                      ),
                      label: Text(
                        _tabController.index == 2
                            ? AppTranslations.translate('add_photo', locale)
                            : _tabController.index == 1
                            ? AppTranslations.translate('add_meal', locale)
                            : AppTranslations.translate('add_lesson', locale),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: SizeTokens.f12,
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : null,
      body: viewModel.isLoading && viewModel.classes.isEmpty
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : RefreshIndicator(
              onRefresh: () async => viewModel.refresh(),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.only(bottom: SizeTokens.p16),
                      child: Column(
                        children: [
                          if (viewModel.classes.length > 1)
                            _buildClassSelector(viewModel, locale),
                          CalendarWidget(
                            selectedDate: viewModel.selectedDate,
                            format: _calendarFormat,
                            locale: locale,
                            onDaySelected: (selectedDay, focusedDay) {
                              viewModel.onDateSelected(selectedDay);
                            },
                            onFormatChanged: (format) {
                              setState(() {
                                _calendarFormat = format;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      SizeTokens.p16,
                      SizeTokens.p16,
                      SizeTokens.p16,
                      SizeTokens.p8,
                    ),
                    sliver: SliverToBoxAdapter(child: _buildTabBar(locale)),
                  ),
                  SliverFillRemaining(
                    child: viewModel.isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColor,
                            ),
                          )
                        : _buildTabBarView(viewModel, locale, isAuthorized),
                  ),
                ],
              ),
            ),
    );
  }

  void _handleFabPressed(CalendarViewModel viewModel, String locale) async {
    if (_tabController.index == 2) {
      final success = await viewModel.pickAndUploadGalleryImage();
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppTranslations.translate('upload_success', locale)),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else if (_tabController.index == 0) {
      _showAddTimeTableDialog(context, viewModel, locale);
    } else if (_tabController.index == 1) {
      _showAddMealMenuDialog(context, viewModel, locale);
    }
  }

  Widget _buildClassSelector(CalendarViewModel viewModel, String locale) {
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: SizeTokens.p16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ClassModel>(
          value: viewModel.selectedClass,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: primaryColor),
          onChanged: (val) => viewModel.onClassSelected(val),
          items: viewModel.classes.map((c) {
            return DropdownMenuItem(
              value: c,
              child: Text(
                c.name ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: SizeTokens.f14,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTabBar(String locale) {
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: primaryColor,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: SizeTokens.f12,
        ),
        tabs: [
          Tab(text: AppTranslations.translate('time_table', locale)),
          Tab(text: AppTranslations.translate('meal_menu_title', locale)),
          Tab(text: AppTranslations.translate('gallery_title', locale)),
        ],
      ),
    );
  }

  Widget _buildTabBarView(
    CalendarViewModel viewModel,
    String locale,
    bool isAuthorized,
  ) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildTimeTable(viewModel, locale, isAuthorized),
        _buildMealMenu(viewModel, locale, isAuthorized),
        _buildGallery(viewModel, locale, isAuthorized),
      ],
    );
  }

  Widget _buildTimeTable(
    CalendarViewModel viewModel,
    String locale,
    bool isAuthorized,
  ) {
    final timeTable = viewModel.data?.timeTable;
    if (timeTable == null || timeTable.isEmpty) {
      return _buildEmptyState(
        AppTranslations.translate('no_lesson_found', locale),
        Icons.event_busy_rounded,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(SizeTokens.p16),
      itemCount: timeTable.length,
      itemBuilder: (context, index) => TimeTableCard(
        item: timeTable[index],
        isAuthorized: isAuthorized,
        locale: locale,
        onDelete: () => _confirmDelete(
          context: context,
          locale: locale,
          onConfirm: () => viewModel.deleteTimeTableEntry(
            lessonId: timeTable[index].lesson?.id ?? 0,
          ),
        ),
      ),
    );
  }

  Widget _buildMealMenu(
    CalendarViewModel viewModel,
    String locale,
    bool isAuthorized,
  ) {
    final meals = viewModel.data?.mealMenus;
    if (meals == null || meals.isEmpty) {
      return _buildEmptyState(
        AppTranslations.translate('no_menu_found', locale),
        Icons.no_food_rounded,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(SizeTokens.p16),
      itemCount: meals.length,
      itemBuilder: (context, index) => MealMenuCard(
        meal: meals[index],
        isAuthorized: isAuthorized,
        locale: locale,
        onDelete: () => _confirmDelete(
          context: context,
          locale: locale,
          onConfirm: () =>
              viewModel.deleteMealMenuEntry(time: meals[index].time ?? ""),
        ),
      ),
    );
  }

  Widget _buildGallery(
    CalendarViewModel viewModel,
    String locale,
    bool isAuthorized,
  ) {
    final gallery = viewModel.data?.gallery;
    if (gallery == null || gallery.isEmpty) {
      return _buildEmptyState(
        AppTranslations.translate('no_gallery_found', locale),
        Icons.no_photography_rounded,
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(SizeTokens.p16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: SizeTokens.p12,
        mainAxisSpacing: SizeTokens.p12,
      ),
      itemCount: gallery.length,
      itemBuilder: (context, index) => GalleryGridItem(
        item: gallery[index],
        isAuthorized: isAuthorized,
        onTap: () => _showFullImage(context, gallery[index].image ?? ""),
        onDelete: () => _confirmDelete(
          context: context,
          locale: locale,
          onConfirm: () => viewModel.deleteGalleryImage(gallery[index].id ?? 0),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: SizeTokens.i64, color: Colors.grey[300]),
          SizedBox(height: SizeTokens.p16),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: SizeTokens.f14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showFullImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.black.withOpacity(0.8)),
            ),
            InteractiveViewer(child: Image.network(url)),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete({
    required BuildContext context,
    required String locale,
    required Future<bool> Function() onConfirm,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeTokens.r16),
        ),
        title: Text(AppTranslations.translate('delete', locale)),
        content: Text(AppTranslations.translate('delete_confirmation', locale)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppTranslations.translate('cancel', locale)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppTranslations.translate('delete', locale),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await onConfirm();
      if (context.mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppTranslations.translate('delete_success', locale)),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Dialogs for add operations (Keeping these structured but corporate looking)
  void _showAddMealMenuDialog(
    BuildContext context,
    CalendarViewModel viewModel,
    String locale,
  ) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final menuController = TextEditingController();
    TimeOfDay selectedTime = const TimeOfDay(hour: 12, minute: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SizeTokens.r24),
        ),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppTranslations.translate('add_meal_menu', locale),
                    style: TextStyle(
                      fontSize: SizeTokens.f20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: AppTranslations.translate(
                        'meal_title',
                        locale,
                      ),
                    ),
                    validator: (val) => val!.isEmpty ? '' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: menuController,
                    decoration: InputDecoration(
                      labelText: AppTranslations.translate(
                        'meal_content',
                        locale,
                      ),
                    ),
                    maxLines: 3,
                    validator: (val) => val!.isEmpty ? '' : null,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (picked != null)
                        setModalState(() => selectedTime = picked);
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: AppTranslations.translate('time', locale),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedTime.format(context),
                            style: TextStyle(fontSize: SizeTokens.f16),
                          ),
                          Icon(
                            Icons.access_time,
                            color: Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final timeStr =
                            "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}";
                        final success = await viewModel.addMealMenu(
                          title: titleController.text,
                          menu: menuController.text,
                          time: timeStr,
                        );
                        if (success && context.mounted) Navigator.pop(context);
                      }
                    },
                    child: Text(AppTranslations.translate('save', locale)),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddTimeTableDialog(
    BuildContext context,
    CalendarViewModel viewModel,
    String locale,
  ) {
    final formKey = GlobalKey<FormState>();
    LessonModel? selectedLesson;
    final descriptionController = TextEditingController();
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 0);
    File? selectedFile;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SizeTokens.r24),
        ),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppTranslations.translate('add_time_table', locale),
                    style: TextStyle(
                      fontSize: SizeTokens.f20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<LessonModel>(
                    decoration: InputDecoration(
                      labelText: AppTranslations.translate('lesson', locale),
                    ),
                    items: viewModel.lessons
                        .map(
                          (l) => DropdownMenuItem(
                            value: l,
                            child: Text(l.title ?? ''),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => selectedLesson = val,
                    validator: (val) => val == null ? '' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: AppTranslations.translate(
                        'description',
                        locale,
                      ),
                    ),
                    maxLines: 3,
                    validator: (val) => val!.isEmpty ? '' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: startTime,
                            );
                            if (picked != null)
                              setModalState(() => startTime = picked);
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: AppTranslations.translate(
                                'start_time',
                                locale,
                              ),
                            ),
                            child: Text(startTime.format(context)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: endTime,
                            );
                            if (picked != null)
                              setModalState(() => endTime = picked);
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: AppTranslations.translate(
                                'end_time',
                                locale,
                              ),
                            ),
                            child: Text(endTime.format(context)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: EdgeInsets.all(SizeTokens.p8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(SizeTokens.r8),
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.red,
                      ),
                    ),
                    title: Text(
                      selectedFile != null
                          ? selectedFile!.path.split('/').last
                          : AppTranslations.translate('attach_pdf', locale),
                    ),
                    trailing: selectedFile != null
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () =>
                                setModalState(() => selectedFile = null),
                          )
                        : const Icon(Icons.attach_file),
                    onTap: () async {
                      final file = await viewModel.pickPdfFile();
                      if (file != null)
                        setModalState(() => selectedFile = file);
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final startStr =
                            "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}";
                        final endStr =
                            "${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}";
                        final success = await viewModel.addTimeTable(
                          lessonId: selectedLesson!.id!,
                          description: descriptionController.text,
                          startTime: startStr,
                          endTime: endStr,
                          file: selectedFile,
                        );
                        if (success && context.mounted) Navigator.pop(context);
                      }
                    },
                    child: Text(AppTranslations.translate('save', locale)),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
