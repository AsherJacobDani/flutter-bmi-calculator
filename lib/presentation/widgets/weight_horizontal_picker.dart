import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class WeightHorizontalPicker extends StatefulWidget {
  final int minWeight;
  final int maxWeight;
  final int initialWeight;
  final ValueChanged<int> onWeightChanged;

  const WeightHorizontalPicker({
    Key? key,
    this.minWeight = 0,
    this.maxWeight = 150,
    this.initialWeight = 50,
    required this.onWeightChanged,
  }) : super(key: key);

  @override
  State<WeightHorizontalPicker> createState() => _WeightHorizontalPickerState();
}

class _WeightHorizontalPickerState extends State<WeightHorizontalPicker> {
  late ScrollController _scrollController;
  late int _selectedWeight;
  
  // Width of each tick interval in pixels
  final double _tickSpacing = 16.0;
  
  // To avoid circular updates
  bool _isManualScrolling = false;

  @override
  void initState() {
    super.initState();
    _selectedWeight = widget.initialWeight;
    
    // We will initialize the scroll position in postFrameCallback once layout is done
    // to calculate the exact offset to center the initial weight
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToWeight(widget.initialWeight, animate: false);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToWeight(int weight, {bool animate = true}) {
    if (!_scrollController.hasClients) return;
    
    // Offset calculation:
    // The selected tick index is (weight - minWeight)
    // Position of that tick from the start of the list = index * tickSpacing
    // To center it, we subtract half of the viewport width
    final index = weight - widget.minWeight;
    final viewportWidth = _scrollController.position.viewportDimension;
    final targetOffset = (index * _tickSpacing) - (viewportWidth / 2);
    
    _isManualScrolling = true;
    if (animate) {
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      ).then((_) => _isManualScrolling = false);
    } else {
      _scrollController.jumpTo(targetOffset);
      _isManualScrolling = false;
    }
  }

  void _onScroll(double offset, double viewportWidth) {
    if (_isManualScrolling) return;

    // Map offset back to centered weight
    // offset + viewportWidth / 2 = centered position in the content list
    final centeredPosition = offset + (viewportWidth / 2);
    final rawIndex = centeredPosition / _tickSpacing;
    int index = rawIndex.round();
    
    // Clamp index
    final maxIndex = widget.maxWeight - widget.minWeight;
    if (index < 0) index = 0;
    if (index > maxIndex) index = maxIndex;
    
    final newWeight = widget.minWeight + index;
    if (newWeight != _selectedWeight) {
      setState(() {
        _selectedWeight = newWeight;
      });
      widget.onWeightChanged(newWeight);
    }
  }

  void _snapToNearest(double offset, double viewportWidth) {
    final centeredPosition = offset + (viewportWidth / 2);
    final rawIndex = centeredPosition / _tickSpacing;
    final index = rawIndex.round().clamp(0, widget.maxWeight - widget.minWeight);
    final snappedWeight = widget.minWeight + index;
    
    _scrollToWeight(snappedWeight);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tickColor = isDark ? Colors.white38 : Colors.black38;
    final numberColor = isDark ? AppColors.darkText : AppColors.lightText;
    
    final totalTicks = widget.maxWeight - widget.minWeight + 1;

    return Column(
      children: [
        // Display selected weight text
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$_selectedWeight',
              style: TextStyle(
                fontFamily: 'Larsseit',
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'kg',
              style: TextStyle(
                fontFamily: 'Larsseit',
                fontSize: 14,
                color: isDark ? AppColors.darkTextAdditional : AppColors.lightTextAdditional,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Ruler Viewport
        SizedBox(
          height: 90,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final viewportWidth = constraints.maxWidth;
              // Padding at start and end of scroll list so the first and last ticks can be centered
              final sidePadding = viewportWidth / 2;

              return Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Ruler scroll listener and builder
                  NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollUpdateNotification) {
                        _onScroll(_scrollController.offset, viewportWidth);
                      } else if (notification is ScrollEndNotification) {
                        _snapToNearest(_scrollController.offset, viewportWidth);
                      }
                      return true;
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: totalTicks,
                      physics: const ClampingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final weightVal = widget.minWeight + index;
                        final isMajor = weightVal % 10 == 0;
                        final isMedium = weightVal % 5 == 0;

                        Widget tickLine = Container(
                          width: 1.5,
                          height: isMajor ? 32.0 : (isMedium ? 22.0 : 12.0),
                          color: isMajor ? AppColors.primary : tickColor,
                        );

                        Widget itemChild = Column(
                          children: [
                            tickLine,
                            const SizedBox(height: 8),
                            if (isMajor)
                              Text(
                                '$weightVal',
                                style: TextStyle(
                                  fontFamily: 'Larsseit',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: numberColor.withOpacity(0.8),
                                ),
                              )
                            else
                              const SizedBox(height: 14),
                          ],
                        );

                        // If it's the first or last item, we add padding to allow centering
                        double leftMarg = index == 0 ? sidePadding : 0;
                        double rightMarg = index == totalTicks - 1 ? sidePadding : 0;

                        return Container(
                          margin: EdgeInsets.only(
                            left: leftMarg,
                            right: rightMarg,
                          ),
                          width: _tickSpacing,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: itemChild,
                          ),
                        );
                      },
                    ),
                  ),

                  // Center Triangle Indicator
                  Positioned(
                    top: 40,
                    child: CustomPaint(
                      size: const Size(18, 12),
                      painter: TriangleIndicatorPainter(color: AppColors.primary),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class TriangleIndicatorPainter extends CustomPainter {
  final Color color;

  TriangleIndicatorPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height) // bottom-left
      ..lineTo(size.width / 2, 0) // top-middle (pointing up)
      ..lineTo(size.width, size.height) // bottom-right
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
