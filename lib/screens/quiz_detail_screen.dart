import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../components/progress_bar.dart';

class QuizDetailScreen extends StatelessWidget {
  final Map<String, dynamic> attempt;

  const QuizDetailScreen({
    Key? key,
    required this.attempt,
  }) : super(key: key);

  Color _getGradeColor(double pct) {
    if (pct >= 80) return AppColors.success;
    if (pct >= 60) return AppColors.secondary;
    if (pct >= 40) return const Color(0xFFFF9800);
    return AppColors.error;
  }

  String _getGradeEmoji(double pct) {
    if (pct >= 90) return '🏆';
    if (pct >= 80) return '⭐';
    if (pct >= 60) return '👍';
    if (pct >= 40) return '📝';
    return '💪';
  }

  String _getGradeMessage(double pct) {
    if (pct >= 90) return '¡Excelente! Dominas el tema.';
    if (pct >= 80) return '¡Muy bien! Sigue así.';
    if (pct >= 60) return '¡Buen trabajo! Sigue practicando.';
    if (pct >= 40) return 'Puedes mejorar. ¡No te rindas!';
    return 'Necesitas más práctica. ¡Tú puedes!';
  }

  @override
  Widget build(BuildContext context) {
    final mode = attempt['mode'] ?? 'Simulacro';
    final score = attempt['score'] ?? 0;
    final total = attempt['total'] ?? 0;
    final date = attempt['date'] ?? '';
    final List<dynamic> rawQuestions = attempt['questions'] ?? [];
    
    final incorrect = total - score;
    final double percentageVal = total > 0 ? (score / total) * 100 : 0.0;
    final percentage = percentageVal.toStringAsFixed(1);
    final themeColor = _getGradeColor(percentageVal);

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
            icon: const Icon(Ionicons.arrow_back, color: AppColors.textPrimary),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceContainerHigh,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
            ),
          ),
        ),
        title: Text(
          'Detalle de Quiz',
          style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary card
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(color: AppColors.outlineVariant, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.04),
                      blurRadius: 10.0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      _getGradeEmoji(percentageVal),
                      style: const TextStyle(fontSize: 44.0),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      '$percentage%',
                      style: AppTypography.headlineLg.copyWith(
                        fontWeight: FontWeight.w700,
                        color: themeColor,
                        fontSize: 48.0,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      _getGradeMessage(percentageVal),
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySm.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999.0),
                      ),
                      child: Text(
                        mode.toUpperCase(),
                        style: AppTypography.labelSm.copyWith(
                          fontWeight: FontWeight.w700,
                          color: themeColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      date,
                      style: AppTypography.labelSm.copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // Detail Row Grid
              Row(
                children: [
                  _buildMiniStatBox(total.toString(), 'Total', null),
                  const SizedBox(width: 8.0),
                  _buildMiniStatBox(score.toString(), 'Correctas', AppColors.success),
                  const SizedBox(width: 8.0),
                  _buildMiniStatBox(incorrect.toString(), 'Incorrectas', AppColors.error),
                ],
              ),
              const SizedBox(height: 24.0),

              // Accuracy Bar Container
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: AppColors.outlineVariant, width: 1.0),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Precisión de Respuestas',
                          style: AppTypography.bodySm.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '$percentage%',
                          style: AppTypography.bodyMd.copyWith(
                            fontWeight: FontWeight.w700,
                            color: themeColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    ProgressBar(
                      progress: total > 0 ? score / total : 0.0,
                      height: 8.0,
                      color: themeColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32.0),

              // Question breakdowns
              Row(
                children: [
                  const Icon(Ionicons.list_outline, color: AppColors.primary, size: 20.0),
                  const SizedBox(width: 8.0),
                  Text(
                    'Detalle de Preguntas',
                    style: AppTypography.bodyLg.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              if (rawQuestions.isEmpty)
                Text(
                  'No hay preguntas registradas para esta sesión.',
                  style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: rawQuestions.length,
                  itemBuilder: (context, index) {
                    final q = Map<String, dynamic>.from(rawQuestions[index]);
                    final enunciado = q['enunciado'] ?? '';
                    final correctAnswer = q['correctAnswer'] ?? '';
                    final isCorrect = q['isCorrect'] ?? false;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: isCorrect ? AppColors.success.withOpacity(0.3) : AppColors.error.withOpacity(0.3),
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 24.0,
                                height: 24.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isCorrect ? AppColors.successLight : const Color(0x14BA1A1A),
                                ),
                                child: Icon(
                                  isCorrect ? Ionicons.checkmark : Ionicons.close,
                                  size: 14.0,
                                  color: isCorrect ? AppColors.success : AppColors.error,
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                'Pregunta ${index + 1}',
                                style: AppTypography.labelSm.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isCorrect ? AppColors.success : AppColors.error,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12.0),
                          Text(
                            enunciado,
                            style: AppTypography.bodySm.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: isCorrect ? AppColors.successLight : const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                color: isCorrect ? AppColors.success : const Color(0xFFFFB74D),
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Ionicons.checkmark_circle,
                                  size: 16.0,
                                  color: isCorrect ? AppColors.success : const Color(0xFFE65100),
                                ),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: Text(
                                    isCorrect ? 'Correcta: $correctAnswer' : 'Respuesta correcta: $correctAnswer',
                                    style: AppTypography.bodySm.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isCorrect ? AppColors.success : const Color(0xFFE65100),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStatBox(String number, String label, Color? numColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: numColor != null ? numColor.withOpacity(0.3) : AppColors.outlineVariant,
            width: 1.0,
          ),
        ),
        child: Column(
          children: [
            Text(
              number,
              style: AppTypography.headlineSm.copyWith(
                fontWeight: FontWeight.w700,
                color: numColor ?? AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              label,
              style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary, fontSize: 10.0),
            ),
          ],
        ),
      ),
    );
  }
}
