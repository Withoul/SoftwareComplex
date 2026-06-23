import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../models/question.dart';

class QuestionCard extends StatefulWidget {
  final Question question;
  final List<String> shuffledOptions;
  final int correctIndex;
  final Function(bool isCorrect, String correctText) onAnswer;
  final String? progressText;
  final String? streakText;

  const QuestionCard({
    Key? key,
    required this.question,
    required this.shuffledOptions,
    required this.correctIndex,
    required this.onAnswer,
    this.progressText,
    this.streakText,
  }) : super(key: key);

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> with SingleTickerProviderStateMixin {
  int? _selectedIndex;
  bool _showResult = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<String> _optionLetters = ['A', 'B', 'C', 'D'];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _fadeController.forward();
  }

  @override
  void didUpdateWidget(covariant QuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.question.id != oldWidget.question.id) {
      setState(() {
        _selectedIndex = null;
        _showResult = false;
      });
      _fadeController.reset();
      _fadeController.forward();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _handleSelect(int index) {
    if (_showResult) return;
    setState(() {
      _selectedIndex = index;
      _showResult = true;
    });

    final isCorrect = index == widget.correctIndex;

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        widget.onAnswer(isCorrect, widget.shuffledOptions[widget.correctIndex]);
      }
    });
  }

  BoxDecoration _getOptionDecoration(int index) {
    if (!_showResult) {
      if (_selectedIndex == index) {
        return BoxDecoration(
          color: AppColors.primaryOverlay,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: AppColors.primary, width: 1.5),
        );
      }
      return BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppColors.outlineVariant, width: 1.5),
      );
    }

    if (index == widget.correctIndex) {
      return BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppColors.success, width: 1.5),
      );
    }

    if (index == _selectedIndex && index != widget.correctIndex) {
      return BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppColors.error, width: 1.5),
      );
    }

    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12.0),
      border: Border.all(color: AppColors.outlineVariant, width: 1.5),
    );
  }

  TextStyle _getOptionTextStyle(int index) {
    if (!_showResult) {
      if (_selectedIndex == index) {
        return AppTypography.bodyMd.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600);
      }
      return AppTypography.bodyMd.copyWith(color: AppColors.textPrimary);
    }

    if (index == widget.correctIndex) {
      return AppTypography.bodyMd.copyWith(color: AppColors.success, fontWeight: FontWeight.w600);
    }
    if (index == _selectedIndex && index != widget.correctIndex) {
      return AppTypography.bodyMd.copyWith(color: AppColors.error, fontWeight: FontWeight.w600);
    }

    return AppTypography.bodyMd.copyWith(color: AppColors.textPrimary);
  }

  Color _getBadgeColor(int index) {
    if (!_showResult) {
      if (_selectedIndex == index) return AppColors.primary;
      return AppColors.surfaceContainerHigh;
    }
    if (index == widget.correctIndex) return AppColors.success;
    if (index == _selectedIndex && index != widget.correctIndex) return AppColors.error;
    return AppColors.surfaceContainerHigh;
  }

  Color _getBadgeTextColor(int index) {
    if (!_showResult) {
      if (_selectedIndex == index) return AppColors.white;
      return AppColors.textSecondary;
    }
    if (index == widget.correctIndex) return AppColors.white;
    if (index == _selectedIndex && index != widget.correctIndex) return AppColors.white;
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.progressText != null || widget.streakText != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.progressText != null)
                      Text(
                        widget.progressText!,
                        style: AppTypography.bodySm.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    if (widget.streakText != null)
                      Text(
                        widget.streakText!,
                        style: AppTypography.bodyLg.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12.0),
              ],
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: AppColors.outlineVariant, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.08),
                      blurRadius: 12.0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  widget.question.enunciado,
                  style: AppTypography.bodyLg.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Column(
                children: List.generate(widget.shuffledOptions.length, (index) {
                  final option = widget.shuffledOptions[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: GestureDetector(
                      onTap: _showResult ? null : () => _handleSelect(index),
                      child: Container(
                        decoration: _getOptionDecoration(index),
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 32.0,
                              height: 32.0,
                              decoration: BoxDecoration(
                                color: _getBadgeColor(index),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Center(
                                child: Text(
                                  _optionLetters[index],
                                  style: AppTypography.labelLg.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: _getBadgeTextColor(index),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Text(
                                option,
                                style: _getOptionTextStyle(index),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
