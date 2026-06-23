import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../data/questions.dart';
import 'modo_aleatorio_screen.dart';

class ModoFijoSetupScreen extends StatefulWidget {
  const ModoFijoSetupScreen({Key? key}) : super(key: key);

  @override
  State<ModoFijoSetupScreen> createState() => _ModoFijoSetupScreenState();
}

class _ModoFijoSetupScreenState extends State<ModoFijoSetupScreen> {
  final TextEditingController _startController = TextEditingController(text: '1');
  final TextEditingController _endController = TextEditingController(text: '40');

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  void _handleStart() {
    final start = int.tryParse(_startController.text.trim());
    final end = int.tryParse(_endController.text.trim());
    final max = QUESTIONS.length;

    if (start == null ||
        end == null ||
        start < 1 ||
        end > max ||
        start > end) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Rango inválido'),
          content: Text('Por favor ingresa un rango válido entre 1 y $max.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
      return;
    }

    final selectedQuestions = QUESTIONS.sublist(start - 1, end);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ModoAleatorioScreen(
          presetQuestions: selectedQuestions,
          isSequential: true,
          title: 'Quiz Fijo',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final max = QUESTIONS.length;

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
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 96.0,
                      height: 96.0,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.secondaryOverlay,
                      ),
                      child: const Icon(Ionicons.list_outline, size: 48.0, color: AppColors.secondary),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Text(
                    'Cuestionario Fijo',
                    textAlign: TextAlign.center,
                    style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Resuelve las preguntas en orden secuencial según el rango elegido.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 32.0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Desde:',
                            style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 8.0),
                          SizedBox(
                            width: 100.0,
                            child: TextField(
                              controller: _startController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w700),
                              decoration: InputDecoration(
                                fillColor: AppColors.white,
                                filled: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: const BorderSide(color: AppColors.outlineVariant, width: 1.5),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          margin: const EdgeInsets.only(top: 24.0),
                          child: Text(
                            '-',
                            style: AppTypography.headlineMd.copyWith(color: AppColors.textTertiary),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            'Hasta:',
                            style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 8.0),
                          SizedBox(
                            width: 100.0,
                            child: TextField(
                              controller: _endController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w700),
                              decoration: InputDecoration(
                                fillColor: AppColors.white,
                                filled: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: const BorderSide(color: AppColors.outlineVariant, width: 1.5),
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
                    'Máximo disponible: $max',
                    textAlign: TextAlign.center,
                    style: AppTypography.labelSm.copyWith(color: AppColors.textTertiary),
                  ),
                  const SizedBox(height: 32.0),

                  ElevatedButton.icon(
                    onPressed: _handleStart,
                    icon: const Icon(Ionicons.play, color: AppColors.primaryDark, size: 20.0),
                    label: const Text('Iniciar Cuestionario', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
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
          ],
        ),
      ),
    );
  }
}
