import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../../widgets/custom_swipe_button.dart';
import '../../widgets/gender_wheel_picker.dart';
import '../../widgets/height_wheel_picker.dart';
import '../../widgets/weight_horizontal_picker.dart';
import '../auth/login_screen.dart';
import '../profile/profile_screen.dart';
import '../result/result_screen.dart';
import '../../../data/models/bmi_record.dart';
import '../../../data/repositories/user_profile_repository.dart';
import '../../../core/constants/app_colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  final _userProfileRepository = UserProfileRepository();

  String _gender = 'M';
  int _weight = 50;
  int _height = 160;

  bool _doubleBackToExitPressedOnce = false;

  // Entrance and Exit Animation controllers
  late AnimationController _entranceController;
  late AnimationController _exitController;

  // Animation values
  late Animation<double> _titleOpacity;
  late Animation<double> _bodyOpacity;
  late Animation<double> _footerOpacity;
  late Animation<double> _heightOpacity;
  late Animation<double> _weightOpacity;

  late Animation<Offset> _titleSlide;
  late Animation<Offset> _bodySlide;
  late Animation<Offset> _footerSlide;
  late Animation<Offset> _heightSlide;
  late Animation<Offset> _weightSlide;


  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _entranceController.forward();
  }

  void _setupAnimations() {
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Staggered Entrance Animations
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );
    _bodyOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.3, 0.8, curve: Curves.easeOut)),
    );
    _footerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.4, 0.9, curve: Curves.easeOut)),
    );
    _heightOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.45, 0.95, curve: Curves.easeOut)),
    );
    _weightOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.5, 1.0, curve: Curves.easeOut)),
    );

    _titleSlide = Tween<Offset>(begin: const Offset(0.0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic)),
    );
    _bodySlide = Tween<Offset>(begin: const Offset(0.0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic)),
    );
    _footerSlide = Tween<Offset>(begin: const Offset(0.0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.4, 0.9, curve: Curves.easeOutCubic)),
    );
    _heightSlide = Tween<Offset>(begin: const Offset(0.0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.45, 0.95, curve: Curves.easeOutCubic)),
    );
    _weightSlide = Tween<Offset>(begin: const Offset(0.5, 0.0), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic)),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _calculateBMI() {
    if (_weight <= 0 || _height <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select valid weight and height')),
      );
      return;
    }

    // Start Exit Slide Up Animation
    _exitController.forward();

    // After exit animation completes, calculate and navigate
    Future.delayed(const Duration(milliseconds: 550), () async {
      final heightInMeters = _height / 100;
      final bmi = _weight / (heightInMeters * heightInMeters);
      
      String category;
      if (bmi < 18.5) {
        category = 'Underweight';
      } else if (bmi < 25) {
        category = 'Normal';
      } else if (bmi < 30) {
        category = 'Overweight';
      } else {
        category = 'Obese';
      }

      final user = _auth.currentUser;
      if (user != null) {
        final record = BMIRecord(
          date: DateTime.now(),
          weight: _weight.toDouble(),
          height: _height.toDouble(),
          bmi: bmi,
          category: category,
        );
        await _userProfileRepository.addBMIRecord(user.uid, record);
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => ResultScreen(
              bmi: bmi,
              category: category,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? const Color(0xFF121212) : AppColors.white;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;

    // Slide transition for exit animation (sliding up by -1.5 of height)
    final exitSlide = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1.0)).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInOutCubic),
    );
    final exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeOut),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_doubleBackToExitPressedOnce) {
          SystemNavigator.pop();
          return;
        }
        _doubleBackToExitPressedOnce = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please click BACK again to exit'),
            duration: Duration(seconds: 2),
          ),
        );
        Future.delayed(const Duration(seconds: 2), () {
          _doubleBackToExitPressedOnce = false;
        });
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Top Toolbar
              FadeTransition(
                opacity: _titleOpacity,
                child: SlideTransition(
                  position: _titleSlide,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'BMI Calculator',
                          style: TextStyle(
                            fontFamily: 'Larsseit',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ProfileScreen()),
                            );
                          },
                          icon: const Icon(Icons.account_circle_outlined, size: 22, color: AppColors.primary),
                          label: const Text(
                            'Profile',
                            style: TextStyle(
                              fontFamily: 'Larsseit',
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Animated Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 10),
                        
                        // Panels container (Gender, Weight, Height)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Column (Gender & Weight)
                            Expanded(
                              child: Column(
                                children: [
                                  // Gender Card
                                  FadeTransition(
                                    opacity: _bodyOpacity,
                                    child: SlideTransition(
                                      position: _bodySlide,
                                      child: _buildInputCard(
                                        title: 'GENDER',
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                                            child: GenderWheelPicker(
                                              initialGender: _gender,
                                              onGenderChanged: (val) {
                                                setState(() {
                                                  _gender = val;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                        backgroundColor: cardBgColor,
                                        titleColor: textColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  // Weight Card
                                  FadeTransition(
                                    opacity: _weightOpacity,
                                    child: SlideTransition(
                                      position: _weightSlide,
                                      child: _buildInputCard(
                                        title: 'WEIGHT',
                                        unit: '(KG)',
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                                          child: WeightHorizontalPicker(
                                            initialWeight: _weight,
                                            onWeightChanged: (val) {
                                              setState(() {
                                                _weight = val;
                                              });
                                            },
                                          ),
                                        ),
                                        backgroundColor: cardBgColor,
                                        titleColor: textColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            // Right Column (Height)
                            Expanded(
                              child: FadeTransition(
                                opacity: _heightOpacity,
                                child: SlideTransition(
                                  position: _heightSlide,
                                  child: _buildInputCard(
                                    title: 'HEIGHT',
                                    unit: '(CM)',
                                    height: 395.0, // Match total height of left col approximately
                                    child: Expanded(
                                      child: Center(
                                        child: HeightWheelPicker(
                                          initialHeight: _height,
                                          onHeightChanged: (val) {
                                            setState(() {
                                              _height = val;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    backgroundColor: cardBgColor,
                                    titleColor: textColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 36),

                        // Swipe Start Button
                        FadeTransition(
                          opacity: _footerOpacity,
                          child: SlideTransition(
                            position: _footerSlide,
                            child: Column(
                              children: [
                                Center(
                                  child: CustomSwipeButton(
                                    onSwiped: _calculateBMI,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                
                                // Logout Button
                                Center(
                                  child: TextButton.icon(
                                    onPressed: _logout,
                                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                                    label: const Text(
                                      'Logout',
                                      style: TextStyle(
                                        fontFamily: 'Larsseit',
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required String title,
    String? unit,
    required Widget child,
    double? height,
    required Color backgroundColor,
    required Color titleColor,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Larsseit',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                  letterSpacing: 1.0,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontFamily: 'Larsseit',
                    fontSize: 8,
                    color: titleColor.withOpacity(0.5),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
