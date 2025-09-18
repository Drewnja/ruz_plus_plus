import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:ruz_timetable/services/api_service.dart';
import 'package:ruz_timetable/models/api_models.dart';
import 'package:ruz_timetable/services/settings_service.dart';
import 'package:ruz_timetable/services/cache_service.dart';
import 'package:ruz_timetable/widgets/skeleton_widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Function to get themed icons for different disciplines
IconData _getDisciplineIcon(int disciplineId) {
  switch (disciplineId) {
    case 83579830: // Основы военной подготовки
    case 40547703: // Военная подготовка
      return Icons.shield;
    case 75807975: // Банковское дело
      return Icons.assured_workload;
    case 33612229: // Техническая защита информации
      return Icons.security;
    case 58147181: // Информационная безопасность типовых банковских процессов
      return Icons.attach_money;
    case 62062383: // Методы и средства криптографической защиты информации
      return Icons.currency_bitcoin;
    case 94404438: // Основы проектирования банковских автоматизированных систем
      return Icons.account_balance;
    case 47604811: // Имитационное моделирование систем защиты информации
      return Icons.cloud;
    case 2776458: // Иностранный язык в профессиональной сфере
      return Icons.language;
    case 31809723: // Программно-аппаратная защита информации
      return Icons.lock;
    default:
      return Icons.menu_book; // Default book icon for unknown subjects
  }
}

class TimetableDayList extends StatefulWidget {
  const TimetableDayList({super.key, required this.day, this.selectedEntity, this.onNavigateToSettings});

  final DateTime day;
  final SelectedEntity? selectedEntity;
  final VoidCallback? onNavigateToSettings;

  @override
  State<TimetableDayList> createState() => _TimetableDayListState();
}

class _TimetableDayListState extends State<TimetableDayList> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _outgoingSlide;
  late Animation<Offset> _incomingSlide;
  Widget? _previousContent;
  bool _isAnimating = false;
  
  List<Lesson> _lessons = [];
  bool _isLoading = true;
  bool _isLoadingFromCache = false;
  bool _isBackgroundRefresh = false;
  String? _errorMessage;
  CachedLessons? _cachedData;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _setupAnimations(isForward: true);
    _loadLessons();
  }

  void _setupAnimations({required bool isForward}) {
    // Current content slides out
    _outgoingSlide = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(isForward ? -1.0 : 1.0, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // New content slides in
    _incomingSlide = Tween<Offset>(
      begin: Offset(isForward ? 1.0 : -1.0, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
  }

  Future<void> _loadLessons() async {
    try {
      developer.log('📅 Loading lessons for day: ${widget.day.year}-${widget.day.month.toString().padLeft(2, '0')}-${widget.day.day.toString().padLeft(2, '0')}');
      
      // Load selected entity and filter settings from local storage
      final selectedEntity = await SettingsService.getSelectedEntity();
      
      // If no group is selected, show info screen immediately without API calls
      if (selectedEntity == null) {
        developer.log('📭 No group selected, showing info screen without API calls');
        setState(() {
          _lessons = [];
          _isLoading = false;
          _isLoadingFromCache = false;
          _errorMessage = null;
        });
        return;
      }
      
      final filterSettings = await SettingsService.getFilterSettings(
        groupId: selectedEntity.type == 1 ? selectedEntity.id : null,
      );
      
      // Prepare filter IDs for caching and API call
      final disciplineIds = filterSettings.selectedDisciplineIds.isNotEmpty ? filterSettings.disciplineIdsAsInts : null;
      final locationIds = filterSettings.selectedLocationIds.isNotEmpty ? filterSettings.locationIdsAsInts : null;
      
      // For eblanIds, include both filter selections AND the selected person if entity type is 2 (lecturer)
      List<int>? eblanIds;
      if (filterSettings.selectedPersonIds.isNotEmpty) {
        eblanIds = filterSettings.personIdsAsInts;
      }
      
      // If selected entity is a person (type 2), add their ID to eblanIds
      if (selectedEntity.type == 2) {
        final personId = int.tryParse(selectedEntity.id);
        if (personId != null) {
          eblanIds = eblanIds ?? [];
          if (!eblanIds.contains(personId)) {
            eblanIds.add(personId);
          }
        }
      }
      
      developer.log('🎯 Selected entity: ${selectedEntity.name} (type: ${selectedEntity.type}, id: ${selectedEntity.id})');
      developer.log('🎯 Applying filters - Disciplines: $disciplineIds, Locations: $locationIds, Persons: $eblanIds');
      
      // Try to get cached data first
      final cachedLessons = await CacheService.getCachedLessons(
        widget.day,
        selectedEntityId: selectedEntity.id,
        selectedEntityType: selectedEntity.type,
        disciplineIds: disciplineIds,
        locationIds: locationIds,
        eblanIds: eblanIds,
      );
      
      if (cachedLessons != null) {
        developer.log('💾 Using cached lessons (${cachedLessons.lessons.length} lessons)');
        setState(() {
          _lessons = cachedLessons.lessons;
          _cachedData = cachedLessons;
          _isLoading = false;
          _isLoadingFromCache = true;
          _errorMessage = null;
        });
        
        // If cache is stale, refresh in background
        if (cachedLessons.isStale) {
          developer.log('🔄 Cache is stale, refreshing in background');
          _refreshInBackground(selectedEntity.id, selectedEntity.type, disciplineIds, locationIds, eblanIds);
        }
        return;
      }
      
      // No cache available, show skeleton and load from API
      setState(() {
        _isLoading = true;
        _isLoadingFromCache = false;
        _errorMessage = null;
      });

      await _loadFromApi(selectedEntity.id, selectedEntity.type, disciplineIds, locationIds, eblanIds);
    } catch (e) {
      developer.log('❌ Failed to load lessons: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingFromCache = false;
          _errorMessage = 'Failed to load lessons: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _loadFromApi(String? selectedEntityId, int? selectedEntityType, List<int>? disciplineIds, List<int>? locationIds, List<int>? eblanIds) async {
    final startOfDay = DateTime(widget.day.year, widget.day.month, widget.day.day);
    final endOfDay = DateTime(widget.day.year, widget.day.month, widget.day.day, 23, 59, 59);
    developer.log('📅 Date range: ${startOfDay.toIso8601String()} to ${endOfDay.toIso8601String()}');
    
    final lessons = await ApiService.getRUZ(
      dateFrom: ApiService.formatDateForApi(startOfDay),
      dateTo: ApiService.formatDateForApi(endOfDay),
      disciplineIds: disciplineIds,
      locationIds: locationIds,
      eblanIds: eblanIds,
      groupId: selectedEntityType == 1 ? int.tryParse(selectedEntityId ?? '') : null,
    );

    // Filter lessons to the specific day (API might return broader range)
    final dayLessons = lessons.where((lesson) {
      final lessonDate = lesson.startDateTime;
      return lessonDate.year == widget.day.year &&
             lessonDate.month == widget.day.month &&
             lessonDate.day == widget.day.day;
    }).toList();
    
    developer.log('✅ Lessons loaded successfully: ${dayLessons.length} lessons for the day (${lessons.length} total from API)');
    for (final lesson in dayLessons) {
      developer.log('📅 Lesson: ${lesson.disciplineInfo.disciplineName} at ${lesson.startDateTime.hour}:${lesson.startDateTime.minute.toString().padLeft(2, '0')}');
    }

    // Cache the results with selected entity info
    await CacheService.cacheLessons(
      widget.day,
      dayLessons,
      selectedEntityId: selectedEntityId,
      selectedEntityType: selectedEntityType,
      disciplineIds: disciplineIds,
      locationIds: locationIds,
      eblanIds: eblanIds,
    );

    if (mounted) {
      setState(() {
        _lessons = dayLessons;
        _isLoading = false;
        _isLoadingFromCache = false;
        _isBackgroundRefresh = false;
      });
    }
  }

  Future<void> _refreshInBackground(String? selectedEntityId, int? selectedEntityType, List<int>? disciplineIds, List<int>? locationIds, List<int>? eblanIds) async {
    try {
      setState(() {
        _isBackgroundRefresh = true;
      });
      
      await _loadFromApi(selectedEntityId, selectedEntityType, disciplineIds, locationIds, eblanIds);
    } catch (e) {
      developer.log('❌ Background refresh failed: $e');
      setState(() {
        _isBackgroundRefresh = false;
      });
    }
  }

  @override
  void didUpdateWidget(TimetableDayList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.day != widget.day && !_isAnimating) {
      developer.log('📅 Day changed from ${oldWidget.day.day} to ${widget.day.day}, starting animation');
      _isAnimating = true;
      _previousContent = _buildLessonList();
      
      final bool isForward = widget.day.isAfter(oldWidget.day);
      developer.log('🎨 Animation direction: ${isForward ? 'forward' : 'backward'}');
      _setupAnimations(isForward: isForward);
      
      _loadLessons();
      
      _animationController.reset();
      _animationController.forward().then((_) {
        if (mounted) {
          developer.log('✅ Day transition animation completed');
          setState(() {
            _isAnimating = false;
            _previousContent = null;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildLessonList() {
    // Show skeleton loading while loading from API (not from cache)
    if (_isLoading && !_isLoadingFromCache) {
      return SkeletonWidgets.lessonListSkeleton();
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadLessons,
                child: Text(AppLocalizations.of(context)!.retry),
              ),
            ],
          ),
        ),
      );
    }

    // Show different content based on whether a group is selected
    if (widget.selectedEntity == null) {
      final l10n = AppLocalizations.of(context)!;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.group_add,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noGroupSelected,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.noGroupSelectedDescription,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: widget.onNavigateToSettings,
                icon: const Icon(Icons.settings),
                label: Text(l10n.goToSettings),
              ),
            ],
          ),
        ),
      );
    }

    if (_lessons.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.event_busy,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noLessonsForThisDay,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Show cache indicator and background refresh status
        if (_isLoadingFromCache || _isBackgroundRefresh)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                if (_isLoadingFromCache) ...[
                  Icon(
                    Icons.cached,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.cachedData('${_cachedData?.age.inMinutes ?? 0}m'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
                const Spacer(),
                if (_isBackgroundRefresh) ...[
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.refreshing,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (BuildContext context, int index) {
              final Lesson lesson = _lessons[index];
              final String time = '${lesson.startDateTime.hour.toString().padLeft(2, '0')}:${lesson.startDateTime.minute.toString().padLeft(2, '0')} - '
                  '${lesson.endDateTime.hour.toString().padLeft(2, '0')}:${lesson.endDateTime.minute.toString().padLeft(2, '0')}';
              
              return Card(
                elevation: 2,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Discipline name with icon
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _getDisciplineIcon(lesson.disciplineInfo.disciplineId),
                                  size: 20,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  lesson.disciplineInfo.disciplineName,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          
                          // Time
                          Text(
                            time,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          
                          // Lecture/Seminar type
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: lesson.isLecture 
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.yellow.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              lesson.isLecture 
                                  ? AppLocalizations.of(context)!.lecture
                                  : AppLocalizations.of(context)!.seminar,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: lesson.isLecture 
                                    ? Colors.green.shade700
                                    : Colors.yellow.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          
                          // Lecturer
                          Text(
                            lesson.eblanInfo.eblanName.isNotEmpty 
                                ? lesson.eblanInfo.eblanName 
                                : lesson.eblanInfo.eblanNameShort,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 6),
                          
                          // Cabinet
                          if (lesson.locationInfo.cabinet.isNotEmpty)
                            Text(
                              lesson.locationInfo.cabinet,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          if (lesson.locationInfo.cabinet.isNotEmpty)
                            const SizedBox(height: 6),
                          
                          // Address
                          Text(
                            lesson.locationInfo.locationName,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemCount: _lessons.length,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAnimating) {
      return _buildLessonList();
    }

    return Stack(
      children: [
        // Previous content sliding out
        if (_previousContent != null)
          SlideTransition(
            position: _outgoingSlide,
            child: _previousContent!,
          ),
        // New content sliding in
        SlideTransition(
          position: _incomingSlide,
          child: _buildLessonList(),
        ),
      ],
    );
  }
}



