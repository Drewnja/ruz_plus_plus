import 'package:flutter/material.dart';
import 'package:ruz_timetable/widgets/timetable_day_list.dart';
import 'package:ruz_timetable/widgets/week_day_selector.dart';
import 'package:ruz_timetable/widgets/calendar_modal.dart';
import 'package:ruz_timetable/services/settings_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key, required this.selectedEntityName, this.selectedEntity, this.onNavigateToSettings});

  final String selectedEntityName;
  final SelectedEntity? selectedEntity;
  final VoidCallback? onNavigateToSettings;

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  late DateTime _weekStart; // Monday as start
  int _selectedDayIndex = 0; // 0..6
  final GlobalKey<WeekDaySelectorState> _weekSelectorKey = GlobalKey<WeekDaySelectorState>();

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    final int weekday = now.weekday; // 1=Mon ... 7=Sun
    _weekStart = now.subtract(Duration(days: weekday - 1));
    _selectedDayIndex = now.difference(_weekStart).inDays.clamp(0, 6);
  }

  DateTime _dayAt(int index) => _weekStart.add(Duration(days: index));

  void _onWeekChanged(DateTime newWeekStart) {
    setState(() {
      _weekStart = newWeekStart;
      // Keep selected day index within the new week
      _selectedDayIndex = _selectedDayIndex.clamp(0, 6);
    });
  }

  void _returnToToday() {
    final DateTime now = DateTime.now();
    final int weekday = now.weekday; // 1=Mon ... 7=Sun
    final DateTime todayWeekStart = now.subtract(Duration(days: weekday - 1));
    final int todayIndex = now.difference(todayWeekStart).inDays.clamp(0, 6);

    // First update the state to today
    setState(() {
      _weekStart = todayWeekStart;
      _selectedDayIndex = todayIndex;
    });

    // Reset the week selector to today's week (force rebuild)
    _weekSelectorKey.currentState?.resetToWeek(todayWeekStart);
  }


  @override
  Widget build(BuildContext context) {
    final DateTime selectedDay = _dayAt(_selectedDayIndex);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedEntityName),
        leading: IconButton(
          icon: const Icon(Icons.history),
          onPressed: _returnToToday,
          tooltip: l10n.returnToToday,
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              showCalendarModal(
                context,
                _dayAt(_selectedDayIndex),
                (DateTime selectedDate) {
                  final int weekday = selectedDate.weekday;
                  final DateTime weekStart = selectedDate.subtract(Duration(days: weekday - 1));
                  final int dayIndex = selectedDate.difference(weekStart).inDays.clamp(0, 6);

                  setState(() {
                    _weekStart = weekStart;
                    _selectedDayIndex = dayIndex;
                  });
                },
              );
            },
            tooltip: l10n.calendarView,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          WeekDaySelector(
            key: _weekSelectorKey,
            weekStart: _weekStart,
            selectedIndex: _selectedDayIndex,
            onSelected: (int idx) => setState(() => _selectedDayIndex = idx),
            onWeekChanged: _onWeekChanged,
          ),
          const Divider(height: 1),
          Expanded(
            child: TimetableDayList(
              day: selectedDay,
              selectedEntity: widget.selectedEntity,
              onNavigateToSettings: widget.onNavigateToSettings,
            ),
          ),
        ],
      ),
    );
  }
}


