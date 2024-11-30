import 'package:flutter/material.dart';
import 'quiz_screen.dart';
import '../services/api_service.dart';

class QuizSetupScreen extends StatefulWidget {
  @override
  _QuizSetupScreenState createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  int _selectedQuestions = 10;
  String _selectedCategory = "9";
  String _selectedDifficulty = "easy";
  String _selectedType = "multiple";
  List<dynamic> _categories = [];
  bool _loadingCategories = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await ApiService.fetchCategories();
      setState(() {
        _categories = categories;
        _loadingCategories = false;
      });
    } catch (e) {
      print("Error fetching categories: $e");
      setState(() => _loadingCategories = false);
    }
  }

  void _startQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          numQuestions: _selectedQuestions,
          category: _selectedCategory,
          difficulty: _selectedDifficulty,
          type: _selectedType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz Setup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loadingCategories
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Select Number of Questions:',
                      style: TextStyle(fontSize: 16)),
                  DropdownButton<int>(
                    value: _selectedQuestions,
                    items: [5, 10, 15].map((num) {
                      return DropdownMenuItem(
                          value: num, child: Text(num.toString()));
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedQuestions = value!);
                    },
                  ),
                  SizedBox(height: 16),
                  Text('Select Category:', style: TextStyle(fontSize: 16)),
                  DropdownButton<String>(
                    value: _selectedCategory,
                    items:
                        _categories.map<DropdownMenuItem<String>>((category) {
                      return DropdownMenuItem(
                        value: category['id'].toString(),
                        child: Text(category['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedCategory = value!);
                    },
                  ),
                  SizedBox(height: 16),
                  Text('Select Difficulty:', style: TextStyle(fontSize: 16)),
                  DropdownButton<String>(
                    value: _selectedDifficulty,
                    items: ['easy', 'medium', 'hard'].map((difficulty) {
                      return DropdownMenuItem(
                          value: difficulty, child: Text(difficulty));
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedDifficulty = value!);
                    },
                  ),
                  SizedBox(height: 16),
                  Text('Select Type:', style: TextStyle(fontSize: 16)),
                  DropdownButton<String>(
                    value: _selectedType,
                    items: ['multiple', 'boolean'].map((type) {
                      return DropdownMenuItem(
                          value: type,
                          child: Text(type == 'multiple'
                              ? 'Multiple Choice'
                              : 'True/False'));
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedType = value!);
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _startQuiz,
                    child: Text('Start Quiz'),
                  ),
                ],
              ),
      ),
    );
  }
}
