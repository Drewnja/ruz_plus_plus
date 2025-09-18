import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:ruz_timetable/models/api_models.dart';
import 'package:ruz_timetable/services/api_config_service.dart';

class ApiService {
  // Get the current API endpoint
  static Future<String> get baseUrl async {
    return await ApiConfigService.getApiEndpoint();
  }
  
  // Search for groups and lecturers
  static Future<List<SearchResult>> search({
    required String searchString,
    int? type, // 1 = group, 2 = lecturer, null = all
  }) async {
    final endpoint = await baseUrl;
    final url = '$endpoint/search';
    final requestBody = {
      'searchString': searchString,
      if (type != null) 'type': type,
    };
    
    developer.log('🔍 API Request: POST $url');
    developer.log('📤 Request body: ${jsonEncode(requestBody)}');
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 15));

      developer.log('📥 Response status: ${response.statusCode}');
      developer.log('📥 Response headers: ${response.headers}');
      developer.log('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['result'] as List<dynamic>? ?? [];
        developer.log('✅ Search successful: ${results.length} results');
        return results
            .map((e) => SearchResult.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        developer.log('❌ Search failed with status: ${response.statusCode}');
        developer.log('❌ Error response: ${response.body}');
        throw Exception('Failed to search: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      developer.log('💥 Search exception: $e');
      developer.log('💥 Search exception type: ${e.runtimeType}');
      throw Exception('Search error: $e');
    }
  }

  // Get filter options
  static Future<FilterOptions> getFilterOptions({
    required String dateFrom,
    required String dateTo,
    int? group,
    int? eblan,
  }) async {
    final endpoint = await baseUrl;
    final url = '$endpoint/getFilterOptions';
    final requestBody = {
      'dateFrom': dateFrom,
      'dateTo': dateTo,
      if (group != null) 'group': group,
      if (eblan != null) 'eblan': eblan,
    };
    
    developer.log('🎯 API Request: POST $url');
    developer.log('📤 Request body: ${jsonEncode(requestBody)}');
    developer.log('🎯 Filter options parameters - Group: $group, Eblan: $eblan');
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      developer.log('📥 Response status: ${response.statusCode}');
      developer.log('📥 Response headers: ${response.headers}');
      developer.log('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        developer.log('✅ Filter options successful');
        return FilterOptions.fromJson(data);
      } else {
        developer.log('❌ Filter options failed with status: ${response.statusCode}');
        developer.log('❌ Error response: ${response.body}');
        throw Exception('Failed to get filter options: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      developer.log('💥 Filter options exception: $e');
      throw Exception('Filter options error: $e');
    }
  }

  // Get RUZ timetable data
  static Future<List<Lesson>> getRUZ({
    required String dateFrom,
    required String dateTo,
    List<int>? disciplineIds,
    List<int>? locationIds,
    List<int>? eblanIds,
    int? groupId,
  }) async {
    final endpoint = await baseUrl;
    final url = '$endpoint/getRUZ';
    final requestBody = {
      'dateFrom': dateFrom,
      'dateTo': dateTo,
      'filters': {
        if (disciplineIds != null) 'disciplineIds': disciplineIds,
        if (locationIds != null) 'locationIds': locationIds,
        if (eblanIds != null) 'eblanIds': eblanIds,
        if (groupId != null) 'groupId': groupId,
      },
    };
    
    developer.log('📅 API Request: POST $url');
    developer.log('🎯 Filters applied - Disciplines: $disciplineIds, Locations: $locationIds, Eblans: $eblanIds, GroupId: $groupId');
    developer.log('📤 Request body: ${jsonEncode(requestBody)}');
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      developer.log('📥 Response status: ${response.statusCode}');
      developer.log('📥 Response headers: ${response.headers}');
      developer.log('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final lessons = data['lessons'] as List<dynamic>? ?? [];
        developer.log('✅ RUZ data successful: ${lessons.length} lessons');
        return lessons
            .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        developer.log('❌ RUZ data failed with status: ${response.statusCode}');
        developer.log('❌ Error response: ${response.body}');
        throw Exception('Failed to get RUZ data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      developer.log('💥 RUZ data exception: $e');
      throw Exception('RUZ data error: $e');
    }
  }

  // Test connectivity to the API server
  static Future<bool> testConnection() async {
    final endpoint = await baseUrl;
    final url = '$endpoint/search';
    
    developer.log('🔗 Testing connection to: $url');
    
    try {
      // Try a simple POST request like the real API calls
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'searchString': 'test'}),
      ).timeout(const Duration(seconds: 10));

      developer.log('🔗 Connection test response: ${response.statusCode}');
      developer.log('🔗 Connection test headers: ${response.headers}');
      developer.log('🔗 Connection test body: ${response.body}');
      
      return response.statusCode < 500; // Accept any response that's not a server error
    } catch (e) {
      developer.log('💥 Connection test failed: $e');
      return false;
    }
  }

  // Helper method to format DateTime to API format
  static String formatDateForApi(DateTime date) {
    return date.toUtc().toIso8601String();
  }

}
