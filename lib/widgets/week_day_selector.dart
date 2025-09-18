import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WeekDaySelector extends StatefulWidget {
  const WeekDaySelector({
    super.key,
    required this.weekStart,
    required this.selectedIndex,
    required this.onSelected,
    required this.onWeekChanged,
  });

  final DateTime weekStart;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final ValueChanged<DateTime> onWeekChanged;

  @override
  State<WeekDaySelector> createState() => WeekDaySelectorState();
}

class WeekDaySelectorState extends State<WeekDaySelector> {
  late PageController _pageController;
  late DateTime _baseWeekStart; // This stays constant as our reference point
  
  static const int _initialPage = 1000; // Start in middle to allow infinite scroll
  
  @override
  void initState() {
    super.initState();
    _baseWeekStart = widget.weekStart;
    _pageController = PageController(initialPage: _initialPage);
  }

  void scrollToWeek(DateTime weekStart) {
    final int weekOffset = weekStart.difference(_baseWeekStart).inDays ~/ 7;
    final int targetPage = _initialPage + weekOffset;
    
    _pageController.animateToPage(
      targetPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void resetToWeek(DateTime weekStart) {
    setState(() {
      _baseWeekStart = weekStart;
    });
    
    _pageController.jumpToPage(_initialPage);
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  DateTime _getWeekStartForPage(int page) {
    final int weekOffset = page - _initialPage;
    return _baseWeekStart.add(Duration(days: weekOffset * 7));
  }
  
  String _weekdayLabel(DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final List<String> shortWeekdays = <String>[
      l10n.monday,
      l10n.tuesday,
      l10n.wednesday,
      l10n.thursday,
      l10n.friday,
      l10n.saturday,
      l10n.sunday,
    ];
    return shortWeekdays[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextStyle dayStyle = Theme.of(context).textTheme.labelLarge!;
    final TextStyle dateStyle = Theme.of(context).textTheme.bodySmall!;
    
    return SizedBox(
      height: 80,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (int page) {
          final DateTime newWeekStart = _getWeekStartForPage(page);
          // Only notify parent when page change is complete
          widget.onWeekChanged(newWeekStart);
        },
        itemBuilder: (BuildContext context, int page) {
          final DateTime weekStart = _getWeekStartForPage(page);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: List.generate(7, (int dayIndex) {
                final DateTime date = weekStart.add(Duration(days: dayIndex));
                // Check if this specific date matches the selected date from parent
                final DateTime selectedDate = widget.weekStart.add(Duration(days: widget.selectedIndex));
                final bool isSelected = _isSameDay(date, selectedDate);
                final bool isToday = _isSameDay(date, DateTime.now());

                final Color bg = isSelected
                    ? cs.primaryContainer
                    : (isToday ? cs.secondaryContainer : cs.surfaceContainerLow);
                final Color fg = isSelected
                    ? cs.onPrimaryContainer
                    : (isToday ? cs.onSecondaryContainer : cs.onSurfaceVariant);

                return Expanded(
                  child: Container(
                    height: 64,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: cs.primary.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ] : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          // Calculate which day index this would be if we switched to this week
                          final int daysDifference = date.difference(weekStart).inDays;
                          
                          // Notify parent of week change first (if needed)
                          if (!_isSameWeek(weekStart, widget.weekStart)) {
                            widget.onWeekChanged(weekStart);
                          }
                          
                          // Then notify of day selection
                          widget.onSelected(daysDifference);
                        },
                        child: Container(
                          height: 64,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                _weekdayLabel(date),
                                style: dayStyle.copyWith(color: fg),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${date.day}',
                                style: dateStyle.copyWith(
                                  color: fg,
                                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  bool _isSameWeek(DateTime week1Start, DateTime week2Start) {
    return _isSameDay(week1Start, week2Start);
  }
}