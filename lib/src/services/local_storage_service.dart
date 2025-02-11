import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/news_category.dart';

class LocalStorageService {
  static const String _categoriesKey = 'news_categories';

  static Future<void> saveCategories(List<NewsCategory> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = categories.map((category) => category.toJson()).toList();
    await prefs.setString(_categoriesKey, jsonEncode(categoriesJson));
  }

  static Future<List<NewsCategory>> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = prefs.getString(_categoriesKey);
    if (categoriesJson != null) {
      final List<dynamic> decodedJson = jsonDecode(categoriesJson);
      return decodedJson.map((json) => NewsCategory.fromJson(json)).toList();
    }
    return [];
  }
}