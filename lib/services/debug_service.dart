import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

class DebugService {
  static const String baseUrl = 'https://ruzapi.yashalava.sh/api';
  
  // Simple test with minimal configuration
  static Future<String> simpleTest() async {
    final url = '$baseUrl/search';
    
    developer.log('🧪 Simple test to: $url');
    
    try {
      // Most basic POST request possible
      final uri = Uri.parse(url);
      developer.log('🧪 Parsed URI: $uri');
      developer.log('🧪 URI scheme: ${uri.scheme}');
      developer.log('🧪 URI host: ${uri.host}');
      developer.log('🧪 URI port: ${uri.port}');
      
      final client = http.Client();
      final request = http.Request('POST', uri);
      
      request.headers['Content-Type'] = 'application/json';
      request.body = '{"searchString": "test"}';
      
      developer.log('🧪 Request method: ${request.method}');
      developer.log('🧪 Request headers: ${request.headers}');
      developer.log('🧪 Request body: ${request.body}');
      
      final streamedResponse = await client.send(request).timeout(const Duration(seconds: 10));
      final response = await http.Response.fromStream(streamedResponse);
      
      developer.log('🧪 Response status: ${response.statusCode}');
      developer.log('🧪 Response headers: ${response.headers}');
      developer.log('🧪 Response body: ${response.body}');
      
      client.close();
      
      return 'Success: ${response.statusCode}';
      
    } catch (e) {
      developer.log('🧪 Simple test exception: $e');
      developer.log('🧪 Exception type: ${e.runtimeType}');
      return 'Error: $e';
    }
  }
  
  // Test with different HTTP client
  static Future<String> alternativeTest() async {
    final url = '$baseUrl/search';
    
    developer.log('🔬 Alternative test to: $url');
    
    try {
      // Try with explicit client configuration
      final client = http.Client();
      
      final response = await client.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: jsonEncode({'searchString': 'test'}),
      );
      
      developer.log('🔬 Alt response status: ${response.statusCode}');
      developer.log('🔬 Alt response body: ${response.body}');
      
      client.close();
      
      return 'Alt Success: ${response.statusCode}';
      
    } catch (e) {
      developer.log('🔬 Alt test exception: $e');
      return 'Alt Error: $e';
    }
  }
}
