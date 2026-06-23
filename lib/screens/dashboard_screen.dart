import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../components/mode_card.dart';
import '../components/stat_card.dart';
import '../services/storage_service.dart';
import 'racha_infinita_screen.dart';
import 'modo_aleatorio_screen.dart';
import 'modo_refuerzo_screen.dart';
import 'modo_repaso_setup_screen.dart';
import 'modo_fijo_setup_screen.dart';
import 'quiz_history_screen.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final StorageService _storageService = StorageService();

  String _userName = '';
  int _pointsToday = 0;
  int _currentStreak = 0;

  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkUserName();
    _loadStats();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _checkUserName() async {
    final name = await _storageService.getUserName();
    if (name != null && name.isNotEmpty) {
      setState(() {
        _userName = name;
      });
    } else {
      // Show name dialog on next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNameDialog();
      });
    }
  }

  Future<void> _loadStats() async {
    final points = await _storageService.getPointsToday();
    final streak = await _storageService.getCurrentStreak();

    setState(() {
      _pointsToday = points;
      _currentStreak = streak;
    });
  }

  void _showNameDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false, // Prevent back button dismissing
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.0),
            ),
            backgroundColor: AppColors.white,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Ionicons.person_circle,
                    size: 64.0,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    '¡Bienvenido!',
                    style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    '¿Cómo te llamas?',
                    style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24.0),
                  TextField(
                    controller: _nameController,
                    style: AppTypography.bodyMd,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'Tu nombre...',
                      hintStyle: const TextStyle(color: AppColors.textTertiary),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(color: AppColors.outlineVariant, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: () async {
                      final name = _nameController.text.trim();
                      final finalName = name.isNotEmpty ? name : 'Estudiante';
                      await _storageService.saveUserName(finalName);
                      setState(() {
                        _userName = finalName;
                      });
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size(double.infinity, 50.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 0.0,
                    ),
                    child: Text(
                      'Comenzar',
                      style: AppTypography.labelLg.copyWith(color: AppColors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  void _navigateTo(Widget screen) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => screen))
        .then((_) => _loadStats()); // Reload stats when returning to dashboard
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24.0, 40.0, 24.0, 100.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: AppTypography.headlineMd.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              height: 1.2,
                            ),
                            children: [
                              const TextSpan(text: 'Hola, '),
                              TextSpan(
                                text: _userName,
                                style: const TextStyle(color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          '¿Qué desafío conquistaremos hoy?',
                          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),

              // Stats Row
              Row(
                children: [
                  StatCard(
                    label: 'Puntos Hoy',
                    value: _pointsToday.toString(),
                  ),
                  const SizedBox(width: 16.0),
                  StatCard(
                    label: 'Racha',
                    value: _currentStreak.toString(),
                    icon: '🔥',
                    color: AppColors.secondary,
                  ),
                ],
              ),
              const SizedBox(height: 24.0),

              // Quiz History Shortcut Card
              GestureDetector(
                onTap: () => _navigateTo(const QuizHistoryScreen()),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOverlay,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.0),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: const Icon(Ionicons.time, size: 20.0, color: AppColors.white),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Historial de Preguntas',
                              style: AppTypography.bodySm.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              'Revisa tus últimos 20 simulacros realizados',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Ionicons.chevron_forward, size: 18.0, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32.0),

              // Modes Section
              Text(
                'Modos de Estudio',
                style: AppTypography.bodyLg.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16.0),

              ModeCard(
                title: 'Modo Racha Infinita',
                subtitle: 'Responde hasta fallar',
                icon: Ionicons.infinite,
                iconBgColor: AppColors.primaryOverlay,
                onPress: () => _navigateTo(const RachaInfinitaScreen()),
              ),
              ModeCard(
                title: 'Modo Aleatorio',
                subtitle: 'Simulacro con promedio',
                icon: Ionicons.dice_outline,
                iconBgColor: AppColors.secondaryOverlay,
                onPress: () => _navigateTo(const ModoAleatorioScreen()),
              ),
              ModeCard(
                title: 'Modo Refuerzo',
                subtitle: 'Estudia y responde preguntas erradas',
                icon: Ionicons.barbell_outline,
                iconBgColor: const Color(0x26E65100),
                onPress: () => _navigateTo(const ModoRefuerzoScreen()),
              ),
              ModeCard(
                title: 'Estudio por Temario',
                subtitle: 'Repasa y luego evalúate',
                icon: Ionicons.book_outline,
                iconBgColor: AppColors.primaryOverlay,
                onPress: () => _navigateTo(const ModoRepasoSetupScreen()),
              ),
              ModeCard(
                title: 'Cuestionario Fijo',
                subtitle: 'Preguntas en orden secuencial',
                icon: Ionicons.list_outline,
                iconBgColor: const Color(0x262E7D32),
                onPress: () => _navigateTo(const ModoFijoSetupScreen()),
              ),

              const SizedBox(height: 8.0),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.primaryOverlay,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Ionicons.library_outline,
                      size: 20.0,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                          children: const [
                            TextSpan(text: 'Base de datos: '),
                            TextSpan(
                              text: '400 preguntas',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            TextSpan(text: ' listas para practicar'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
