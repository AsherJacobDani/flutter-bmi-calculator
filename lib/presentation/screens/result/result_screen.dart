import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../../screens/main/main_screen.dart';
import '../../../core/constants/app_colors.dart';

// ─────────────────────────────────────────────
// AI Suggestion Data Model
// ─────────────────────────────────────────────
class AISuggestion {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const AISuggestion({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

List<AISuggestion> _getAISuggestions(double bmi) {
  if (bmi < 18.5) {
    return const [
      AISuggestion(
        icon: Icons.restaurant_menu,
        title: 'Increase Caloric Intake',
        description: 'Aim for calorie-dense, nutrient-rich foods like nuts, avocados, whole grains, and lean proteins.',
        color: Color(0xFF3B82F6),
      ),
      AISuggestion(
        icon: Icons.fitness_center,
        title: 'Strength Training',
        description: 'Focus on resistance exercises 3–4x per week to build muscle mass healthily.',
        color: Color(0xFF8B5CF6),
      ),
      AISuggestion(
        icon: Icons.local_drink,
        title: 'Stay Hydrated',
        description: 'Drink protein shakes or smoothies between meals to add healthy calories.',
        color: Color(0xFF06B6D4),
      ),
      AISuggestion(
        icon: Icons.medical_services_outlined,
        title: 'Consult a Nutritionist',
        description: 'A dietitian can create a personalized meal plan to reach a healthy weight safely.',
        color: Color(0xFFF59E0B),
      ),
    ];
  } else if (bmi < 25.0) {
    return const [
      AISuggestion(
        icon: Icons.check_circle_outline,
        title: 'Maintain Your Balance',
        description: 'Great job! Keep up a balanced diet with fruits, vegetables, and lean proteins.',
        color: Color(0xFF10B981),
      ),
      AISuggestion(
        icon: Icons.directions_run,
        title: 'Stay Active',
        description: 'Aim for 150 minutes of moderate aerobic activity weekly to keep your fitness on track.',
        color: Color(0xFF3B82F6),
      ),
      AISuggestion(
        icon: Icons.bedtime_outlined,
        title: 'Quality Sleep',
        description: 'Maintain 7–9 hours of sleep. Good sleep regulates metabolism and energy levels.',
        color: Color(0xFF8B5CF6),
      ),
      AISuggestion(
        icon: Icons.self_improvement,
        title: 'Mental Wellness',
        description: 'Practice mindfulness or meditation to reduce stress and sustain your healthy lifestyle.',
        color: Color(0xFF06B6D4),
      ),
    ];
  } else if (bmi < 30.0) {
    return const [
      AISuggestion(
        icon: Icons.no_food,
        title: 'Reduce Processed Foods',
        description: 'Cut back on sugar, refined carbs, and fast food. Choose whole foods instead.',
        color: Color(0xFFF59E0B),
      ),
      AISuggestion(
        icon: Icons.directions_walk,
        title: 'Daily Cardio',
        description: 'Start with 30-minute brisk walks daily and gradually increase to jogging or cycling.',
        color: Color(0xFF3B82F6),
      ),
      AISuggestion(
        icon: Icons.water_drop_outlined,
        title: 'Drink More Water',
        description: 'Drink 8–10 glasses of water daily. Staying hydrated helps control appetite.',
        color: Color(0xFF06B6D4),
      ),
      AISuggestion(
        icon: Icons.monitor_weight_outlined,
        title: 'Track Your Progress',
        description: 'Log meals and workouts. Awareness is the first step toward lasting change.',
        color: Color(0xFF8B5CF6),
      ),
    ];
  } else {
    return const [
      AISuggestion(
        icon: Icons.medical_services_outlined,
        title: 'Seek Medical Guidance',
        description: 'Consult a doctor or endocrinologist to rule out underlying health conditions.',
        color: Color(0xFFEF4444),
      ),
      AISuggestion(
        icon: Icons.local_dining,
        title: 'Adopt a Structured Diet',
        description: 'Work with a dietitian on a calorie-deficit meal plan — reduce 500 kcal/day safely.',
        color: Color(0xFFF59E0B),
      ),
      AISuggestion(
        icon: Icons.pool,
        title: 'Low-Impact Exercise',
        description: 'Start with swimming or yoga to reduce joint strain while burning calories effectively.',
        color: Color(0xFF3B82F6),
      ),
      AISuggestion(
        icon: Icons.psychology_outlined,
        title: 'Behavioral Support',
        description: 'Consider joining a support group or therapy to address emotional eating patterns.',
        color: Color(0xFF8B5CF6),
      ),
    ];
  }
}

// ─────────────────────────────────────────────
// Result Screen
// ─────────────────────────────────────────────
class ResultScreen extends StatefulWidget {
  final double bmi;
  final String category;

  const ResultScreen({
    super.key,
    required this.bmi,
    required this.category,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with TickerProviderStateMixin {
  final ScreenshotController _screenshotController = ScreenshotController();

  late AnimationController _entranceController;
  late AnimationController _exitController;
  late AnimationController _aiController;
  late AnimationController _pulseController;

  // Entrance animations
  late Animation<double> _titleOpacity;
  late Animation<double> _deskOpacity;
  late Animation<double> _resultOpacity;
  late Animation<double> _bmiTextOpacity;
  late Animation<double> _bmiNormalOpacity;
  late Animation<double> _buttonsOpacity;
  late Animation<double> _aiCardOpacity;

  late Animation<Offset> _titleSlide;
  late Animation<Offset> _deskSlide;
  late Animation<Offset> _resultSlide;
  late Animation<Offset> _bmiTextSlide;
  late Animation<Offset> _bmiNormalSlide;
  late Animation<Offset> _buttonsSlide;
  late Animation<Offset> _aiCardSlide;

  late Animation<double> _deskPadding;
  late Animation<double> _pulseAnim;

  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _entranceController.forward().then((_) {
      _aiController.forward();
    });
    _pulseController.repeat(reverse: true);
  }

  void _setupAnimations() {
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _aiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.0, 0.3, curve: Curves.easeOut)),
    );
    _deskOpacity = Tween<double>(begin: 0.0, end: 0.7).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.2, 0.6, curve: Curves.easeOut)),
    );
    _resultOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.4, 0.8, curve: Curves.easeOut)),
    );
    _bmiTextOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.35, 0.75, curve: Curves.easeOut)),
    );
    _bmiNormalOpacity = Tween<double>(begin: 0.0, end: 0.3).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.4, 0.8, curve: Curves.easeOut)),
    );
    _buttonsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.5, 0.9, curve: Curves.easeOut)),
    );
    _aiCardOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _aiController, curve: Curves.easeOut),
    );

    _titleSlide = Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.0, 0.3, curve: Curves.easeOutCubic)),
    );
    _deskSlide = Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic)),
    );
    _resultSlide = Tween<Offset>(begin: const Offset(0.0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic)),
    );
    _bmiTextSlide = Tween<Offset>(begin: const Offset(0.0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.35, 0.75, curve: Curves.easeOutCubic)),
    );
    _bmiNormalSlide = Tween<Offset>(begin: const Offset(0.0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic)),
    );
    _buttonsSlide = Tween<Offset>(begin: const Offset(0.0, 0.25), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.5, 0.9, curve: Curves.easeOutCubic)),
    );
    _aiCardSlide = Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _aiController, curve: Curves.easeOutCubic),
    );

    _deskPadding = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.2, 0.6, curve: Curves.easeOut)),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _exitController.dispose();
    _aiController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _backPreviousPage() {
    if (_isExiting) return;
    setState(() => _isExiting = true);
    _exitController.forward();
    Future.delayed(const Duration(milliseconds: 550), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const MainScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
    });
  }

  Future<void> _shareResultImage() async {
    try {
      final imageBytes = await _screenshotController.capture();
      if (imageBytes != null) {
        final tempDir = await getTemporaryDirectory();
        final file = await File('${tempDir.path}/bmi_result.png').create();
        await file.writeAsBytes(imageBytes);
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'My BMI is ${widget.bmi.toStringAsFixed(1)} (${_getDisplayCategory()}). Calculated using BMI Calculator!',
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error generating result card image.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to share: $e')));
    }
  }

  String _getDisplayCategory() {
    if (widget.bmi < 18.5) {
      return "You are Under Weight";
    } else if (widget.bmi < 25.0) {
      return "You are Healthy";
    } else if (widget.bmi < 30) {
      return "You are Overweight";
    } else {
      return "You are Suffering from Obesity";
    }
  }

  Color _getCategoryAccentColor() {
    if (widget.bmi < 18.5) {
      return const Color(0xFF3B82F6);
    } else if (widget.bmi < 25.0) {
      return const Color(0xFF10B981);
    } else if (widget.bmi < 30) {
      return const Color(0xFFF59E0B);
    } else {
      return const Color(0xFFEF4444);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final labelColor = isDark ? AppColors.darkTextAdditional : AppColors.lightTextAdditional;
    final backgroundColor = isDark ? AppColors.darkBackgroundAdditional : AppColors.lightBackgroundAdditional;
    final accentColor = _getCategoryAccentColor();
    final suggestions = _getAISuggestions(widget.bmi);

    final exitSlide = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1.0)).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInOutCubic),
    );
    final exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeOut),
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _exitController,
          builder: (context, child) {
            return Transform.translate(
              offset: exitSlide.value * 300,
              child: Opacity(opacity: exitOpacity.value, child: child),
            );
          },
          child: Column(
            children: [
              // Header
              FadeTransition(
                opacity: _titleOpacity,
                child: SlideTransition(
                  position: _titleSlide,
                  child: Container(
                    height: 70,
                    alignment: Alignment.center,
                    child: Text(
                      'Your Health',
                      style: TextStyle(
                        fontFamily: 'Larsseit',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Screenshot Wrapper
                      Screenshot(
                        controller: _screenshotController,
                        child: Container(
                          color: backgroundColor,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              FadeTransition(
                                opacity: _deskOpacity,
                                child: SlideTransition(
                                  position: _deskSlide,
                                  child: AnimatedBuilder(
                                    animation: _deskPadding,
                                    builder: (context, child) => Padding(
                                      padding: EdgeInsets.all(_deskPadding.value),
                                      child: Image.asset(
                                        'assets/images/shelf.png',
                                        width: double.infinity,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  const SizedBox(height: 10),
                                  FadeTransition(
                                    opacity: _resultOpacity,
                                    child: SlideTransition(
                                      position: _resultSlide,
                                      child: Text(
                                        widget.bmi.toStringAsFixed(1),
                                        style: TextStyle(
                                          fontFamily: 'Larsseit',
                                          fontSize: 120,
                                          fontWeight: FontWeight.bold,
                                          color: labelColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // BMI Status
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          children: [
                            FadeTransition(
                              opacity: _bmiTextOpacity,
                              child: SlideTransition(
                                position: _bmiTextSlide,
                                child: SizedBox(
                                  height: 50,
                                  child: Center(
                                    child: Text(
                                      _getDisplayCategory(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Larsseit',
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: labelColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            FadeTransition(
                              opacity: _bmiNormalOpacity,
                              child: SlideTransition(
                                position: _bmiNormalSlide,
                                child: Text(
                                  'Normal BMI weight range for the height: 18.5 – 24.9',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Larsseit',
                                    fontSize: 16,
                                    color: labelColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── AI Suggestions Section ──────────────────────────
                      FadeTransition(
                        opacity: _aiCardOpacity,
                        child: SlideTransition(
                          position: _aiCardSlide,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Section Header
                                Row(
                                  children: [
                                    AnimatedBuilder(
                                      animation: _pulseAnim,
                                      builder: (context, child) => Transform.scale(
                                        scale: _pulseAnim.value,
                                        child: child,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [accentColor, accentColor.withOpacity(0.6)],
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: accentColor.withOpacity(0.4),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'AI Health Recommendations',
                                      style: TextStyle(
                                        fontFamily: 'Larsseit',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Personalized tips based on your BMI result',
                                  style: TextStyle(
                                    fontFamily: 'Larsseit',
                                    fontSize: 12,
                                    color: textColor.withOpacity(0.45),
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Suggestion Cards
                                ...suggestions.asMap().entries.map((entry) {
                                  final i = entry.key;
                                  final s = entry.value;
                                  return _AISuggestionCard(
                                    suggestion: s,
                                    index: i,
                                    isDark: isDark,
                                    parentController: _aiController,
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Action Buttons
                      FadeTransition(
                        opacity: _buttonsOpacity,
                        child: SlideTransition(
                          position: _buttonsSlide,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: _backPreviousPage,
                                  child: Opacity(
                                    opacity: 0.3,
                                    child: Container(
                                      width: 55,
                                      height: 55,
                                      decoration: const BoxDecoration(
                                        color: Colors.transparent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.delete_outline, size: 28),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                GestureDetector(
                                  onTap: _backPreviousPage,
                                  child: Container(
                                    width: 55,
                                    height: 55,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.refresh, color: Colors.white, size: 28),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                GestureDetector(
                                  onTap: _shareResultImage,
                                  child: Opacity(
                                    opacity: 0.3,
                                    child: Container(
                                      width: 55,
                                      height: 55,
                                      decoration: const BoxDecoration(
                                        color: Colors.transparent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.share_outlined, size: 28),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// AI Suggestion Card Widget
// ─────────────────────────────────────────────
class _AISuggestionCard extends StatefulWidget {
  final AISuggestion suggestion;
  final int index;
  final bool isDark;
  final AnimationController parentController;

  const _AISuggestionCard({
    required this.suggestion,
    required this.index,
    required this.isDark,
    required this.parentController,
  });

  @override
  State<_AISuggestionCard> createState() => _AISuggestionCardState();
}

class _AISuggestionCardState extends State<_AISuggestionCard> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnim;
  late Animation<double> _slideAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );

    final start = 0.1 * widget.index;
    final end = (0.1 * widget.index + 0.6).clamp(0.0, 1.0);

    _slideAnim = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: widget.parentController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.parentController,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = widget.isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final s = widget.suggestion;

    return AnimatedBuilder(
      animation: widget.parentController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnim.value),
          child: Opacity(opacity: _opacityAnim.value, child: child),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => _hoverController.forward(),
        onTapUp: (_) => _hoverController.reverse(),
        onTapCancel: () => _hoverController.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnim,
          builder: (context, child) => Transform.scale(scale: _scaleAnim.value, child: child),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: s.color.withOpacity(0.15), width: 1),
              boxShadow: [
                BoxShadow(
                  color: s.color.withOpacity(widget.isDark ? 0.12 : 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Subtle gradient shimmer top-right
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: s.color.withOpacity(0.08),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon container
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [s.color, s.color.withOpacity(0.7)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: s.color.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(s.icon, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.title,
                                style: TextStyle(
                                  fontFamily: 'Larsseit',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: widget.isDark ? Colors.white : const Color(0xFF1A1A2E),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                s.description,
                                style: TextStyle(
                                  fontFamily: 'Larsseit',
                                  fontSize: 12,
                                  height: 1.5,
                                  color: widget.isDark
                                      ? Colors.white.withOpacity(0.55)
                                      : const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
