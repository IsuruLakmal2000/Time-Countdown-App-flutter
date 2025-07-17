import 'package:flutter/material.dart';

class PageIndicatorComponent extends StatelessWidget {
  final int currentPage;
  final int itemCount;
  final Color activeColor;
  final Color inactiveColor;
  final double dotSize;
  final double spacing;
  const PageIndicatorComponent({
    Key? key,
    required this.currentPage,
    required this.itemCount,
    this.activeColor = Colors.white,
    this.inactiveColor = Colors.grey,
    this.dotSize = 8.0,
    this.spacing = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (itemCount <= 1) {
      return Container(); // Don't show indicator if there's only one item or none
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...List.generate(
            itemCount,
            (index) => AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: spacing / 2),
              height: dotSize,
              width: currentPage == index ? dotSize * 1.8 : dotSize,
              decoration: BoxDecoration(
                color: currentPage == index ? activeColor : inactiveColor,
                borderRadius: BorderRadius.circular(dotSize / 2),
                boxShadow: currentPage == index
                    ? [
                        BoxShadow(
                          color: activeColor.withOpacity(0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
