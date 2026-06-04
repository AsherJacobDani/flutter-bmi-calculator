import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class HeightWheelPicker extends StatefulWidget {
  final int minHeight;
  final int maxHeight;
  final int initialHeight;
  final ValueChanged<int> onHeightChanged;

  const HeightWheelPicker({
    Key? key,
    this.minHeight = 1,
    this.maxHeight = 200,
    this.initialHeight = 160,
    required this.onHeightChanged,
  }) : super(key: key);

  @override
  State<HeightWheelPicker> createState() => _HeightWheelPickerState();
}

class _HeightWheelPickerState extends State<HeightWheelPicker> {
  late FixedExtentScrollController _scrollController;
  late int _selectedHeight;
  
  // Total number of actual items
  int get _itemCount => widget.maxHeight - widget.minHeight + 1;

  @override
  void initState() {
    super.initState();
    _selectedHeight = widget.initialHeight;
    // Map initialHeight to index
    final initialIndex = widget.initialHeight - widget.minHeight;
    _scrollController = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final overlayColor = AppColors.primary.withOpacity(0.08);

    return SizedBox(
      height: 300,
      width: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Middle selected line overlay
          Container(
            height: 48,
            width: 100,
            decoration: BoxDecoration(
              color: overlayColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 1.5,
              ),
            ),
          ),
          
          // Wheel scroll view
          ListWheelScrollView.useDelegate(
            controller: _scrollController,
            itemExtent: 44,
            physics: const FixedExtentScrollPhysics(),
            perspective: 0.007,
            diameterRatio: 1.5,
            onSelectedItemChanged: (index) {
              // Map index back to height
              final newHeight = widget.minHeight + (index % _itemCount);
              setState(() {
                _selectedHeight = newHeight;
              });
              widget.onHeightChanged(newHeight);
            },
            childDelegate: ListWheelChildLoopingListDelegate(
              children: List.generate(_itemCount, (index) {
                final heightVal = widget.minHeight + index;
                final isSelected = heightVal == _selectedHeight;
                return Center(
                  child: Text(
                    heightVal.toString(),
                    style: TextStyle(
                      fontFamily: 'Larsseit',
                      color: isSelected ? AppColors.primary : textColor.withOpacity(0.5),
                      fontSize: isSelected ? 22 : 17,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
