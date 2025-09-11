import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ruz_timetable/models/api_models.dart';

class CacheService {
  static const String _lessonsCachePrefix = 'lessons_cache_';
  static const Duration _cacheExpiry = Duration(minutes: 30); // Cache expires after 30 minutes

  // Generate cache key for lessons based on date, selected entity, and filters
  static String _generateLessonsCacheKey(DateTime day, {
    String? selectedEntityId,
    int? selectedEntityType,
    List<int>? disciplineIds,
    List<int>? locationIds,
    List<int>? eblanIds,
  }) {
    final dateKey = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    final entityKey = '${selectedEntityType ?? 'none'}_${selectedEntityId ?? 'none'}';
    final filtersKey = '${disciplineIds?.join(',') ?? 'all'}_${locationIds?.join(',') ?? 'all'}_${eblanIds?.join(',') ?? 'all'}';
    return '$_lessonsCachePrefix${dateKey}_${entityKey}_$filtersKey';
  }

  // Cache lessons for a specific day and filters
  static Future<void> cacheLessons(
    DateTime day,
    List<Lesson> lessons, {
    String? selectedEntityId,
    int? selectedEntityType,
    List<int>? disciplineIds,
    List<int>? locationIds,
    List<int>? eblanIds,
  }) async {
    try {
      developer.log('💾 Caching ${lessons.length} lessons for day: ${day.day}/${day.month}/${day.year} (entity: ${selectedEntityType}_$selectedEntityId)');
      
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _generateLessonsCacheKey(day, 
        selectedEntityId: selectedEntityId,
        selectedEntityType: selectedEntityType,
        disciplineIds: disciplineIds, 
        locationIds: locationIds, 
        eblanIds: eblanIds
      );
      
      final cacheData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'lessons': lessons.map((lesson) => lesson.toJson()).toList(),
      };
      
      await prefs.setString(cacheKey, jsonEncode(cacheData));
      developer.log('✅ Lessons cached successfully with key: $cacheKey');
    } catch (e) {
      developer.log('❌ Failed to cache lessons: $e');
    }
  }

  // Get cached lessons for a specific day and filters
  static Future<CachedLessons?> getCachedLessons(
    DateTime day, {
    String? selectedEntityId,
    int? selectedEntityType,
    List<int>? disciplineIds,
    List<int>? locationIds,
    List<int>? eblanIds,
  }) async {
    try {
      developer.log('🔍 Looking for cached lessons for day: ${day.day}/${day.month}/${day.year} (entity: ${selectedEntityType}_$selectedEntityId)');
      
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _generateLessonsCacheKey(day, 
        selectedEntityId: selectedEntityId,
        selectedEntityType: selectedEntityType,
        disciplineIds: disciplineIds, 
        locationIds: locationIds, 
        eblanIds: eblanIds
      );
      
      final cachedJson = prefs.getString(cacheKey);
      if (cachedJson == null) {
        developer.log('📭 No cached lessons found for key: $cacheKey');
        return null;
      }

      final cacheData = jsonDecode(cachedJson) as Map<String, dynamic>;
      final timestamp = DateTime.fromMillisecondsSinceEpoch(cacheData['timestamp'] as int);
      final isExpired = DateTime.now().difference(timestamp) > _cacheExpiry;
      
      if (isExpired) {
        developer.log('⏰ Cached lessons expired (${DateTime.now().difference(timestamp).inMinutes} minutes old), removing from cache');
        await prefs.remove(cacheKey);
        return null;
      }

      final lessonsJson = cacheData['lessons'] as List<dynamic>;
      final lessons = lessonsJson
          .map((json) => Lesson.fromJson(json as Map<String, dynamic>))
          .toList();
      
      developer.log('✅ Found ${lessons.length} cached lessons (${DateTime.now().difference(timestamp).inMinutes} minutes old)');
      
      return CachedLessons(
        lessons: lessons,
        cachedAt: timestamp,
        isExpired: false,
      );
    } catch (e) {
      developer.log('❌ Failed to get cached lessons: $e');
      return null;
    }
  }

  // Clear all lesson caches (useful when filters change globally)
  static Future<void> clearAllLessonCaches() async {
    try {
      developer.log('🧹 Clearing all lesson caches');
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final lessonCacheKeys = keys.where((key) => key.startsWith(_lessonsCachePrefix));
      
      for (final key in lessonCacheKeys) {
        await prefs.remove(key);
      }
      
      developer.log('✅ Cleared ${lessonCacheKeys.length} lesson cache entries');
    } catch (e) {
      developer.log('❌ Failed to clear lesson caches: $e');
    }
  }

  // Clear expired caches (maintenance function)
  static Future<void> clearExpiredCaches() async {
    try {
      developer.log('🧹 Cleaning up expired caches');
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final lessonCacheKeys = keys.where((key) => key.startsWith(_lessonsCachePrefix));
      
      int removedCount = 0;
      for (final key in lessonCacheKeys) {
        final cachedJson = prefs.getString(key);
        if (cachedJson != null) {
          try {
            final cacheData = jsonDecode(cachedJson) as Map<String, dynamic>;
            final timestamp = DateTime.fromMillisecondsSinceEpoch(cacheData['timestamp'] as int);
            final isExpired = DateTime.now().difference(timestamp) > _cacheExpiry;
            
            if (isExpired) {
              await prefs.remove(key);
              removedCount++;
            }
          } catch (e) {
            // If we can't parse the cache entry, remove it
            await prefs.remove(key);
            removedCount++;
          }
        }
      }
      
      developer.log('✅ Removed $removedCount expired cache entries');
    } catch (e) {
      developer.log('❌ Failed to clear expired caches: $e');
    }
  }
}

class CachedLessons {
  final List<Lesson> lessons;
  final DateTime cachedAt;
  final bool isExpired;

  CachedLessons({
    required this.lessons,
    required this.cachedAt,
    required this.isExpired,
  });

  Duration get age => DateTime.now().difference(cachedAt);
  bool get isStale => age > const Duration(minutes: 5); // Consider stale after 5 minutes
}
