import 'package:flutter/material.dart';

class ResponsiveCountdownLayout {
  /// Creates a responsive horizontal layout that automatically adjusts spacing and alignment
  /// based on the number of visible countdown elements
  static Widget buildResponsiveRow({
    required List<Widget> children,
    double spacing = 16.0,
    MainAxisAlignment? forceAlignment,
  }) {
    // Filter out empty containers and null widgets
    final visibleChildren = children
        .where((child) {
          if (child is Container) {
            return child.child != null;
          }
          return true;
        })
        .toList();

    if (visibleChildren.isEmpty) {
      return Container();
    }

    // For single element, center it
    if (visibleChildren.length == 1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: visibleChildren,
      );
    }

    // Use forced alignment if provided, otherwise use spaceEvenly for multiple items
    MainAxisAlignment alignment = forceAlignment ?? MainAxisAlignment.spaceEvenly;
    
    return Row(
      mainAxisAlignment: alignment,
      children: visibleChildren,
    );
  }

  /// Creates a responsive wrap layout for countdown elements that can wrap to multiple lines
  static Widget buildResponsiveWrap({
    required List<Widget> children,
    double spacing = 16.0,
    double runSpacing = 16.0,
    WrapAlignment alignment = WrapAlignment.center,
  }) {
    final visibleChildren = children
        .where((child) {
          if (child is Container) {
            return child.child != null;
          }
          return true;
        })
        .toList();

    if (visibleChildren.isEmpty) {
      return Container();
    }

    return Wrap(
      alignment: alignment,
      spacing: spacing,
      runSpacing: runSpacing,
      children: visibleChildren,
    );
  }

  /// Creates a responsive column layout with proper spacing
  static Widget buildResponsiveColumn({
    required List<Widget> children,
    double spacing = 8.0,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  }) {
    final visibleChildren = children
        .where((child) => child is! Container || 
                (child as Container).child != null)
        .toList();

    if (visibleChildren.isEmpty) {
      return Container();
    }

    // Add spacing between children
    final spacedChildren = <Widget>[];
    for (int i = 0; i < visibleChildren.length; i++) {
      spacedChildren.add(visibleChildren[i]);
      if (i < visibleChildren.length - 1) {
        spacedChildren.add(SizedBox(height: spacing));
      }
    }

    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: spacedChildren,
    );
  }

  /// Creates countdown element widget (for Template2 style with number and label)
  static Widget buildCountdownElement({
    required int value,
    required String label,
    required TextStyle numberStyle,
    required TextStyle labelStyle,
    bool showIfZero = false,
  }) {
    if (value == 0 && !showIfZero) {
      return Container();
    }

    return Column(
      children: [
        Text(
          '$value',
          style: numberStyle,
        ),
        Text(
          label,
          style: labelStyle,
        ),
      ],
    );
  }

  /// Creates countdown text widget (for Template1 style with combined text)
  static Widget buildCountdownText({
    required int value,
    required String unit,
    required TextStyle style,
    bool showIfZero = false,
    Matrix4? transform,
  }) {
    if (value == 0 && !showIfZero) {
      return Container();
    }

    Widget textWidget = Text(
      '$value $unit',
      style: style,
    );

    if (transform != null) {
      return Transform(
        transform: transform,
        child: textWidget,
      );
    }

    return textWidget;
  }

  /// Builds a grid layout that adjusts columns based on visible children count
  static Widget buildResponsiveGrid({
    required List<Widget> children,
    double spacing = 16.0,
    double runSpacing = 16.0,
    int maxColumns = 3,
  }) {
    final visibleChildren = children
        .where((child) => child is! Container || 
                (child as Container).child != null)
        .toList();

    if (visibleChildren.isEmpty) {
      return Container();
    }

    // Determine optimal column count based on visible children
    int columns = visibleChildren.length > maxColumns ? maxColumns : visibleChildren.length;
    
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: columns,
      mainAxisSpacing: runSpacing,
      crossAxisSpacing: spacing,
      children: visibleChildren,
    );
  }

  /// Checks if a countdown value should be displayed
  static bool shouldShow(int value, {bool alwaysShowSeconds = true}) {
    if (alwaysShowSeconds && value >= 0) return true;
    return value != 0;
  }
}
