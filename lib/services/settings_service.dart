import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ruz_timetable/services/cache_service.dart';

class SettingsService {
  static const String _themeKey = 'theme_mode';
  static const String _selectedEntityKey = 'selected_entity';
  static const String _selectedFiltersKey = 'selected_filters';
  
  // Theme settings
  static Future<ThemeMode> getThemeMode() async {
    developer.log('💾 Loading theme mode from local storage');
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? ThemeMode.system.index;
    final themeMode = ThemeMode.values[themeIndex];
    developer.log('💾 Loaded theme mode: $themeMode (index: $themeIndex)');
    return themeMode;
  }
  
  static Future<void> setThemeMode(ThemeMode themeMode) async {
    developer.log('💾 Saving theme mode to local storage: $themeMode (index: ${themeMode.index})');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, themeMode.index);
    developer.log('✅ Theme mode saved successfully');
  }
  
  // Selected entity (group/person/lecturer)
  static Future<SelectedEntity?> getSelectedEntity() async {
    developer.log('💾 Loading selected entity from local storage');
    final prefs = await SharedPreferences.getInstance();
    final entityJson = prefs.getString(_selectedEntityKey);
    if (entityJson == null) {
      developer.log('💾 No selected entity found in local storage');
      return null;
    }
    
    try {
      final Map<String, dynamic> entityMap = jsonDecode(entityJson);
      final entity = SelectedEntity.fromJson(entityMap);
      developer.log('💾 Loaded selected entity: ${entity.name} (type: ${entity.type}, id: ${entity.id})');
      return entity;
    } catch (e) {
      developer.log('❌ Failed to parse selected entity from local storage: $e');
      return null;
    }
  }
  
  static Future<void> setSelectedEntity(SelectedEntity entity) async {
    developer.log('💾 Saving selected entity to local storage: ${entity.name} (type: ${entity.type}, id: ${entity.id})');
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(entity.toJson());
    await prefs.setString(_selectedEntityKey, jsonString);
    developer.log('✅ Selected entity saved successfully: $jsonString');
    
    // Clear lesson cache when entity changes since lessons will be different
    developer.log('🧹 Clearing lesson cache due to entity change');
    await CacheService.clearAllLessonCaches();
  }
  
  static Future<void> clearSelectedEntity() async {
    developer.log('💾 Clearing selected entity from local storage');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_selectedEntityKey);
    developer.log('✅ Selected entity cleared successfully');
    
    // Clear lesson cache when entity is cleared
    developer.log('🧹 Clearing lesson cache due to entity clearing');
    await CacheService.clearAllLessonCaches();
  }
  
  // Filter settings - now group-specific
  static Future<FilterSettings> getFilterSettings({String? groupId}) async {
    developer.log('💾 Loading filter settings from local storage for group: ${groupId ?? 'global'}');
    final prefs = await SharedPreferences.getInstance();
    final filterKey = groupId != null ? 'filters_$groupId' : _selectedFiltersKey;
    final filtersJson = prefs.getString(filterKey);
    if (filtersJson == null) {
      developer.log('💾 No filter settings found for group ${groupId ?? 'global'}, returning empty filters');
      return FilterSettings.empty();
    }
    
    try {
      final Map<String, dynamic> filtersMap = jsonDecode(filtersJson);
      final filters = FilterSettings.fromJson(filtersMap);
      developer.log('💾 Loaded filter settings for group ${groupId ?? 'global'}: ${filters.selectedPersonIds.length} persons, ${filters.selectedLocationIds.length} locations, ${filters.selectedDisciplineIds.length} disciplines');
      developer.log('💾 Filter details - Persons: ${filters.selectedPersonIds}, Locations: ${filters.selectedLocationIds}, Disciplines: ${filters.selectedDisciplineIds}');
      return filters;
    } catch (e) {
      developer.log('❌ Failed to parse filter settings from local storage for group ${groupId ?? 'global'}: $e');
      return FilterSettings.empty();
    }
  }
  
  static Future<void> setFilterSettings(FilterSettings filters, {String? groupId}) async {
    developer.log('💾 Saving filter settings to local storage for group: ${groupId ?? 'global'} - ${filters.selectedPersonIds.length} persons, ${filters.selectedLocationIds.length} locations, ${filters.selectedDisciplineIds.length} disciplines');
    developer.log('💾 Filter details - Persons: ${filters.selectedPersonIds}, Locations: ${filters.selectedLocationIds}, Disciplines: ${filters.selectedDisciplineIds}');
    final prefs = await SharedPreferences.getInstance();
    final filterKey = groupId != null ? 'filters_$groupId' : _selectedFiltersKey;
    final jsonString = jsonEncode(filters.toJson());
    await prefs.setString(filterKey, jsonString);
    developer.log('✅ Filter settings saved successfully for group ${groupId ?? 'global'}: $jsonString');
  }
}

class SelectedEntity {
  final int type; // 1 = group, 2 = lecturer
  final String id;
  final String name;
  final String description;
  
  SelectedEntity({
    required this.type,
    required this.id,
    required this.name,
    required this.description,
  });
  
  factory SelectedEntity.fromJson(Map<String, dynamic> json) {
    return SelectedEntity(
      type: json['type'] ?? 0,
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'id': id,
      'name': name,
      'description': description,
    };
  }
}

class FilterSettings {
  final Set<String> selectedPersonIds;
  final Set<String> selectedLocationIds;
  final Set<String> selectedDisciplineIds;
  
  FilterSettings({
    required this.selectedPersonIds,
    required this.selectedLocationIds,
    required this.selectedDisciplineIds,
  });
  
  factory FilterSettings.empty() {
    return FilterSettings(
      selectedPersonIds: {},
      selectedLocationIds: {},
      selectedDisciplineIds: {},
    );
  }
  
  factory FilterSettings.fromJson(Map<String, dynamic> json) {
    return FilterSettings(
      selectedPersonIds: Set<String>.from(json['personIds'] ?? []),
      selectedLocationIds: Set<String>.from(json['locationIds'] ?? []),
      selectedDisciplineIds: Set<String>.from(json['disciplineIds'] ?? []),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'personIds': selectedPersonIds.toList(),
      'locationIds': selectedLocationIds.toList(),
      'disciplineIds': selectedDisciplineIds.toList(),
    };
  }
  
  // Helper methods
  List<int> get personIdsAsInts => selectedPersonIds.map((id) => int.tryParse(id) ?? 0).where((id) => id != 0).toList();
  List<int> get locationIdsAsInts => selectedLocationIds.map((id) => int.tryParse(id) ?? 0).where((id) => id != 0).toList();
  List<int> get disciplineIdsAsInts => selectedDisciplineIds.map((id) => int.tryParse(id) ?? 0).where((id) => id != 0).toList();
  
  bool get hasAnyFilters => selectedPersonIds.isNotEmpty || selectedLocationIds.isNotEmpty || selectedDisciplineIds.isNotEmpty;
}
