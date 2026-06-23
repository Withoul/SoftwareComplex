import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../components/progress_bar.dart';

class IncorrectAnswer {
  final String pregunta;
  final String correcta;

  IncorrectAnswer({
    required this.pregunta,
    required this.correcta,
  });
}

class ResultsScreen extends StatelessWidget {
  final String mode;
  final int total;
  final int correct;
  final List<IncorrectAnswer> errors;

  const ResultsScreen({
    Key? key,
    required this.mode,
    required this.total,
    required this.correct,
    required this.errors,
  }) : super(key: key);

  Color _getGradeColor() {
    double pct = total > 0 ? (correct / total) * 100 : 0.0;
    if (pct >= 80) return AppColors.success;
    if (pct >= 60) return AppColors.secondary;
    if (pct >= 40) return const Color(0xFFFF9800);
    return AppColors.error;
  }

  String _getGradeEmoji() {
    double pct = total > 0 ? (correct / total) * 100 : 0.0;
    if (pct >= 90) return '🏆';
    if (pct >= 80) return '⭐';
    if (pct >= 60) return '👍';
    if (pct >= 40) return '📝';
    return '💪';
  }

  String _getGradeMessage() {
    double pct = total > 0 ? (correct / total) * 100 : 0.0;
    if (pct >= 90) return '¡Excelente! Dominas el tema.';
    if (pct >= 80) return '¡Muy bien! Sigue así.';
    if (pct >= 60) return '¡Buen trabajo! Sigue practicando.';
    if (pct >= 40) return 'Puedes mejorar. ¡No te rindas!';
    return 'Necesitas más práctica. ¡Tú puedes!';
  }

  @override
  Widget build(BuildContext context) {
    final incorrect = total - correct;
    final double percentageVal = total > 0 ? (correct / total) * 100 : 0.0;
    final percentage = percentageVal.toStringAsFixed(1);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24.0, 40.0, 24.0, 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  Text(
                    _getGradeEmoji(),
                    style: const TextStyle(fontSize: 48.0),
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    '$percentage%',
                    style: AppTypography.headlineLg.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _getGradeColor(),
                      fontSize: 56.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    _getGradeMessage(),
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMd.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOverlay,
                      borderRadius: BorderRadius.circular(999.0),
                    ),
                    child: Text(
                      mode.toUpperCase(),
                      style: AppTypography.labelSm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32.0),

              Row(
                children: [
                  _buildStatBox(total.toString(), 'Total', null),
                  const SizedBox(width: 8.0),
                  _buildStatBox(correct.toString(), 'Correctas', AppColors.success),
                  const SizedBox(width: 8.0),
                  _buildStatBox(incorrect.toString(), 'Incorrectas', AppColors.error),
                ],
              ),
              const SizedBox(height: 24.0),

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
                          'Precisión',
                          style: AppTypography.bodySm.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '$percentage%',
                          style: AppTypography.bodyMd.copyWith(
                            fontWeight: FontWeight.w700,
                            color: _getGradeColor(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    ProgressBar(
                      progress: total > 0 ? correct / total : 0.0,
                      height: 10.0,
                      color: _getGradeColor(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32.0),

              if (errors.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Ionicons.alert_circle, color: AppColors.error, size: 18.0),
                    const SizedBox(width: 8.0),
                    Text(
                      'Detalle de Respuestas Incorrectas',
                      style: AppTypography.bodyMd.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: errors.length,
                  itemBuilder: (context, index) {
                    final err = errors[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: AppColors.errorContainer, width: 1.0),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28.0,
                            height: 28.0,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.errorContainer,
                            ),
                            child: Center(
                              child: Text(
                                (index + 1).toString(),
                                style: AppTypography.labelSm.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  err.pregunta,
                                  style: AppTypography.bodySm.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Ionicons.checkmark_circle,
                                      size: 16.0,
                                      color: AppColors.success,
                                    ),
                                    const SizedBox(width: 6.0),
                                    Expanded(
                                      child: Text(
                                        err.correcta,
                                        style: AppTypography.bodySm.copyWith(
                                          color: AppColors.success,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24.0),
              ],

              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Ionicons.refresh, color: AppColors.white, size: 20.0),
                label: const Text('Nuevo simulacro', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
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
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                icon: const Icon(Ionicons.home_outline, color: AppColors.primary, size: 20.0),
                label: const Text('Volver al inicio', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  minimumSize: const Size(double.infinity, 54.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(String number, String label, Color? numColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: numColor != null ? numColor.withOpacity(0.4) : AppColors.outlineVariant,
            width: 1.0,
          ),
        ),
        child: Column(
          children: [
            Text(
              number,
              style: AppTypography.numberSm.copyWith(
                fontWeight: FontWeight.w700,
                color: numColor ?? AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              label,
              style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary, fontSize: 11.0),
            ),
          ],
        ),
      ),
    );
  }
}
