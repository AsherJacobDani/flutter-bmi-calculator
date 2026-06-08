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

class _GenderWheelPickerState extends State<GenderWheelPicker>
    with SingleTickerProviderStateMixin {
  late String _selectedGender;
  double _rotationAngle = 0.0; // In radians
  double _startAngle = 0.0;
  double _startRotation = 0.0;

  late AnimationController _snapController;
  late Animation<double> _snapAnimation;

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.initialGender;
    _rotationAngle = _getTargetAngleForGender(_selectedGender);
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  // Returns the canonical angle for each gender selection
  // O is at 0 rad (top)
  // M is at 120 deg (bottom right) -> rotates to top, so target is -120 deg
  // F is at 240 deg (bottom left) -> rotates to top, so target is +120 deg
  double _getTargetAngleForGender(String gender) {
    switch (gender) {
      case 'O':
        return 0.0;
      case 'M':
        return -2 * math.pi / 3;
      case 'F':
        return 2 * math.pi / 3;
      default:
        return 0.0;
    }
  }

  // Determines the closest gender based on the current rotation angle
  String _getGenderForAngle(double angle) {
    final normalized = _normalizeAngle(angle);
    final diffO = (normalized - 0.0).abs();
    final diffM = _angleDistance(normalized, -2 * math.pi / 3);
    final diffF = _angleDistance(normalized, 2 * math.pi / 3);

    if (diffO <= diffM && diffO <= diffF) {
      return 'O';
    } else if (diffM <= diffF) {
      return 'M';
    } else {
      return 'F';
    }
  }

  double _normalizeAngle(double angle) {
    double a = angle % (2 * math.pi);
    if (a > math.pi) {
      a -= 2 * math.pi;
    } else if (a < -math.pi) {
      a += 2 * math.pi;
    }
    return a;
  }

  double _angleDistance(double a, double b) {
    final diff = (a - b).abs() % (2 * math.pi);
    return diff > math.pi ? 2 * math.pi - diff : diff;
  }

  void _onPanStart(DragStartDetails details) {
    _snapController.stop();
    // Center is Offset(175/2, 175/2)
    const center = Offset(87.5, 87.5);
    final localPos = details.localPosition;
    final dx = localPos.dx - center.dx;
    final dy = localPos.dy - center.dy;
    _startAngle = math.atan2(dy, dx);
    _startRotation = _rotationAngle;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    const center = Offset(87.5, 87.5);
    final localPos = details.localPosition;
    final dx = localPos.dx - center.dx;
    final dy = localPos.dy - center.dy;
    final currentAngle = math.atan2(dy, dx);
    final deltaAngle = currentAngle - _startAngle;
    setState(() {
      _rotationAngle = _startRotation + deltaAngle;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final targetGender = _getGenderForAngle(_rotationAngle);
    final targetAngle = _getTargetAngleForGender(targetGender);

    // Shortest-path snapping animation
    final diff = _normalizeAngle(targetAngle - _rotationAngle);
    final start = _rotationAngle;
    final end = _rotationAngle + diff;

    _snapAnimation = Tween<double>(begin: start, end: end).animate(
      CurvedAnimation(parent: _snapController, curve: Curves.easeOutBack),
    )..addListener(() {
        setState(() {
          _rotationAngle = _snapAnimation.value;
        });
      });

    _snapController.reset();
    _snapController.forward().then((_) {
      setState(() {
        _selectedGender = targetGender;
        _rotationAngle = _normalizeAngle(targetAngle);
      });
      widget.onGenderChanged(targetGender);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialBgColor =
        isDark ? const Color(0xFF181818) : AppColors.lightBackgroundAdditional2;
    final itemTextColor = isDark ? AppColors.darkText : AppColors.lightText;
    final lineColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.06);

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 175,
        height: 175,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Rotating Wheel Circle
            Transform.rotate(
              angle: _rotationAngle,
              child: Container(
                width: 165,
                height: 165,
                decoration: BoxDecoration(
                  color: dialBgColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.15),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Splits / Dividers
                    Positioned.fill(
                      child: CustomPaint(
                        painter: WheelPartitionPainter(lineColor: lineColor),
                      ),
                    ),

                    // Label 'O' inside the sector (Top Center) — counter-rotated
                    _buildPositionedLabel('O', 0.0, itemTextColor),

                    // Label 'M' inside the sector (Bottom Right) — counter-rotated
                    _buildPositionedLabel('M', 2 * math.pi / 3, itemTextColor),

                    // Label 'F' inside the sector (Bottom Left) — counter-rotated
                    _buildPositionedLabel('F', 4 * math.pi / 3, itemTextColor),
                  ],
                ),
              ),
            ),

            // Top Pointer Indicator (Stationary)
            Positioned(
              top: 1,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Central Station Hub — gender symbol icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.transgender,
                color: Colors.white,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionedLabel(String label, double angle, Color color) {
    // Radius of text offset from center
    const double radius = 50.0;
    final dx = radius * math.sin(angle);
    final dy = -radius * math.cos(angle);

    final isSelected = _selectedGender == label;

    return Transform.translate(
      offset: Offset(dx, dy),
      // Counter-rotate by -_rotationAngle so the text stays upright
      child: Transform.rotate(
        angle: -_rotationAngle,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Larsseit',
            color: isSelected ? AppColors.primary : color.withOpacity(0.55),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class WheelPartitionPainter extends CustomPainter {
  final Color lineColor;

  WheelPartitionPainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // dividers at 60, 180, 300 degrees
    final angles = [
      -math.pi / 6,
      math.pi / 2,
      7 * math.pi / 6,
    ];

    for (final angle in angles) {
      final endPoint = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(center, endPoint, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
