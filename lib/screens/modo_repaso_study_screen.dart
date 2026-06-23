import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../models/question.dart';
import '../data/questions.dart';
import 'modo_aleatorio_screen.dart';

class ModoRepasoStudyScreen extends StatelessWidget {
  final int start;
  final int end;

  const ModoRepasoStudyScreen({
    Key? key,
    required this.start,
    required this.end,
  }) : super(key: key);

  void _handleStartQuiz(BuildContext context, List<Question> selectedQuestions) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ModoAleatorioScreen(
          presetQuestions: selectedQuestions,
          isSequential: true,
          title: 'Quiz por Temario',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedQuestions = QUESTIONS.sublist(start - 1, end);

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
                  Text(
                    'Repaso ($start-$end)',
                    style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 120.0),
                itemCount: selectedQuestions.length,
                itemBuilder: (context, index) {
                  final question = selectedQuestions[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: AppColors.outlineVariant, width: 1.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PREGUNTA ${start + index}',
                          style: AppTypography.labelSm.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          question.enunciado,
                          style: AppTypography.bodyMd.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: AppColors.success, width: 1.0),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Ionicons.checkmark_circle, size: 20.0, color: AppColors.success),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: Text(
                                  question.respuestaCorrecta,
                                  style: AppTypography.bodySm.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.success,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
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
          onPressed: () => _handleStartQuiz(context, selectedQuestions),
          icon: const Icon(Ionicons.play, color: AppColors.white, size: 20.0),
          label: const Text('¡Empezar Quiz!', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
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
}
