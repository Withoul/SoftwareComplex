import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../models/question.dart';
import '../data/questions.dart';
import '../components/question_card.dart';
import '../components/progress_bar.dart';
import '../utils/helpers.dart';
import '../services/storage_service.dart';
import 'results_screen.dart';

class ModoAleatorioScreen extends StatefulWidget {
  final List<Question>? presetQuestions;
  final bool? isSequential;
  final String? title;

  const ModoAleatorioScreen({
    Key? key,
    this.presetQuestions,
    this.isSequential,
    this.title,
  }) : super(key: key);

  @override
  State<ModoAleatorioScreen> createState() => _ModoAleatorioScreenState();
}

class _ModoAleatorioScreenState extends State<ModoAleatorioScreen> {
  final StorageService _storageService = StorageService();

  String _phase = 'setup'; // 'setup' | 'quiz'
  int _questionCount = 20;
  final TextEditingController _customCountController = TextEditingController();

  List<Question> _questions = [];
  int _currentIndex = 0;
  int _correctCount = 0;
  List<IncorrectAnswer> _errors = [];
  PreparedQuestion? _prepared;
  final List<Map<String, dynamic>> _quizQuestions = [];

  final List<int> _presetCounts = [10, 20, 30, 50, 100, 400];

  @override
  void initState() {
    super.initState();
    if (widget.presetQuestions != null && widget.presetQuestions!.isNotEmpty) {
      _initPreset();
    } else {
      _phase = 'setup';
    }
  }

  @override
  void dispose() {
    _customCountController.dispose();
    super.dispose();
  }

  Future<void> _initPreset() async {
    final presets = widget.presetQuestions!;
    List<Question> selected;
    if (widget.isSequential == true) {
      selected = List<Question>.from(presets);
    } else {
      final history = await _storageService.getQuestionHistory();
      final seenIds = history.keys.toList();
      selected = selectRandomQuestions(presets, presets.length, seenIds);
    }

    if (mounted) {
      setState(() {
        _questions = selected;
        _currentIndex = 0;
        _correctCount = 0;
        _errors = [];
        _quizQuestions.clear();
        _prepared = prepareQuestion(selected[0]);
        _phase = 'quiz';
      });
    }
  }

  Future<void> _startQuiz() async {
    int count = _questionCount;
    final customText = _customCountController.text.trim();
    if (customText.isNotEmpty) {
      final parsed = int.tryParse(customText);
      if (parsed != null && parsed > 0) {
        count = parsed.clamp(1, QUESTIONS.length);
      }
    }

    final history = await _storageService.getQuestionHistory();
    final seenIds = history.keys.toList();
    final selected = selectRandomQuestions(QUESTIONS, count, seenIds);

    setState(() {
      _questions = selected;
      _currentIndex = 0;
      _correctCount = 0;
      _errors = [];
      _quizQuestions.clear();
      _prepared = prepareQuestion(selected[0]);
      _phase = 'quiz';
    });
  }

  Future<void> _handleAnswer(bool isCorrect, String correctText) async {
    final currentQuestion = _questions[_currentIndex];
    await _storageService.recordQuestionAnswer(currentQuestion.id, isCorrect);

    int finalCorrect = _correctCount;
    if (isCorrect) {
      setState(() {
        _correctCount++;
      });
      finalCorrect++;
      await _storageService.addPoints(5);
    } else {
      setState(() {
        _errors.add(IncorrectAnswer(
          pregunta: currentQuestion.enunciado,
          correcta: correctText,
        ));
      });
    }

    _quizQuestions.add({
      'enunciado': currentQuestion.enunciado,
      'correctAnswer': currentQuestion.respuestaCorrecta,
      'isCorrect': isCorrect,
    });

    final nextIndex = _currentIndex + 1;
    if (nextIndex < _questions.length) {
      setState(() {
        _currentIndex = nextIndex;
        _prepared = prepareQuestion(_questions[nextIndex]);
      });
    } else {
      await _storageService.addToStats(_questions.length, finalCorrect);
      await _storageService.markStudyDay();
      await _storageService.updateStreak();

      // Record in quiz history
      await _storageService.recordQuizAttempt(
        widget.title ?? 'Modo Aleatorio',
        finalCorrect,
        _questions.length,
        _quizQuestions,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ResultsScreen(
              mode: widget.title ?? 'Modo Aleatorio',
              total: _questions.length,
              correct: finalCorrect,
              errors: _errors,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_phase == 'setup') {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 20.0,
                left: 20.0,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Ionicons.arrow_back, color: AppColors.textPrimary),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surfaceContainerHigh,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40.0),
                      Center(
                        child: Container(
                          width: 96.0,
                          height: 96.0,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.secondaryOverlay,
                          ),
                          child: const Icon(Ionicons.dice_outline, size: 48.0, color: AppColors.secondary),
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      Text(
                        'Modo Aleatorio',
                        textAlign: TextAlign.center,
                        style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Selecciona la cantidad de preguntas para tu simulacro',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 32.0),

                      Wrap(
                        spacing: 12.0,
                        runSpacing: 12.0,
                        alignment: WrapAlignment.center,
                        children: _presetCounts.map((count) {
                          final isSelected = _questionCount == count && _customCountController.text.isEmpty;
                          return ChoiceChip(
                            label: Text(count.toString(), style: const TextStyle(fontSize: 18.0)),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() {
                                _questionCount = count;
                                _customCountController.clear();
                              });
                            },
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.white,
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                            side: BorderSide(color: isSelected ? AppColors.primary : AppColors.outlineVariant),
                            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                            showCheckmark: false,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32.0),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              'O ingresa un número personalizado (máx. 400):',
                              style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          TextField(
                            controller: _customCountController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w700),
                            onChanged: (_) {
                              setState(() {});
                            },
                            decoration: InputDecoration(
                              hintText: 'Ej: 15',
                              hintStyle: const TextStyle(color: AppColors.textTertiary),
                              fillColor: AppColors.white,
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: const BorderSide(color: AppColors.outlineVariant, width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32.0),

                      ElevatedButton.icon(
                        onPressed: _startQuiz,
                        icon: const Icon(Ionicons.play, color: AppColors.primaryDark, size: 20.0),
                        label: const Text('Comenzar Simulacro', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          minimumSize: const Size(double.infinity, 54.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 0.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
          widget.title ?? 'Simulacro',
          style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0, top: 18.0),
            child: Text(
              '${_currentIndex + 1}/${_questions.length}',
              style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 8.0, bottom: 40.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ProgressBar(
                  progress: (_currentIndex + 1) / _questions.length,
                  height: 6.0,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 16.0),
              QuestionCard(
                key: ValueKey(_currentIndex),
                question: _prepared!.question,
                shuffledOptions: _prepared!.shuffledOptions,
                correctIndex: _prepared!.correctIndex,
                onAnswer: _handleAnswer,
                progressText: 'Pregunta ${_currentIndex + 1} de ${_questions.length}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
