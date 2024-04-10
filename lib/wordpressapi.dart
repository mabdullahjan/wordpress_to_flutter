import 'dart:convert';
import 'package:http/http.dart' as http;

class WordPressAPI {
  static const String baseURL = 'https://yoursite.com/wp-json/wp/v2';

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final response = await http.get(Uri.parse('$baseURL/categories'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<List<Map<String, dynamic>>> getAllPosts() async {
    final response = await http.get(Uri.parse('$baseURL/posts?_embed'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load posts');
    }
  }
}
