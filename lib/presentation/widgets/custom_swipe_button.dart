import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/constants/app_colors.dart';

class CustomSwipeButton extends StatefulWidget {
  final double width;
  final double height;
  final VoidCallback onSwiped;

  const CustomSwipeButton({
    Key? key,
    this.width = 240.0,
    this.height = 70.0,
    required this.onSwiped,
  }) : super(key: key);

  @override
  State<CustomSwipeButton> createState() => _CustomSwipeButtonState();
}

class _CustomSwipeButtonState extends State<CustomSwipeButton> with SingleTickerProviderStateMixin {
  double _dragPosition = 0.0;
  bool _isSwiped = false;
  late AnimationController _resetController;
  late Animation<double> _resetAnimation;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _resetAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(_resetController);
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details, double maxDrag) {
    if (_isSwiped) return;
    setState(() {
      _dragPosition += details.delta.dx;
      if (_dragPosition < 0) _dragPosition = 0;
      if (_dragPosition > maxDrag) _dragPosition = maxDrag;
    });
  }

  void _onDragEnd(DragEndDetails details, double maxDrag) {
    if (_isSwiped) return;
    if (_dragPosition >= maxDrag * 0.9) {
      // Trigger swipe action
      setState(() {
        _dragPosition = maxDrag;
        _isSwiped = true;
      });
      widget.onSwiped();
      // Auto-reset after a short delay so the button can be used again next time
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          reset();
        }
      });
    } else {
      // Snap back
      _resetAnimation = Tween<double>(
        begin: _dragPosition,
        end: 0.0,
      ).animate(
        CurvedAnimation(parent: _resetController, curve: Curves.easeOutBack),
      )..addListener(() {
          setState(() {
            _dragPosition = _resetAnimation.value;
          });
        });
      _resetController.forward(from: 0.0);
    }
  }

  void reset() {
    setState(() {
      _isSwiped = false;
      _dragPosition = 0.0;
    });
    _resetController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Color(0xFF151515) : AppColors.white;
    final trackColor = isDark ? Color(0xFF202020) : AppColors.lightBackgroundAdditional;

    final double thumbSize = widget.height - 12.0; // Margin around thumb
    final double maxDrag = widget.width - thumbSize - 12.0;
    final double progress = maxDrag > 0 ? (_dragPosition / maxDrag) : 0.0;

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(widget.height / 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6.0),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Inner Track text or dots
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Opacity(
                opacity: (1.0 - progress).clamp(0.0, 1.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(4, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      width: 6.0,
                      height: 6.0,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
          
          // Slider background filling as we swipe
          Container(
            width: _dragPosition + thumbSize,
            height: widget.height - 12.0,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(widget.height / 2),
            ),
          ),

          // Draggable Thumb
          Positioned(
            left: _dragPosition,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) => _onDragUpdate(details, maxDrag),
              onHorizontalDragEnd: (details) => _onDragEnd(details, maxDrag),
              child: Container(
                width: thumbSize,
                height: thumbSize,
                decoration: BoxDecoration(
                  color: trackColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: CustomPaint(
                    size: Size(thumbSize * 0.6, thumbSize * 0.6),
                    painter: PacmanPainter(
                      progress: progress,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PacmanPainter extends CustomPainter {
  final double progress;
  final Color color;

  PacmanPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Calculate mouth opening angle based on progress (cycles back and forth as dragged)
    // 0.0 to 0.7 radians (approx 0 to 40 degrees)
    final double cycle = math.sin(progress * 4 * math.pi).abs();
    final double mouthAngle = 0.15 + (0.5 * cycle);

    // Draw Pacman body (circle sector leaving the mouth open)
    // 0 degrees is to the right in Flutter (math.pi * 2)
    final double startAngle = mouthAngle;
    final double sweepAngle = 2 * math.pi - (2 * mouthAngle);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      true,
      paint,
    );

    // Draw Pacman Eye
    final Paint eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Eye position is shifted up and slightly forward
    final Offset eyeCenter = Offset(
      center.dx + (radius * 0.1),
      center.dy - (radius * 0.4),
    );
    canvas.drawCircle(eyeCenter, radius * 0.15, eyePaint);
  }

  @override
  bool shouldRepaint(covariant PacmanPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
