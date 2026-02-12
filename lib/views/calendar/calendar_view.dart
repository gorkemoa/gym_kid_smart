import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gym_kid_smart/models/calendar_detail_model.dart';
import 'package:gym_kid_smart/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/responsive/size_tokens.dart';
import '../../core/ui_components/common_widgets.dart';
import '../../viewmodels/calendar_view_model.dart';
import '../../viewmodels/login_view_model.dart';
import '../../viewmodels/landing_view_model.dart';
import '../../models/class_model.dart';
import '../../core/utils/app_translations.dart';

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
            )
          : null,
      body: viewModel.isLoading && viewModel.classes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (viewModel.classes.length > 1)
                  _buildClassSelector(viewModel, locale),
                _buildCalendar(viewModel, locale),
                SizedBox(height: SizeTokens.p16),
                _buildTabBar(locale),
                Expanded(
                  child: viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildTabBarView(viewModel, locale),
                ),
              ],
            ),
      floatingActionButton:
          isAuthorized &&
              (_tabController.index == 0 ||
                  _tabController.index == 1 ||
                  _tabController.index == 2)
          ? FloatingActionButton(
              onPressed: () async {
                if (_tabController.index == 2) {
                  final success = await viewModel.pickAndUploadGalleryImage();
                  if (context.mounted) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppTranslations.translate('upload_success', locale),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else if (viewModel.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(viewModel.errorMessage!),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } else if (_tabController.index == 0) {
                  _showAddTimeTableDialog(context, viewModel, locale);
                } else if (_tabController.index == 1) {
                  _showAddMealMenuDialog(context, viewModel, locale);
                }
              },
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(
                _tabController.index == 2
                    ? Icons.add_a_photo
                    : _tabController.index == 1
                    ? Icons.restaurant_menu
                    : Icons.add_task,
                color: Colors.white,
              ),
            )
          : null,
    );
  }

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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
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
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: AppTranslations.translate(
                        'meal_title',
                        locale,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (val) => val!.isEmpty ? '' : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: menuController,
                    decoration: InputDecoration(
                      labelText: AppTranslations.translate(
                        'meal_content',
                        locale,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (val) => val!.isEmpty ? '' : null,
                  ),
                  const SizedBox(height: 15),
                  InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (picked != null) {
                        setModalState(() => selectedTime = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: AppTranslations.translate('time', locale),
                        border: const OutlineInputBorder(),
                      ),
                      child: Text(selectedTime.format(context)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          final timeStr =
                              "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}";

                          final success = await viewModel.addMealMenu(
                            title: titleController.text,
                            menu: menuController.text,
                            time: timeStr,
                          );

                          if (success && context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppTranslations.translate(
                                    'save_success',
                                    locale,
                                  ),
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                      },
                      child: Text(
                        AppTranslations.translate('save', locale),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
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
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<LessonModel>(
                    decoration: InputDecoration(
                      labelText: AppTranslations.translate('lesson', locale),
                      border: const OutlineInputBorder(),
                    ),
                    items: viewModel.lessons.map((l) {
                      return DropdownMenuItem(
                        value: l,
                        child: Text(l.title ?? ''),
                      );
                    }).toList(),
                    onChanged: (val) => selectedLesson = val,
                    validator: (val) => val == null ? '' : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: AppTranslations.translate(
                        'description',
                        locale,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (val) => val!.isEmpty ? '' : null,
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: startTime,
                            );
                            if (picked != null) {
                              setModalState(() => startTime = picked);
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: AppTranslations.translate(
                                'start_time',
                                locale,
                              ),
                              border: const OutlineInputBorder(),
                            ),
                            child: Text(startTime.format(context)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: endTime,
                            );
                            if (picked != null) {
                              setModalState(() => endTime = picked);
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: AppTranslations.translate(
                                'end_time',
                                locale,
                              ),
                              border: const OutlineInputBorder(),
                            ),
                            child: Text(endTime.format(context)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ListTile(
                    leading: const Icon(Icons.picture_as_pdf),
                    title: Text(
                      selectedFile != null
                          ? selectedFile!.path.split('/').last
                          : AppTranslations.translate('attach_pdf', locale),
                    ),
                    subtitle: selectedFile != null
                        ? null
                        : const Text("PDF only"),
                    trailing: selectedFile != null
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () =>
                                setModalState(() => selectedFile = null),
                          )
                        : const Icon(Icons.attach_file),
                    onTap: () async {
                      final file = await viewModel.pickPdfFile();
                      if (file != null) {
                        setModalState(() => selectedFile = file);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
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
                          if (success && context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppTranslations.translate(
                                    'save_success',
                                    locale,
                                  ),
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                      },
                      child: Text(
                        AppTranslations.translate('save', locale),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClassSelector(CalendarViewModel viewModel, String locale) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeTokens.p16,
        vertical: SizeTokens.p8,
      ),
      color: Colors.white,
      child: Row(
        children: [
          Text(
            "${AppTranslations.translate('select_class', locale)}: ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: SizeTokens.f16,
            ),
          ),
          SizedBox(width: SizeTokens.p12),
          Expanded(
            child: DropdownButton<ClassModel>(
              value: viewModel.selectedClass,
              isExpanded: true,
              underline: Container(height: 1, color: Colors.grey[300]),
              onChanged: (ClassModel? newValue) {
                viewModel.onClassSelected(newValue);
              },
              items: viewModel.classes.map<DropdownMenuItem<ClassModel>>((
                ClassModel value,
              ) {
                return DropdownMenuItem<ClassModel>(
                  value: value,
                  child: Text(value.name ?? ''),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(CalendarViewModel viewModel, String locale) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(bottom: SizeTokens.p8),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 10, 16),
        lastDay: DateTime.utc(2030, 3, 14),
        focusedDay: viewModel.selectedDate,
        calendarFormat: _calendarFormat,
        locale: locale,
        availableCalendarFormats: const {
          CalendarFormat.month: 'Month',
          CalendarFormat.twoWeeks: '2 Weeks',
          CalendarFormat.week: 'Week',
        },
        selectedDayPredicate: (day) {
          return isSameDay(viewModel.selectedDate, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          viewModel.onDateSelected(selectedDay);
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        calendarStyle: CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(String locale) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Theme.of(context).primaryColor,
        tabs: [
          Tab(text: AppTranslations.translate('time_table', locale)),
          Tab(text: AppTranslations.translate('meal_menu_title', locale)),
          Tab(text: AppTranslations.translate('gallery_title', locale)),
        ],
      ),
    );
  }

  Widget _buildTabBarView(CalendarViewModel viewModel, String locale) {
    if (viewModel.data == null) {
      // If no data loaded yet (and not loading), or error
      if (viewModel.errorMessage != null) {
        return Center(child: Text(viewModel.errorMessage!));
      }
      return const Center(child: Text(""));
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildTimeTable(viewModel, locale),
        _buildMealMenu(viewModel, locale),
        _buildGallery(viewModel, locale),
      ],
    );
  }

  Widget _buildTimeTable(CalendarViewModel viewModel, String locale) {
    final timeTable = viewModel.data?.timeTable;
    if (timeTable == null || timeTable.isEmpty) {
      return Center(
        child: Text(AppTranslations.translate('no_lesson_found', locale)),
      );
    }

    final user = context.read<LoginViewModel>().data?.data;
    final isAuthorized = user?.role == 'superadmin' || user?.role == 'teacher';

    return ListView.builder(
      padding: EdgeInsets.all(SizeTokens.p16),
      itemCount: timeTable.length,
      itemBuilder: (context, index) {
        final item = timeTable[index];
        return Card(
          elevation: 2,
          margin: EdgeInsets.only(bottom: SizeTokens.p12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeTokens.r12),
          ),
          child: Padding(
            padding: EdgeInsets.all(SizeTokens.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.lesson?.title ?? "",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: SizeTokens.f18,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: SizeTokens.p8,
                            vertical: SizeTokens.p4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(SizeTokens.r8),
                          ),
                          child: Text(
                            "${item.startTime} - ${item.endTime}",
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isAuthorized)
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(
                                    AppTranslations.translate('delete', locale),
                                  ),
                                  content: Text(
                                    AppTranslations.translate(
                                      'delete_confirmation',
                                      locale,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: Text(
                                        AppTranslations.translate(
                                          'cancel',
                                          locale,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: Text(
                                        AppTranslations.translate(
                                          'delete',
                                          locale,
                                        ),
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                final success = await viewModel
                                    .deleteTimeTableEntry(
                                      lessonId: item.lesson?.id ?? 0,
                                    );
                                if (context.mounted) {
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          AppTranslations.translate(
                                            'delete_success',
                                            locale,
                                          ),
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } else if (viewModel.errorMessage != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(viewModel.errorMessage!),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: SizeTokens.p8),
                Text(
                  item.description ?? "",
                  style: TextStyle(color: Colors.grey[700]),
                ),
                SizedBox(height: SizeTokens.p8),
                if (item.creator != null)
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: SizeTokens.i16,
                        color: Colors.grey,
                      ),
                      SizedBox(width: SizeTokens.p4),
                      Text(
                        "${item.creator!.name} ${item.creator!.surname}",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: SizeTokens.f14,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMealMenu(CalendarViewModel viewModel, String locale) {
    final meals = viewModel.data?.mealMenus;
    if (meals == null || meals.isEmpty) {
      return Center(
        child: Text(AppTranslations.translate('no_menu_found', locale)),
      );
    }

    final user = context.read<LoginViewModel>().data?.data;
    final isAuthorized = user?.role == 'superadmin' || user?.role == 'teacher';

    return ListView.builder(
      padding: EdgeInsets.all(SizeTokens.p16),
      itemCount: meals.length,
      itemBuilder: (context, index) {
        final meal = meals[index];
        return Card(
          elevation: 2,
          margin: EdgeInsets.only(bottom: SizeTokens.p12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeTokens.r12),
          ),
          child: Padding(
            padding: EdgeInsets.all(SizeTokens.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        meal.title ?? "",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: SizeTokens.f18,
                        ),
                      ),
                    ),
                    if (isAuthorized)
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                AppTranslations.translate('delete', locale),
                              ),
                              content: Text(
                                AppTranslations.translate(
                                  'delete_confirmation',
                                  locale,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text(
                                    AppTranslations.translate('cancel', locale),
                                  ),
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
                            final success = await viewModel.deleteMealMenuEntry(
                              time: meal.time ?? "",
                            );
                            if (context.mounted) {
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppTranslations.translate(
                                        'delete_success',
                                        locale,
                                      ),
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else if (viewModel.errorMessage != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(viewModel.errorMessage!),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                      ),
                  ],
                ),
                SizedBox(height: SizeTokens.p8),
                Text(
                  meal.menu ?? "",
                  style: TextStyle(fontSize: SizeTokens.f16),
                ),
                SizedBox(height: SizeTokens.p8),
                Text(
                  "${AppTranslations.translate('time', locale)}: ${meal.time}",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: SizeTokens.f14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGallery(CalendarViewModel viewModel, String locale) {
    final gallery = viewModel.data?.gallery;
    if (gallery == null || gallery.isEmpty) {
      return Center(
        child: Text(AppTranslations.translate('no_gallery_found', locale)),
      );
    }

    final user = context.read<LoginViewModel>().data?.data;
    final isAuthorized = user?.role == 'superadmin' || user?.role == 'teacher';

    return GridView.builder(
      padding: EdgeInsets.all(SizeTokens.p16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: SizeTokens.p12,
        mainAxisSpacing: SizeTokens.p12,
        childAspectRatio: 1.0,
      ),
      itemCount: gallery.length,
      itemBuilder: (context, index) {
        final item = gallery[index];
        return Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(SizeTokens.r12),
                child: Image.network(
                  item.image ?? "",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            ),
            if (isAuthorized)
              Positioned(
                top: 5,
                right: 5,
                child: GestureDetector(
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          AppTranslations.translate('delete', locale),
                        ),
                        content: Text(
                          AppTranslations.translate(
                            'delete_confirmation',
                            locale,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(
                              AppTranslations.translate('cancel', locale),
                            ),
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
                      final success = await viewModel.deleteGalleryImage(
                        item.id ?? 0,
                      );
                      if (context.mounted) {
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppTranslations.translate(
                                  'delete_success',
                                  locale,
                                ),
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else if (viewModel.errorMessage != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(viewModel.errorMessage!),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_forever,
                      color: Colors.white,
                      size: SizeTokens.i20,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
