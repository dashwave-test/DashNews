import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class NetworkService {
  static const String _baseUrl = 'https://api.example.com'; // Replace with your API base URL
  static const String _googleNewsBaseUrl = 'https://google-news13.p.rapidapi.com';
  static bool _useMockGoogleNewsApi = false;

  static void setUseMockGoogleNewsApi(bool useMock) {
    _useMockGoogleNewsApi = useMock;
  }

  static Future<Map<String, String>> _getHeaders() async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    // Add authentication token if user is logged in
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? token = await user.getIdToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  static Map<String, String> _getGoogleNewsHeaders() {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'x-rapidapi-ua': 'RapidAPI-Playground',
      'x-rapidapi-key': const String.fromEnvironment('RAPID_API_KEY'),
      'x-rapidapi-host': 'google-news13.p.rapidapi.com',
    };
  }

  static Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> post(String endpoint, dynamic body) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: await _getHeaders(),
      body: json.encode(body),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> put(String endpoint, dynamic body) async {
    final response = await http.put(
      Uri.parse('$_baseUrl$endpoint'),
      headers: await _getHeaders(),
      body: json.encode(body),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl$endpoint'),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> getNews({
    String categoryId = 'latest',
    String languageCode = 'en-US',
    String countryCode = 'US',
  }) async {
    print("News category ID: $categoryId"); // Added semicolon here
    if (_useMockGoogleNewsApi || categoryId == 'entertainment') {
      return _getMockNews(categoryId);
    }

    final queryParameters = {
      'lr': languageCode,
      'country': countryCode,
      'category': categoryId,
    };

    final uri = Uri.parse('$_googleNewsBaseUrl/latest').replace(
      queryParameters: queryParameters,
    );

    final response = await http.get(
      uri,
      headers: _getGoogleNewsHeaders(),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> _getMockNews(String categoryId) async {
    String jsonString = await rootBundle.loadString('assets/mock/${categoryId}_news_response.json');
    return json.decode(jsonString);
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception('HTTP Error: ${response.statusCode}, ${response.body}');
    }
  }
}