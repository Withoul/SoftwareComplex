import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../data/questions.dart';
import '../services/storage_service.dart';

class TemarioTabScreen extends StatefulWidget {
  const TemarioTabScreen({Key? key}) : super(key: key);

  @override
  State<TemarioTabScreen> createState() => _TemarioTabScreenState();
}

class _TemarioTabScreenState extends State<TemarioTabScreen> {
  final StorageService _storageService = StorageService();

  bool _showOnlyCorrect = false;
  Map<int, List<bool>> _historyMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });
    final history = await _storageService.getQuestionHistory();
    if (mounted) {
      setState(() {
        _historyMap = history;
        _isLoading = false;
      });
    }
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
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 30.0, 24.0, 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Temario de Estudio',
                    style: AppTypography.headlineMd.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    '${QUESTIONS.length} preguntas disponibles',
                    style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            // Toggle Switch row
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

            // Content list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 100.0),
                      itemCount: QUESTIONS.length,
                      itemBuilder: (context, index) {
                        final question = QUESTIONS[index];
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
                                    'PREGUNTA ${index + 1}',
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
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
