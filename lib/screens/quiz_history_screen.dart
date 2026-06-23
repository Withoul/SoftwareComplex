import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/storage_service.dart';
import 'quiz_detail_screen.dart';

class QuizHistoryScreen extends StatefulWidget {
  const QuizHistoryScreen({Key? key}) : super(key: key);

  @override
  State<QuizHistoryScreen> createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen> {
  final StorageService _storageService = StorageService();
  List<Map<String, dynamic>> _history = [];
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
    final hist = await _storageService.getQuizHistory();
    if (mounted) {
      setState(() {
        _history = hist;
        _isLoading = false;
      });
    }
  }

  Color _getModeColor(String mode) {
    if (mode.contains('Tiempo')) {
      return AppColors.primaryLight;
    } else if (mode.contains('Infinita')) {
      return AppColors.secondary;
    } else {
      return AppColors.primary;
    }
  }

  IconData _getModeIcon(String mode) {
    if (mode.contains('Tiempo')) {
      return Ionicons.timer_outline;
    } else if (mode.contains('Infinita')) {
      return Ionicons.infinite_outline;
    } else {
      return Ionicons.dice_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Historial de Preguntas',
          style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _history.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80.0,
                            height: 80.0,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryOverlay,
                            ),
                            child: const Icon(Ionicons.time_outline, size: 40.0, color: AppColors.primary),
                          ),
                          const SizedBox(height: 24.0),
                          Text(
                            'Historial vacío',
                            style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Completa simulacros o rachas para ver tus resultados guardados aquí.',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 40.0),
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      final item = _history[index];
                      final mode = item['mode'] ?? 'Simulacro';
                      final score = item['score'] ?? 0;
                      final total = item['total'] ?? 0;
                      final date = item['date'] ?? '';

                      final modeColor = _getModeColor(mode);
                      final accuracy = total > 0 ? (score / total) * 100 : 0.0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withOpacity(0.03),
                              blurRadius: 10.0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: AppColors.outlineVariant, width: 1.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => QuizDetailScreen(attempt: item),
                                ),
                              ).then((_) => _loadHistory());
                            },
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 6.0,
                                    color: modeColor,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(20.0, 16.0, 16.0, 16.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44.0,
                                        height: 44.0,
                                        decoration: BoxDecoration(
                                          color: modeColor.withOpacity(0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          _getModeIcon(mode),
                                          color: modeColor,
                                          size: 22.0,
                                        ),
                                      ),
                                      const SizedBox(width: 16.0),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              mode,
                                              style: AppTypography.bodyMd.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 4.0),
                                            Text(
                                              date,
                                              style: AppTypography.labelSm.copyWith(
                                                color: AppColors.textTertiary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12.0),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '$score/$total',
                                            style: AppTypography.bodyLg.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 2.0),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                                            decoration: BoxDecoration(
                                              color: accuracy >= 80
                                                  ? AppColors.successLight
                                                  : (accuracy >= 50
                                                      ? AppColors.secondaryOverlay
                                                      : const Color(0x14BA1A1A)),
                                              borderRadius: BorderRadius.circular(99.0),
                                            ),
                                            child: Text(
                                              '${accuracy.toStringAsFixed(0)}%',
                                              style: TextStyle(
                                                fontSize: 10.0,
                                                fontWeight: FontWeight.w700,
                                                color: accuracy >= 80
                                                    ? AppColors.success
                                                    : (accuracy >= 50
                                                        ? AppColors.secondaryDark
                                                        : AppColors.error),
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
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
