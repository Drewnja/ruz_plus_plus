import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:ruz_timetable/services/api_service.dart';
import 'package:ruz_timetable/models/api_models.dart';
import 'package:ruz_timetable/services/settings_service.dart';
import 'package:ruz_timetable/widgets/skeleton_widgets.dart';

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  FilterOptions? _filterOptions;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFilterOptions();
  }

  Future<void> _resetAllFilters() async {
    developer.log('🔄 Resetting all filters to select all items');
    
    if (_filterOptions != null) {
      // Create new filter settings with all items selected
      final allPersonIds = _filterOptions!.eblans.map((e) => e.id.toString()).toSet();
      final allLocationIds = _filterOptions!.locations.map((e) => e.id.toString()).toSet();
      final allDisciplineIds = _filterOptions!.disciplines.map((e) => e.id.toString()).toSet();
      
      final newSettings = FilterSettings(
        selectedPersonIds: allPersonIds,
        selectedLocationIds: allLocationIds,
        selectedDisciplineIds: allDisciplineIds,
      );
      
      await SettingsService.setFilterSettings(newSettings);
      developer.log('✅ All filters reset: ${allPersonIds.length} persons, ${allLocationIds.length} locations, ${allDisciplineIds.length} disciplines');
      
      // Trigger a rebuild of the entire screen to refresh all tabs
      setState(() {});
    }
  }

  Future<void> _loadFilterOptions() async {
    try {
      developer.log('🎯 Loading filter options from API');
      
      // Get selected entity (group or lecturer)
      final selectedEntity = await SettingsService.getSelectedEntity();
      
      // Use 2 weeks from now as per API requirements
      final now = DateTime.now();
      final twoWeeksFromNow = now.add(const Duration(days: 14));
      developer.log('🎯 Date range for filter options: ${now.toIso8601String()} to ${twoWeeksFromNow.toIso8601String()}');
      
      final groupId = selectedEntity?.type == 1 ? int.tryParse(selectedEntity!.id) : null;
      final eblanId = selectedEntity?.type == 2 ? int.tryParse(selectedEntity!.id) : null;
      developer.log('🎯 Filter options request - Group ID: $groupId, Eblan ID: $eblanId');
      
      final options = await ApiService.getFilterOptions(
        dateFrom: ApiService.formatDateForApi(now),
        dateTo: ApiService.formatDateForApi(twoWeeksFromNow),
        group: groupId,
        eblan: eblanId,
      );
      
      developer.log('✅ Filter options loaded: ${options.disciplines.length} disciplines, ${options.locations.length} locations, ${options.eblans.length} eblans');
      
      if (mounted) {
        setState(() {
          _filterOptions = options;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      developer.log('❌ Failed to load filter options: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load filter options: ${e.toString()}';
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                  width: 0.5,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: const <Tab>[
                Tab(text: 'Persons'),
                Tab(text: 'Locations'),
                Tab(text: 'Disciplines'),
              ],
            ),
          ),
          Expanded(
            child: SkeletonWidgets.filterOptionListSkeleton(),
          ),
        ],
      );
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
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _loadFilterOptions();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                  width: 0.5,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: const <Tab>[
                Tab(text: 'Persons'),
                Tab(text: 'Locations'),
                Tab(text: 'Disciplines'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                _PersonsFilterTab(
                  lecturers: _filterOptions?.eblans ?? [],
                  onResetAll: () => _resetAllFilters(),
                ),
                _LocationsFilterTab(
                  locations: _filterOptions?.locations ?? [],
                  onResetAll: () => _resetAllFilters(),
                ),
                _DisciplinesFilterTab(
                  disciplines: _filterOptions?.disciplines ?? [],
                  onResetAll: () => _resetAllFilters(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _resetAllFilters,
        icon: const Icon(Icons.refresh),
        label: const Text('Reset All'),
        tooltip: 'Select all items in all categories',
      ),
    );
  }
}

class _PersonsFilterTab extends StatefulWidget {
  const _PersonsFilterTab({
    required this.lecturers,
    required this.onResetAll,
  });

  final List<Lecturer> lecturers;
  final VoidCallback onResetAll;

  @override
  State<_PersonsFilterTab> createState() => _PersonsFilterTabState();
}

class _PersonsFilterTabState extends State<_PersonsFilterTab> {
  late final Set<String> _selectedPersons;

  @override
  void initState() {
    super.initState();
    // Select all persons by default
    _selectedPersons = widget.lecturers.map((lecturer) => lecturer.id.toString()).toSet();
    _loadSavedSelections();
  }

  @override
  void didUpdateWidget(_PersonsFilterTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload selections when the widget is updated (e.g., after reset all)
    _loadSavedSelections();
  }

  Future<void> _loadSavedSelections() async {
    developer.log('🎯 Loading saved person filter selections');
    final filterSettings = await SettingsService.getFilterSettings();
    if (filterSettings.selectedPersonIds.isNotEmpty) {
      developer.log('🎯 Restoring ${filterSettings.selectedPersonIds.length} saved person selections: ${filterSettings.selectedPersonIds}');
      setState(() {
        _selectedPersons.clear();
        _selectedPersons.addAll(filterSettings.selectedPersonIds);
      });
    } else {
      developer.log('🎯 No saved person selections found, keeping all selected by default');
    }
  }

  Future<void> _saveSelections() async {
    developer.log('🎯 Saving person filter selections: ${_selectedPersons.length} persons selected');
    final currentSettings = await SettingsService.getFilterSettings();
    final newSettings = FilterSettings(
      selectedPersonIds: _selectedPersons,
      selectedLocationIds: currentSettings.selectedLocationIds,
      selectedDisciplineIds: currentSettings.selectedDisciplineIds,
    );
    await SettingsService.setFilterSettings(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              Text(
                'Selected: ${_selectedPersons.length}/${widget.lecturers.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              if (_selectedPersons.length < widget.lecturers.length)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedPersons.clear();
                      _selectedPersons.addAll(
                        widget.lecturers.map((lecturer) => lecturer.id.toString()),
                      );
                    });
                    _saveSelections();
                  },
                  child: const Text('Select All'),
                ),
            ],
          ),
        ),
        Expanded(
          child: widget.lecturers.isEmpty
              ? Center(
                  child: Text(
                    'No lecturers available',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    final Lecturer lecturer = widget.lecturers[index];
                    final String lecturerId = lecturer.id.toString();
                    final bool isSelected = _selectedPersons.contains(lecturerId);
                    
                    return CheckboxListTile(
                      title: Text(lecturer.name),
                      subtitle: Text(lecturer.short),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedPersons.add(lecturerId);
                          } else {
                            _selectedPersons.remove(lecturerId);
                          }
                        });
                        _saveSelections();
                      },
                    );
                  },
                  itemCount: widget.lecturers.length,
                ),
        ),
      ],
    );
  }
}

class _LocationsFilterTab extends StatefulWidget {
  const _LocationsFilterTab({
    required this.locations,
    required this.onResetAll,
  });

  final List<Location> locations;
  final VoidCallback onResetAll;

  @override
  State<_LocationsFilterTab> createState() => _LocationsFilterTabState();
}

class _LocationsFilterTabState extends State<_LocationsFilterTab> {
  late final Set<String> _selectedLocations;

  @override
  void initState() {
    super.initState();
    // Select all locations by default
    _selectedLocations = widget.locations.map((location) => location.id.toString()).toSet();
    _loadSavedSelections();
  }

  @override
  void didUpdateWidget(_LocationsFilterTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload selections when the widget is updated (e.g., after reset all)
    _loadSavedSelections();
  }

  Future<void> _loadSavedSelections() async {
    developer.log('🎯 Loading saved location filter selections');
    final filterSettings = await SettingsService.getFilterSettings();
    if (filterSettings.selectedLocationIds.isNotEmpty) {
      developer.log('🎯 Restoring ${filterSettings.selectedLocationIds.length} saved location selections: ${filterSettings.selectedLocationIds}');
      setState(() {
        _selectedLocations.clear();
        _selectedLocations.addAll(filterSettings.selectedLocationIds);
      });
    } else {
      developer.log('🎯 No saved location selections found, keeping all selected by default');
    }
  }

  Future<void> _saveSelections() async {
    developer.log('🎯 Saving location filter selections: ${_selectedLocations.length} locations selected');
    final currentSettings = await SettingsService.getFilterSettings();
    final newSettings = FilterSettings(
      selectedPersonIds: currentSettings.selectedPersonIds,
      selectedLocationIds: _selectedLocations,
      selectedDisciplineIds: currentSettings.selectedDisciplineIds,
    );
    await SettingsService.setFilterSettings(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              Text(
                'Selected: ${_selectedLocations.length}/${widget.locations.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              if (_selectedLocations.length < widget.locations.length)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedLocations.clear();
                      _selectedLocations.addAll(
                        widget.locations.map((location) => location.id.toString()),
                      );
                    });
                    _saveSelections();
                  },
                  child: const Text('Select All'),
                ),
            ],
          ),
        ),
        Expanded(
          child: widget.locations.isEmpty
              ? Center(
                  child: Text(
                    'No locations available',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    final Location location = widget.locations[index];
                    final String locationId = location.id.toString();
                    final bool isSelected = _selectedLocations.contains(locationId);
                    
                    return CheckboxListTile(
                      title: Text(location.name),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedLocations.add(locationId);
                          } else {
                            _selectedLocations.remove(locationId);
                          }
                        });
                        _saveSelections();
                      },
                    );
                  },
                  itemCount: widget.locations.length,
                ),
        ),
      ],
    );
  }
}

class _DisciplinesFilterTab extends StatefulWidget {
  const _DisciplinesFilterTab({
    required this.disciplines,
    required this.onResetAll,
  });

  final List<Discipline> disciplines;
  final VoidCallback onResetAll;

  @override
  State<_DisciplinesFilterTab> createState() => _DisciplinesFilterTabState();
}

class _DisciplinesFilterTabState extends State<_DisciplinesFilterTab> {
  late final Set<String> _selectedDisciplines;

  @override
  void initState() {
    super.initState();
    // Select all disciplines by default
    _selectedDisciplines = widget.disciplines.map((discipline) => discipline.id.toString()).toSet();
    _loadSavedSelections();
  }

  @override
  void didUpdateWidget(_DisciplinesFilterTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload selections when the widget is updated (e.g., after reset all)
    _loadSavedSelections();
  }

  Future<void> _loadSavedSelections() async {
    developer.log('🎯 Loading saved discipline filter selections');
    final filterSettings = await SettingsService.getFilterSettings();
    if (filterSettings.selectedDisciplineIds.isNotEmpty) {
      developer.log('🎯 Restoring ${filterSettings.selectedDisciplineIds.length} saved discipline selections: ${filterSettings.selectedDisciplineIds}');
      setState(() {
        _selectedDisciplines.clear();
        _selectedDisciplines.addAll(filterSettings.selectedDisciplineIds);
      });
    } else {
      developer.log('🎯 No saved discipline selections found, keeping all selected by default');
    }
  }

  Future<void> _saveSelections() async {
    developer.log('🎯 Saving discipline filter selections: ${_selectedDisciplines.length} disciplines selected');
    final currentSettings = await SettingsService.getFilterSettings();
    final newSettings = FilterSettings(
      selectedPersonIds: currentSettings.selectedPersonIds,
      selectedLocationIds: currentSettings.selectedLocationIds,
      selectedDisciplineIds: _selectedDisciplines,
    );
    await SettingsService.setFilterSettings(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              Text(
                'Selected: ${_selectedDisciplines.length}/${widget.disciplines.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              if (_selectedDisciplines.length < widget.disciplines.length)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedDisciplines.clear();
                      _selectedDisciplines.addAll(
                        widget.disciplines.map((discipline) => discipline.id.toString()),
                      );
                    });
                    _saveSelections();
                  },
                  child: const Text('Select All'),
                ),
            ],
          ),
        ),
        Expanded(
          child: widget.disciplines.isEmpty
              ? Center(
                  child: Text(
                    'No disciplines available',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    final Discipline discipline = widget.disciplines[index];
                    final String disciplineId = discipline.id.toString();
                    final bool isSelected = _selectedDisciplines.contains(disciplineId);
                    
                    return CheckboxListTile(
                      title: Text(discipline.name),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedDisciplines.add(disciplineId);
                          } else {
                            _selectedDisciplines.remove(disciplineId);
                          }
                        });
                        _saveSelections();
                      },
                    );
                  },
                  itemCount: widget.disciplines.length,
                ),
        ),
      ],
    );
  }
}

