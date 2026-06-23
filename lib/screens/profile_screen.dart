import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../components/progress_bar.dart';
import '../services/storage_service.dart';
import 'quiz_history_screen.dart';



class PresetAvatar {
  final String id;
  final String emoji;
  final Color color;
  final String name;

  const PresetAvatar({
    required this.id,
    required this.emoji,
    required this.color,
    required this.name,
  });
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();

  String _userName = 'Estudiante';
  bool _isEditingName = false;
  final TextEditingController _nameController = TextEditingController();

  int _totalAnswered = 0;
  int _totalCorrect = 0;
  int _masteredCount = 0;
  double _globalPrecision = 0.0;
  int _bestStreak = 0;
  int _currentStreak = 0;

  // Profile image
  String? _profilePic;



  static const List<PresetAvatar> _presetAvatars = [
    PresetAvatar(id: 'avatar_brain', emoji: '🧠', color: Color(0xFF5C59CE), name: 'Mente Activa'),
    PresetAvatar(id: 'avatar_laptop', emoji: '💻', color: Color(0xFF131370), name: 'Desarrollador'),
    PresetAvatar(id: 'avatar_rocket', emoji: '🚀', color: Color(0xFFE65100), name: 'Despegue'),
    PresetAvatar(id: 'avatar_grad', emoji: '🎓', color: Color(0xFF2E7D32), name: 'Graduado'),
    PresetAvatar(id: 'avatar_fire', emoji: '🔥', color: Color(0xFFFAC70F), name: 'Racha'),
    PresetAvatar(id: 'avatar_star', emoji: '⭐', color: Color(0xFF006064), name: 'Estrella'),
  ];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    final name = await _storageService.getUserName();
    final nameStr = name ?? 'Estudiante';

    final stats = await _storageService.getTotalStats();

    // Mastered calculation (accuracy = 100%)
    final history = await _storageService.getQuestionHistory();
    int mastered = 0;
    history.forEach((_, attempts) {
      if (attempts.isNotEmpty && attempts.every((x) => x == true)) {
        mastered++;
      }
    });

    final totalAns = stats['totalAnswered'] ?? 0;
    final totalCorr = stats['totalCorrect'] ?? 0;
    final precision = totalAns > 0 ? (totalCorr / totalAns) * 100.0 : 0.0;

    final best = await _storageService.getBestStreak();

    final curr = await _storageService.getCurrentStreak();

    final pic = await _storageService.getProfileImage();

    if (mounted) {
      setState(() {
        _userName = nameStr;
        _nameController.text = nameStr;
        _totalAnswered = stats['totalAnswered'] ?? 0;
        _totalCorrect = stats['totalCorrect'] ?? 0;
        _masteredCount = mastered;
        _globalPrecision = precision;
        _bestStreak = best;
        _currentStreak = curr;

        _profilePic = pic;
      });
    }
  }

  Future<void> _handleSaveName() async {
    final trimmed = _nameController.text.trim();
    if (trimmed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre no puede estar vacío.')),
      );
      return;
    }
    await _storageService.saveUserName(trimmed);
    setState(() {
      _userName = trimmed;
      _isEditingName = false;
    });
  }



  Future<void> _handlePickGallery() async {
    Navigator.of(context).pop();
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 40,
        maxWidth: 300,
        maxHeight: 300,
      );
      if (image != null) {
        await _storageService.saveProfileImage(image.path);
        setState(() {
          _profilePic = image.path;
        });
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al seleccionar la imagen de galería.')),
      );
    }
  }

  Future<void> _handleSelectPreset(String presetId) async {
    Navigator.of(context).pop();
    await _storageService.saveProfileImage(presetId);
    setState(() {
      _profilePic = presetId;
    });
  }

  Future<void> _handleRemovePhoto() async {
    Navigator.of(context).pop();
    await _storageService.saveProfileImage(null);
    setState(() {
      _profilePic = null;
    });
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Cambiar Foto de Perfil',
                textAlign: TextAlign.center,
                style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Elige un Avatar Ilustrado:',
                style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12.0),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 1.25,
                ),
                itemCount: _presetAvatars.length,
                itemBuilder: (context, index) {
                  final avatar = _presetAvatars[index];
                  return GestureDetector(
                    onTap: () => _handleSelectPreset(avatar.id),
                    child: Container(
                      decoration: BoxDecoration(
                        color: avatar.color,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(avatar.emoji, style: const TextStyle(fontSize: 28.0)),
                          const SizedBox(height: 4.0),
                          Text(
                            avatar.name,
                            style: const TextStyle(fontSize: 9.0, color: AppColors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16.0),
              const Divider(color: AppColors.surfaceContainerHigh),
              const SizedBox(height: 8.0),
              ListTile(
                leading: const Icon(Ionicons.images_outline, color: AppColors.primary),
                title: Text('Subir foto desde Galería', style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w600)),
                tileColor: AppColors.surfaceContainerLow,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                onTap: _handlePickGallery,
              ),
              if (_profilePic != null) ...[
                const SizedBox(height: 8.0),
                ListTile(
                  leading: const Icon(Ionicons.trash_outline, color: AppColors.error),
                  title: Text('Eliminar foto actual', style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w600, color: AppColors.error)),
                  tileColor: const Color(0x14BA1A1A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  onTap: _handleRemovePhoto,
                ),
              ],
              const SizedBox(height: 12.0),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancelar', style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatarWidget() {
    if (_profilePic == null) {
      return Container(
        width: 90.0,
        height: 90.0,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
        ),
        child: const Icon(Ionicons.person, size: 40.0, color: AppColors.white),
      );
    }

    if (_profilePic!.startsWith('avatar_')) {
      final preset = _presetAvatars.firstWhere((a) => a.id == _profilePic,
          orElse: () => _presetAvatars[0]);
      return Container(
        width: 90.0,
        height: 90.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: preset.color,
        ),
        child: Center(
          child: Text(preset.emoji, style: const TextStyle(fontSize: 42.0)),
        ),
      );
    }

    return Container(
      width: 90.0,
      height: 90.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2.0),
        image: DecorationImage(
          image: FileImage(File(_profilePic!)),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Future<void> _launchGitHub() async {
    final Uri url = Uri.parse('https://github.com/Withoul/SimuladorComplex');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el enlace.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24.0, 30.0, 24.0, 100.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Header
              Column(
                children: [
                  GestureDetector(
                    onTap: _showAvatarPicker,
                    child: Stack(
                      children: [
                        _buildAvatarWidget(),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 28.0,
                            height: 28.0,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                              border: Border.fromBorderSide(BorderSide(color: AppColors.white, width: 2.0)),
                            ),
                            child: const Icon(Ionicons.camera, size: 14.0, color: AppColors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isEditingName)
                        Expanded(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 240.0),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: AppColors.primary, width: 1.5)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _nameController,
                                    style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w700),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(vertical: 4.0),
                                    ),
                                    autofocus: true,
                                    onSubmitted: (_) => _handleSaveName(),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _handleSaveName,
                                  child: const Icon(Ionicons.checkmark_circle, size: 28.0, color: AppColors.success),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Row(
                          children: [
                            Text(
                              _userName,
                              style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(width: 8.0),
                            GestureDetector(
                              onTap: () => setState(() => _isEditingName = true),
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(Ionicons.pencil_outline, size: 18.0, color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Toca la foto para cambiar de avatar',
                    style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 32.0),

              // Stats Grid
              Text(
                'Estadísticas Generales',
                style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16.0),
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                  childAspectRatio: 1.35,
                ),
                children: [
                  _buildStatBox(
                    number: _totalAnswered.toString(),
                    label: 'Preguntas respondidas',
                    icon: Ionicons.help_circle,
                    color: AppColors.primary,
                    bgColor: const Color(0xFFF3F2FD),
                  ),
                  _buildStatBox(
                    number: _totalCorrect.toString(),
                    label: 'Respuestas correctas',
                    icon: Ionicons.checkmark_circle,
                    color: AppColors.success,
                    bgColor: const Color(0xFFF1F8F2),
                  ),
                  _buildStatBox(
                    number: _masteredCount.toString(),
                    label: 'Preguntas al 100%',
                    icon: Ionicons.medal,
                    color: const Color(0xFF00ACC1),
                    bgColor: const Color(0xFFE0F7FA),
                  ),
                  _buildStatBox(
                    number: _bestStreak.toString(),
                    label: 'Mejor racha',
                    icon: Ionicons.flame,
                    color: const Color(0xFFFFA000),
                    bgColor: const Color(0xFFFFF8E1),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Mastered Accuracy Progress
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Precisión Global (Aciertos)',
                                style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 2.0),
                              Text(
                                'Porcentaje de aciertos sobre preguntas respondidas',
                                style: AppTypography.labelSm.copyWith(color: AppColors.textTertiary),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${_globalPrecision.toStringAsFixed(1)}%',
                          style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    ProgressBar(
                      progress: _globalPrecision / 100.0,
                      height: 10.0,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32.0),


              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: AppColors.secondaryOverlay,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Row(
                  children: [
                    const Icon(Ionicons.flame, size: 28.0, color: AppColors.secondary),
                    const SizedBox(width: 12.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_currentStreak días',
                          style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          'Racha actual de estudio',
                          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
              ListTile(
                leading: const Icon(Ionicons.time_outline, color: AppColors.primary),
                title: Text(
                  'Historial de Preguntas',
                  style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Revisa tus últimos 20 simulacros',
                  style: AppTypography.labelSm.copyWith(color: AppColors.textTertiary),
                ),
                trailing: const Icon(Ionicons.chevron_forward_outline, size: 18.0),
                tileColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  side: const BorderSide(color: AppColors.outlineVariant, width: 1.0),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const QuizHistoryScreen()),
                  ).then((_) => _loadAll());
                },
              ),
              const SizedBox(height: 32.0),
              const Divider(color: AppColors.surfaceContainerHigh),
              const SizedBox(height: 24.0),
              Column(
                children: [
                  Text(
                    'CREADOR',
                    style: AppTypography.labelSm.copyWith(color: AppColors.textTertiary, letterSpacing: 1.5, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Alex Murillo',
                    style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton.icon(
                    onPressed: _launchGitHub,
                    icon: const Icon(Ionicons.logo_github, color: AppColors.white, size: 18.0),
                    label: const Text('Ver en GitHub', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1C1B1B),
                      minimumSize: const Size(160.0, 44.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99.0),
                      ),
                      elevation: 2.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox({
    required String number,
    required String label,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: color.withOpacity(0.2), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16.0, color: color),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                number,
                style: AppTypography.headlineSm.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 26.0,
                  color: AppColors.textPrimary,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11.0,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


}
