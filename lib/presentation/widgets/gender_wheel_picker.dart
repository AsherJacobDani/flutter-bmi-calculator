import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/constants/app_colors.dart';

class GenderWheelPicker extends StatefulWidget {
  final ValueChanged<String> onGenderChanged;
  final String initialGender;

  const GenderWheelPicker({
    Key? key,
    required this.onGenderChanged,
    this.initialGender = 'M',
  }) : super(key: key);

  @override
  State<GenderWheelPicker> createState() => _GenderWheelPickerState();
}

class _GenderWheelPickerState extends State<GenderWheelPicker> {
  late String _selectedGender;

  // Angles in radians for each option when selected (rotated to top anchor, 270 deg / -pi/2)
  // Let's rotate the ring so the active item aligns at the top.
  // F is at -30 deg, O is at 0 deg, M is at +30 deg relative to top
  double get _targetRotation {
    switch (_selectedGender) {
      case 'F':
        return 0.45; // rotate clockwise to bring F to center
      case 'O':
        return 0.0;  // already centered
      case 'M':
        return -0.45; // rotate counter-clockwise to bring M to center
      default:
        return 0.0;
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.initialGender;
  }

  void _selectGender(String gender) {
    if (_selectedGender == gender) return;
    setState(() {
      _selectedGender = gender;
    });
    widget.onGenderChanged(gender);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialBgColor = isDark ? Color(0xFF181818) : AppColors.lightBackgroundAdditional2;
    final itemTextColor = isDark ? AppColors.darkText : AppColors.lightText;

    return SizedBox(
      width: 170,
      height: 170,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Dial Ring
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: dialBgColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),

          // Arc track indicator (visual highlight on the top selection area)
          Positioned(
            top: 2,
            child: Container(
              width: 50,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(3)),
              ),
            ),
          ),

          // Rotating Dial Options
          AnimatedRotation(
            turns: _targetRotation / (2 * math.pi),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            child: Stack(
              children: [
                // "F" Option (Top-Left)
                Positioned(
                  left: 28,
                  top: 28,
                  child: _buildDialItem('F', itemTextColor),
                ),
                // "O" Option (Top-Center)
                Positioned(
                  left: 65,
                  top: 10,
                  child: _buildDialItem('O', itemTextColor),
                ),
                // "M" Option (Top-Right)
                Positioned(
                  right: 28,
                  top: 28,
                  child: _buildDialItem('M', itemTextColor),
                ),
              ],
            ),
          ),

          // Central Button / User Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialItem(String gender, Color normalColor) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () => _selectGender(gender),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          gender,
          style: TextStyle(
            color: isSelected ? Colors.white : normalColor.withOpacity(0.6),
            fontSize: 18,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
