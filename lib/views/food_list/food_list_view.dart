import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/responsive/size_tokens.dart';
import '../../core/ui_components/common_widgets.dart';
import '../../core/utils/app_translations.dart';
import '../../models/user_model.dart';
import '../../viewmodels/food_list_view_model.dart';
import '../../viewmodels/landing_view_model.dart';

class FoodListView extends StatelessWidget {
  final UserModel user;

  const FoodListView({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          FoodListViewModel()..init(user.schoolId ?? 1, user.userKey ?? ''),
      child: _FoodListViewContent(user: user),
    );
  }
}

class _FoodListViewContent extends StatelessWidget {
  final UserModel user;

  const _FoodListViewContent({required this.user});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FoodListViewModel>();
    final locale = context.watch<LandingViewModel>().locale.languageCode;

    // Convert current selected date to string for comparison in calendar builder
    // Or just use the selectedDayPredicate which is standard in TableCalendar

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: BaseAppBar(
        title: Text(
          AppTranslations.translate('food_list', locale),
          style: TextStyle(
            color: Colors.black,
            fontSize: SizeTokens.f16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [],
      ),
      body: Column(
        children: [
          _buildCalendar(context, viewModel, locale),
          Expanded(child: _buildMealList(context, viewModel, locale)),
        ],
      ),
    );
  }

  Widget _buildCalendar(
    BuildContext context,
    FoodListViewModel viewModel,
    String locale,
  ) {
    return Container(
      margin: EdgeInsets.all(SizeTokens.p16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeTokens.r24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TableCalendar(
        locale: locale,
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: viewModel.selectedDate,
        currentDay: DateTime.now(),
        selectedDayPredicate: (day) {
          return isSameDay(viewModel.selectedDate, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          viewModel.onDaySelected(selectedDay, focusedDay);
        },
        calendarFormat: CalendarFormat.month,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: false,
          titleTextStyle: TextStyle(
            fontSize: SizeTokens.f16,
            fontWeight: FontWeight.bold,
            color: Colors
                .black, // Should confirm with theme, but image shows dark text
          ),
          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
        ),
        calendarStyle: CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: Color(0xFFEFA500), // Orange color from screenshot
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          defaultTextStyle: TextStyle(
            fontSize: SizeTokens.f14,
            fontWeight: FontWeight.w500,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekendStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: SizeTokens.f12,
          ),
          weekdayStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: SizeTokens.f12,
          ),
        ),
      ),
    );
  }

  Widget _buildMealList(
    BuildContext context,
    FoodListViewModel viewModel,
    String locale,
  ) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final meals = viewModel.getMealsForSelectedDate();

    if (meals.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: SizeTokens.p32),
          child: Text(
            AppTranslations.translate('no_food_list_found', locale),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: SizeTokens.f24,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: Colors.black,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(SizeTokens.p16),
      itemCount: meals.length,
      separatorBuilder: (context, index) => SizedBox(height: SizeTokens.p16),
      itemBuilder: (context, index) {
        final menu = meals[index];
        return Container(
          padding: EdgeInsets.all(SizeTokens.p16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(SizeTokens.r16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      menu.title ?? '',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                        fontSize: SizeTokens.f16,
                      ),
                    ),
                  ),
                  if (menu.time != null && menu.time!.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeTokens.p8,
                        vertical: SizeTokens.p4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(SizeTokens.r8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: SizeTokens.i12,
                            color: Colors.grey[700],
                          ),
                          SizedBox(width: SizeTokens.p4),
                          Text(
                            menu.time!,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: SizeTokens.f12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              SizedBox(height: SizeTokens.p12),
              Text(
                menu.menu ?? '',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  fontSize: SizeTokens.f14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
