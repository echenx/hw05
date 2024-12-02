import 'dart:async';
import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/api_service.dart';

class QuizScreen extends StatefulWidget {
  final int numQuestions;
  final String category;
  final String difficulty;
  final String type;

  QuizScreen({
    required this.numQuestions,
    required this.category,
    required this.difficulty,
    required this.type,
  });

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _loading = true;
  bool _answered = false;
  String _selectedAnswer = "";
  String _feedbackText = "";
  late Timer _timer;
  int _timeLeft = 15;
  List<Map<String, String>> _answerSummary = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await ApiService.fetchQuestions(
        numQuestions: widget.numQuestions,
        category: widget.category,
        difficulty: widget.difficulty,
        type: widget.type,
      );
      setState(() {
        _questions = questions;
        _loading = false;
      });
      _startTimer();
    } catch (e) {
      print(e);
      setState(() {
        _loading = false;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _timer.cancel();
        _markTimeout();
      }
    });
  }

  void _markTimeout() {
    final question = _questions[_currentQuestionIndex];
    setState(() {
      _answered = true;
      _feedbackText =
          "Time's up! The correct answer is ${question.correctAnswer}.";
      _answerSummary.add({
        "question": question.question,
        "yourAnswer": "No answer",
        "correctAnswer": question.correctAnswer,
      });
    });
  }

  void _submitAnswer(String selectedAnswer) {
    _timer.cancel();
    final question = _questions[_currentQuestionIndex];
    setState(() {
      _answered = true;
      _selectedAnswer = selectedAnswer;

      if (selectedAnswer == question.correctAnswer) {
        _score++;
        _feedbackText = "Correct! The answer is ${question.correctAnswer}.";
      } else {
        _feedbackText =
            "Incorrect. The correct answer is ${question.correctAnswer}.";
      }
      _answerSummary.add({
        "question": question.question,
        "yourAnswer": selectedAnswer,
        "correctAnswer": question.correctAnswer,
      });
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _answered = false;
        _selectedAnswer = "";
        _feedbackText = "";
        _currentQuestionIndex++;
        _timeLeft = 15;
      });
      _startTimer();
    } else {
      setState(() {
        _currentQuestionIndex++;
        _timer.cancel();
      });
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _answered = false;
      _feedbackText = "";
      _selectedAnswer = "";
      _answerSummary.clear();
      _timeLeft = 15;
      _loading = true;
    });
    _loadQuestions();
  }

  void _goBackToSettings() {
    Navigator.pop(context);
  }

  Widget _buildOptionButton(String option) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: _answered ? null : () => _submitAnswer(option),
        child: Text(option),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
      ),
    );
  }

  Widget _buildSummaryScreen() {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz Summary')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Your Score: $_score/${_questions.length}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _answerSummary.length,
                itemBuilder: (context, index) {
                  final summary = _answerSummary[index];
                  return Card(
                    child: ListTile(
                      title: Text(summary["question"]!),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Your Answer: ${summary["yourAnswer"]}"),
                          Text("Correct Answer: ${summary["correctAnswer"]}"),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _restartQuiz,
              child: Text('Retake Quiz'),
            ),
            ElevatedButton(
              onPressed: _goBackToSettings,
              child: Text('Adjust Settings'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        body: Center(child: Text('No questions available.')),
      );
    }

    if (_currentQuestionIndex >= _questions.length) {
      return _buildSummaryScreen();
    }

    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: Text('Quiz App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentQuestionIndex + 1}/${_questions.length}',
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  'Score: $_score/${_questions.length}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Time Left: $_timeLeft seconds',
              style: TextStyle(
                fontSize: 16,
                color: _timeLeft <= 5 ? Colors.red : Colors.black,
              ),
            ),
            SizedBox(height: 16),
            Text(
              question.question,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            ...question.options.map((option) => _buildOptionButton(option)),
            SizedBox(height: 20),
            if (_answered)
              Text(
                _feedbackText,
                style: TextStyle(
                  fontSize: 16,
                  color: _selectedAnswer == question.correctAnswer
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            if (_answered)
              ElevatedButton(
                onPressed: _nextQuestion,
                child: Text('Next Question'),
              ),
          ],
        ),
      ),
    );
  }
}
