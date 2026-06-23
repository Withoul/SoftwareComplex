import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../models/question.dart';
import '../data/questions.dart';
import '../services/storage_service.dart';
import 'modo_aleatorio_screen.dart';

class ModoRefuerzoScreen extends StatefulWidget {
  const ModoRefuerzoScreen({Key? key}) : super(key: key);

  @override
  State<ModoRefuerzoScreen> createState() => _ModoRefuerzoScreenState();
}

class _ModoRefuerzoScreenState extends State<ModoRefuerzoScreen> {
  final StorageService _storageService = StorageService();

  bool _showOnlyCorrect = false;
  List<Question> _reinforceQuestions = [];
  Map<int, List<bool>> _historyMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final history = await _storageService.getQuestionHistory();
      final filtered = QUESTIONS.where((q) {
        final attempts = history[q.id];
        if (attempts == null || attempts.isEmpty) return false;

        final correctCount = attempts.where((x) => x == true).length;
        final accuracy = correctCount / attempts.length;

        return accuracy < 1.0;
      }).toList();

      if (mounted) {
        setState(() {
          _historyMap = history;
          _reinforceQuestions = filtered;
        });
      }
    } catch (_) {} finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleStartQuiz() {
    if (_reinforceQuestions.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ModoAleatorioScreen(
          presetQuestions: _reinforceQuestions,
          isSequential: false,
          title: 'Quiz de Refuerzo',
        ),
      ),
    ).then((_) => _loadQuestions());
  }

  Color _getBarColor(double accuracy) {
    if (accuracy >= 80) {
      return AppColors.success;
    } else if (accuracy >= 50) {
      return AppColors.secondary;
    } else {
      return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Ionicons.arrow_back, color: AppColors.textPrimary),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainerHigh,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Modo Refuerzo',
                          style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          '${_reinforceQuestions.length} preguntas por reforzar',
                          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (_reinforceQuestions.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.surfaceContainerHigh, width: 1.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mostrar solo respuestas correctas',
                      style: AppTypography.bodySm.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Switch(
                      value: _showOnlyCorrect,
                      onChanged: (val) {
                        setState(() {
                          _showOnlyCorrect = val;
                        });
                      },
                      activeColor: AppColors.success,
                      activeTrackColor: AppColors.successLight,
                      inactiveThumbColor: AppColors.outline,
                      inactiveTrackColor: AppColors.surfaceDim,
                    ),
                  ],
                ),
              ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (_reinforceQuestions.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 120.0),
                          itemCount: _reinforceQuestions.length,
                          itemBuilder: (context, index) {
                            final question = _reinforceQuestions[index];
                            final attempts = _historyMap[question.id] ?? [];
                            final correctCount = attempts.where((x) => x == true).length;
                            final accuracy = attempts.isNotEmpty
                                ? (correctCount / attempts.length) * 100
                                : 0.0;

                            final barColor = _getBarColor(accuracy);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16.0),
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(color: AppColors.outlineVariant, width: 1.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.04),
                                    blurRadius: 4.0,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'REFUERZO ${index + 1}',
                                        style: AppTypography.labelSm.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      if (attempts.isNotEmpty)
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${accuracy.toStringAsFixed(0)}% Éxito',
                                              style: AppTypography.labelSm.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: barColor,
                                              ),
                                            ),
                                            const SizedBox(height: 4.0),
                                            Container(
                                              width: 100.0,
                                              height: 6.0,
                                              decoration: BoxDecoration(
                                                color: AppColors.surfaceContainerHigh,
                                                borderRadius: BorderRadius.circular(3.0),
                                              ),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Container(
                                                  width: 100.0 * (accuracy / 100),
                                                  height: 6.0,
                                                  decoration: BoxDecoration(
                                                    color: barColor,
                                                    borderRadius: BorderRadius.circular(3.0),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12.0),
                                  Text(
                                    question.enunciado,
                                    style: AppTypography.bodyMd.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 16.0),
                                  Column(
                                    children: question.opciones.map((option) {
                                      final isCorrect = option == question.respuestaCorrecta;
                                      if (_showOnlyCorrect && !isCorrect) return const SizedBox.shrink();

                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 8.0),
                                        padding: const EdgeInsets.all(12.0),
                                        decoration: BoxDecoration(
                                          color: isCorrect ? AppColors.successLight : AppColors.surfaceContainerLow,
                                          borderRadius: BorderRadius.circular(8.0),
                                          border: isCorrect
                                              ? Border.all(color: AppColors.success, width: 1.0)
                                              : null,
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              isCorrect ? Ionicons.checkmark_circle : Ionicons.ellipse_outline,
                                              size: 20.0,
                                              color: isCorrect ? AppColors.success : AppColors.outlineVariant,
                                            ),
                                            const SizedBox(width: 8.0),
                                            Expanded(
                                              child: Text(
                                                option,
                                                style: AppTypography.bodySm.copyWith(
                                                  fontWeight: isCorrect ? FontWeight.w600 : FontWeight.w400,
                                                  color: isCorrect ? AppColors.success : AppColors.textSecondary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            );
                          },
                        )),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _reinforceQuestions.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: const Border(
                  top: BorderSide(color: AppColors.surfaceContainerHigh, width: 1.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.08),
                    blurRadius: 12.0,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _handleStartQuiz,
                icon: const Icon(Ionicons.play, color: AppColors.white, size: 20.0),
                label: const Text('¡Iniciar Simulacro de Refuerzo!', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 54.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 0.0,
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120.0,
            height: 120.0,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.successLight,
            ),
            child: const Icon(Ionicons.checkmark_done_circle, size: 80.0, color: AppColors.success),
          ),
          const SizedBox(height: 24.0),
          Text(
            '¡Todo al 100%!',
            style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12.0),
          Text(
            'No tienes preguntas con errores pendientes. ¡Excelente trabajo y sigue así!',
            textAlign: TextAlign.center,
            style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }
}
