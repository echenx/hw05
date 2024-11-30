import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class ApiService {
  static Future<List<Question>> fetchQuestions({
    required int numQuestions,
    required String category,
    required String difficulty,
    required String type,
  }) async {
    final response = await http.get(
      Uri.parse(
        'https://opentdb.com/api.php?amount=$numQuestions&category=$category&difficulty=$difficulty&type=$type',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Question> questions = (data['results'] as List)
          .map((questionData) => Question.fromJson(questionData))
          .toList();
      return questions;
    } else {
      throw Exception('Failed to load questions');
    }
  }

  static Future<List<dynamic>> fetchCategories() async {
    final response = await http.get(
      Uri.parse('https://opentdb.com/api_category.php'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['trivia_categories'];
    } else {
      throw Exception('Failed to fetch categories');
    }
  }
}
