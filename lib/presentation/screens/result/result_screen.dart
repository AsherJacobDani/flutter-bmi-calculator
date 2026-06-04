import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../../screens/main/main_screen.dart';
import '../../../core/constants/app_colors.dart';

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

  // Staggered Entrance Animations
  late Animation<double> _titleOpacity;
  late Animation<double> _deskOpacity;
  late Animation<double> _resultOpacity;
  late Animation<double> _bmiTextOpacity;
  late Animation<double> _bmiNormalOpacity;
  late Animation<double> _buttonsOpacity;

  late Animation<Offset> _titleSlide;
  late Animation<Offset> _deskSlide;
  late Animation<Offset> _resultSlide;
  late Animation<Offset> _bmiTextSlide;
  late Animation<Offset> _bmiNormalSlide;
  late Animation<Offset> _buttonsSlide;

  late Animation<double> _deskPadding;

  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _entranceController.forward();
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

    // Initial padding animation for the shelf image (shrinks down to 0)
    _deskPadding = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.2, 0.6, curve: Curves.easeOut)),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  void _backPreviousPage() {
    if (_isExiting) return;
    setState(() {
      _isExiting = true;
    });

    _exitController.forward();

    Future.delayed(const Duration(milliseconds: 550), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const MainScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share: $e')),
      );
    }
  }

  String _getDisplayCategory() {
    if (widget.bmi < 18.5) {
      return "You are Under Weight";
    } else if (widget.bmi < 24.9) {
      return "You are Healthy";
    } else if (widget.bmi < 30) {
      return "You are Overweight";
    } else {
      return "You are Suffering from Obesity";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final labelColor = isDark ? AppColors.darkTextAdditional : AppColors.lightTextAdditional;
    final backgroundColor = isDark ? AppColors.darkBackgroundAdditional : AppColors.lightBackgroundAdditional;

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
              child: Opacity(
                opacity: exitOpacity.value,
                child: child,
              ),
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
                  child: Column(
                    children: [
                      // Screenshot Wrapper for Share Image
                      Screenshot(
                        controller: _screenshotController,
                        child: Container(
                          color: backgroundColor, // preserve bg color in screenshot
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              // Shelf Desk Image
                              FadeTransition(
                                opacity: _deskOpacity,
                                child: SlideTransition(
                                  position: _deskSlide,
                                  child: AnimatedBuilder(
                                    animation: _deskPadding,
                                    builder: (context, child) {
                                      return Padding(
                                        padding: EdgeInsets.all(_deskPadding.value),
                                        child: Image.asset(
                                          'assets/images/shelf.png',
                                          width: double.infinity,
                                          fit: BoxFit.contain,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),

                              // BMI value overlay (resultText)
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

                      // BMI status description (bmiText)
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
                            
                            // Normal range descriptor (bmiTextNormal)
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

                      const SizedBox(height: 60),

                      // Control Buttons Layout (delete, reload, share)
                      FadeTransition(
                        opacity: _buttonsOpacity,
                        child: SlideTransition(
                          position: _buttonsSlide,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Delete / Back Button (left)
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
                                      child: const Icon(
                                        Icons.delete_outline,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),

                                // Reload Button (middle)
                                GestureDetector(
                                  onTap: _backPreviousPage,
                                  child: Container(
                                    width: 55,
                                    height: 55,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.refresh,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),

                                // Share Button (right)
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
                                      child: const Icon(
                                        Icons.share_outlined,
                                        size: 28,
                                      ),
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
