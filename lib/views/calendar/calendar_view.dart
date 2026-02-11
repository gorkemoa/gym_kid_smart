import 'package:flutter/material.dart';
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
  const CalendarView({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalendarViewModel(),
      child: _CalendarViewContent(user: user),
    );
  }
}

class _CalendarViewContent extends StatefulWidget {
  final UserModel? user;
  const _CalendarViewContent({this.user});

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

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: BaseAppBar(
        title: Text(
          AppTranslations.translate('calendar', locale),
          style: TextStyle(
            color: Colors.black,
            fontSize: SizeTokens.f18,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: true,
      ),
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
                    Text(
                      item.lesson?.title ?? "",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: SizeTokens.f18,
                      ),
                    ),
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
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                Text(
                  meal.title ?? "",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: SizeTokens.f18,
                  ),
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
        return ClipRRect(
          borderRadius: BorderRadius.circular(SizeTokens.r12),
          child: Image.network(
            item.image ?? "",
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[200],
              child: Icon(Icons.broken_image, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }
}
