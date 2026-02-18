import 'package:flutter/material.dart';
import 'package:gym_kid_smart/core/responsive/size_tokens.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime selectedDate;
  final CalendarFormat format;
  final Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;
  final Function(CalendarFormat format) onFormatChanged;
  final String locale;

  const CalendarWidget({
    super.key,
    required this.selectedDate,
    required this.format,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return TableCalendar(
      firstDay: DateTime.utc(2020, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      focusedDay: selectedDate,
      calendarFormat: format,
      locale: locale,
      headerStyle: HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
        formatButtonShowsNext: false,
        formatButtonDecoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(SizeTokens.r8),
        ),
        formatButtonTextStyle: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: SizeTokens.f12,
        ),
        titleTextStyle: TextStyle(
          fontSize: SizeTokens.f16,
          fontWeight: FontWeight.bold,
        ),
        leftChevronIcon: Icon(Icons.chevron_left, color: primaryColor),
        rightChevronIcon: Icon(Icons.chevron_right, color: primaryColor),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.w600,
          fontSize: SizeTokens.f12,
        ),
        weekendStyle: TextStyle(
          color: primaryColor.withOpacity(0.7),
          fontWeight: FontWeight.w600,
          fontSize: SizeTokens.f12,
        ),
      ),
      calendarStyle: CalendarStyle(
        selectedDecoration: BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: primaryColor.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        todayTextStyle: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
        ),
        defaultTextStyle: TextStyle(fontSize: SizeTokens.f14),
        weekendTextStyle: TextStyle(
          fontSize: SizeTokens.f14,
          color: Colors.red[300],
        ),
        outsideDaysVisible: false,
      ),
      selectedDayPredicate: (day) => isSameDay(selectedDate, day),
      onDaySelected: onDaySelected,
      onFormatChanged: onFormatChanged,
    );
  }
}
