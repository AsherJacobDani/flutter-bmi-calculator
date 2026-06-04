import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/models/bmi_record.dart';
import '../../../data/repositories/user_profile_repository.dart';
import '../../../core/constants/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userProfileRepository = UserProfileRepository();
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _userProfileRepository.getUserProfile();
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'underweight':
        return Colors.blue;
      case 'normal':
      case 'healthy':
        return Colors.green;
      case 'overweight':
        return Colors.orange;
      case 'obese':
      case 'obesity':
        return Colors.red;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final secondaryTextColor = isDark ? AppColors.darkTextAdditional : AppColors.lightTextAdditional;
    final cardBgColor = isDark ? const Color(0xFF121212) : AppColors.white;

    final displayName = _userProfile?.name.isNotEmpty == true
        ? _userProfile!.name.split(' ').first
        : 'User';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isLoading ? 'Profile' : 'Hey, $displayName 👋',
          style: const TextStyle(fontFamily: 'Larsseit', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userProfile == null
              ? const Center(
                  child: Text(
                    'No profile found.',
                    style: TextStyle(fontFamily: 'Larsseit', fontSize: 18),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // User Info Card
                      Container(
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: AppColors.primary,
                              child: Text(
                                _userProfile!.name.isNotEmpty
                                    ? _userProfile!.name[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Larsseit',
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _userProfile!.name,
                                    style: TextStyle(
                                      fontFamily: 'Larsseit',
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _userProfile!.email,
                                    style: TextStyle(
                                      fontFamily: 'Larsseit',
                                      fontSize: 14,
                                      color: secondaryTextColor.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // History Header
                      Text(
                        'BMI History',
                        style: TextStyle(
                          fontFamily: 'Larsseit',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // History List
                      Expanded(
                        child: _userProfile!.bmiHistory.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.history,
                                      size: 64,
                                      color: secondaryTextColor.withOpacity(0.3),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No BMI history available',
                                      style: TextStyle(
                                        fontFamily: 'Larsseit',
                                        fontSize: 16,
                                        color: secondaryTextColor.withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: _userProfile!.bmiHistory.length,
                                itemBuilder: (context, index) {
                                  // Sort history by date descending
                                  final sortedHistory = List<BMIRecord>.from(_userProfile!.bmiHistory)
                                    ..sort((a, b) => b.date.compareTo(a.date));
                                  final record = sortedHistory[index];
                                  final dateStr = DateFormat('MMM dd, yyyy').format(record.date);
                                  final color = _getCategoryColor(record.category);

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: cardBgColor,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.02),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Row(
                                        children: [
                                          // Left Indicator bar
                                          Container(
                                            width: 6,
                                            height: 90,
                                            color: color,
                                          ),
                                          const SizedBox(width: 14),

                                          // Content
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        dateStr,
                                                        style: TextStyle(
                                                          fontFamily: 'Larsseit',
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.bold,
                                                          color: textColor,
                                                        ),
                                                      ),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                        decoration: BoxDecoration(
                                                          color: color.withOpacity(0.12),
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        child: Text(
                                                          record.category,
                                                          style: TextStyle(
                                                            fontFamily: 'Larsseit',
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.bold,
                                                            color: color,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      _buildHistoryStat(
                                                        label: 'BMI',
                                                        value: record.bmi.toStringAsFixed(1),
                                                        valueColor: textColor,
                                                      ),
                                                      _buildHistoryStat(
                                                        label: 'Weight',
                                                        value: '${record.weight.toStringAsFixed(1)} kg',
                                                        valueColor: secondaryTextColor,
                                                      ),
                                                      _buildHistoryStat(
                                                        label: 'Height',
                                                        value: '${record.height.toStringAsFixed(0)} cm',
                                                        valueColor: secondaryTextColor,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                        ],
                                      ),
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

  Widget _buildHistoryStat({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Larsseit',
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Larsseit',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
