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
      // Handle error appropriately
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
    setState(() {
      _answered = true;
      _feedbackText =
          "Time's up! The correct answer is ${_questions[_currentQuestionIndex].correctAnswer}.";
    });
  }

  void _submitAnswer(String selectedAnswer) {
    _timer.cancel();
    setState(() {
      _answered = true;
      _selectedAnswer = selectedAnswer;

      final correctAnswer = _questions[_currentQuestionIndex].correctAnswer;
      if (selectedAnswer == correctAnswer) {
        _score++;
        _feedbackText = "Correct! The answer is $correctAnswer.";
      } else {
        _feedbackText = "Incorrect. The correct answer is $correctAnswer.";
      }
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
      _timer.cancel();
    }
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentQuestionIndex >= _questions.length) {
      return Scaffold(
        body: Center(
          child:
              Text('Quiz Finished! Your Score: $_score/${_questions.length}'),
        ),
      );
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
