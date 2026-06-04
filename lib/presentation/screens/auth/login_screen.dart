import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_screen.dart';
import '../main/main_screen.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/repositories/user_profile_repository.dart';
import '../../../core/constants/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _userProfileRepository = UserProfileRepository();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Use display name set during registration, fallback to email prefix
        final name = (user.displayName != null && user.displayName!.isNotEmpty)
            ? user.displayName!
            : email.split('@')[0];

        UserProfile? existingProfile = await _userProfileRepository.getUserProfile();
        if (existingProfile == null || existingProfile.userId != user.uid) {
          final userProfile = UserProfile(
            userId: user.uid,
            name: name,
            email: user.email ?? email,
            bmiHistory: [],
          );
          await _userProfileRepository.saveUserProfile(userProfile);
        } else if (existingProfile.name.isEmpty ||
            existingProfile.name == existingProfile.email.split('@')[0]) {
          // Update name if it was never properly set
          final updated = existingProfile.copyWith(name: name);
          await _userProfileRepository.saveUserProfile(updated);
        }

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.message}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.darkText : AppColors.lightText;
    final hintColor = isDark ? Colors.white30 : Colors.black38;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.favorite_rounded,
                  size: 80,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'BMI Calculator',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Larsseit',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to calculate and track your BMI history',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Larsseit',
                    fontSize: 14,
                    color: titleColor.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                    fontFamily: 'Larsseit',
                  ),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(color: hintColor, fontFamily: 'Larsseit'),
                    prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: TextStyle(
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                    fontFamily: 'Larsseit',
                  ),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(color: hintColor, fontFamily: 'Larsseit'),
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _loginUser,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Sign In',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Larsseit'),
                        ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: Text(
                    "Don't have an account? Register here",
                    style: TextStyle(
                      fontFamily: 'Larsseit',
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
