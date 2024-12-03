import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class ApiService {
  static String _decodeHtml(String input) {
    return input
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&#039;', "'")
        .replaceAll('&rdquo;', '"')
        .replaceAll('&ldquo;', '"')
        .replaceAll('&shy;', '')
        .replaceAll('&hellip;', '...');
  }

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
      List<Question> questions = (data['results'] as List).map((questionData) {
        questionData['question'] = _decodeHtml(questionData['question']);
        questionData['correct_answer'] = _decodeHtml(questionData['correct_answer']);
        questionData['incorrect_answers'] = (questionData['incorrect_answers'] as List)
            .map((answer) => _decodeHtml(answer.toString()))
            .toList();
        
        return Question.fromJson(questionData);
      }).toList();
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
