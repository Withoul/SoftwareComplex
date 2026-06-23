import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../models/question.dart';
import '../data/questions.dart';
import '../components/question_card.dart';
import '../utils/helpers.dart';
import '../services/storage_service.dart';
import 'results_screen.dart';

class RachaInfinitaScreen extends StatefulWidget {
  const RachaInfinitaScreen({Key? key}) : super(key: key);

  @override
  State<RachaInfinitaScreen> createState() => _RachaInfinitaScreenState();
}

class _RachaInfinitaScreenState extends State<RachaInfinitaScreen> {
  final StorageService _storageService = StorageService();

  List<Question> _questions = [];
  int _currentIndex = 0;
  int _streak = 0;
  bool _gameOver = false;
  String _lastCorrectAnswer = '';
  PreparedQuestion? _prepared;
  final List<Map<String, dynamic>> _quizQuestions = [];

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    final shuffled = shuffleArray(QUESTIONS);
    setState(() {
      _questions = shuffled;
      _currentIndex = 0;
      _streak = 0;
      _gameOver = false;
      _lastCorrectAnswer = '';
      _quizQuestions.clear();
      _prepared = prepareQuestion(shuffled[0]);
    });
  }

  Future<void> _handleAnswer(bool isCorrect, String correctText) async {
    final currentQuestion = _questions[_currentIndex];
    await _storageService.recordQuestionAnswer(currentQuestion.id, isCorrect);

    _quizQuestions.add({
      'enunciado': currentQuestion.enunciado,
      'correctAnswer': currentQuestion.respuestaCorrecta,
      'isCorrect': isCorrect,
    });

    if (isCorrect) {
      final newStreak = _streak + 1;
      setState(() {
        _streak = newStreak;
      });

      await _storageService.addPoints(10);
      await _storageService.markStudyDay();
      await _storageService.updateStreak();

      final nextIndex = _currentIndex + 1;
      if (nextIndex < _questions.length) {
        setState(() {
          _currentIndex = nextIndex;
          _prepared = prepareQuestion(_questions[nextIndex]);
        });
      } else {
        await _storageService.addToStats(newStreak, newStreak);
        
        await _storageService.recordQuizAttempt(
          'Racha Infinita',
          newStreak,
          newStreak,
          _quizQuestions,
        );

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => ResultsScreen(
                mode: 'Racha Infinita',
                total: newStreak,
                correct: newStreak,
                errors: const [],
              ),
            ),
          );
        }
      }
    } else {
      setState(() {
        _lastCorrectAnswer = correctText;
        _gameOver = true;
      });

      await _storageService.addToStats(_streak + 1, _streak);
      await _storageService.markStudyDay();
      await _storageService.updateStreak();

      await _storageService.recordQuizAttempt(
        'Racha Infinita',
        _streak,
        _streak + 1,
        _quizQuestions,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_gameOver) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 100.0,
                    height: 100.0,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondaryOverlay,
                    ),
                    child: const Icon(Ionicons.flame, size: 64.0, color: AppColors.secondary),
                  ),
                ),
                const SizedBox(height: 24.0),
                Text(
                  '¡Racha terminada!',
                  textAlign: TextAlign.center,
                  style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8.0),
                Text(
                  _streak.toString(),
                  textAlign: TextAlign.center,
                  style: AppTypography.headlineLg.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontSize: 64.0,
                  ),
                ),
                Text(
                  'preguntas correctas consecutivas',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32.0),

                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Ionicons.close_circle, color: AppColors.error, size: 20.0),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: AppTypography.bodySm.copyWith(color: AppColors.textPrimary, height: 1.4),
                            children: [
                              const TextSpan(text: 'La respuesta correcta era:\n'),
                              TextSpan(
                                text: _lastCorrectAnswer,
                                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.success),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32.0),

                ElevatedButton.icon(
                  onPressed: _startNewGame,
                  icon: const Icon(Ionicons.refresh, color: AppColors.white, size: 20.0),
                  label: const Text('Intentar de nuevo', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 54.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 0.0,
                  ),
                ),
                const SizedBox(height: 12.0),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Volver al menú',
                    style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_prepared == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0.0,
        leadingWidth: 70.0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 8.0, bottom: 8.0),
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Ionicons.close, color: AppColors.textPrimary),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceContainerHigh,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
            ),
          ),
        ),
        title: Text(
          'Racha Infinita',
          style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0, top: 10.0, bottom: 10.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: AppColors.secondaryOverlay,
                borderRadius: BorderRadius.circular(99.0),
              ),
              child: Row(
                children: [
                  const Icon(Ionicons.flame, size: 16.0, color: AppColors.secondary),
                  const SizedBox(width: 4.0),
                  Text(
                    _streak.toString(),
                    style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 16.0, bottom: 40.0),
          child: QuestionCard(
            question: _prepared!.question,
            shuffledOptions: _prepared!.shuffledOptions,
            correctIndex: _prepared!.correctIndex,
            onAnswer: _handleAnswer,
            streakText: '🔥 Racha: $_streak',
          ),
        ),
      ),
    );
  }
}
