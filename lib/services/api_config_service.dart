import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfigService {
  static const String _apiEndpointKey = 'custom_api_endpoint';
  static const String _defaultEndpoint = 'https://ruzapi.yashalava.sh/api';

  // Get the current API endpoint
  static Future<String> getApiEndpoint() async {
    developer.log('🔧 Loading API endpoint from local storage');
    final prefs = await SharedPreferences.getInstance();
    final endpoint = prefs.getString(_apiEndpointKey) ?? _defaultEndpoint;
    developer.log('🔧 Current API endpoint: $endpoint');
    return endpoint;
  }

  // Set a custom API endpoint
  static Future<void> setApiEndpoint(String endpoint) async {
    developer.log('🔧 Saving custom API endpoint: $endpoint');
    final prefs = await SharedPreferences.getInstance();
    
    // Clean up the endpoint URL
    String cleanEndpoint = endpoint.trim();
    if (cleanEndpoint.endsWith('/')) {
      cleanEndpoint = cleanEndpoint.substring(0, cleanEndpoint.length - 1);
    }
    if (!cleanEndpoint.endsWith('/api')) {
      cleanEndpoint = '$cleanEndpoint/api';
    }
    
    await prefs.setString(_apiEndpointKey, cleanEndpoint);
    developer.log('✅ API endpoint saved: $cleanEndpoint');
  }

  // Reset to default endpoint
  static Future<void> resetToDefault() async {
    developer.log('🔧 Resetting API endpoint to default');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_apiEndpointKey);
    developer.log('✅ API endpoint reset to default: $_defaultEndpoint');
  }

  // Check if using custom endpoint
  static Future<bool> isUsingCustomEndpoint() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_apiEndpointKey);
  }

  // Get the default endpoint
  static String getDefaultEndpoint() {
    return _defaultEndpoint;
  }
}
