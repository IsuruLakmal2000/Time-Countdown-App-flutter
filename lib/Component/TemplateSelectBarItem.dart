import 'package:flutter/material.dart';

Widget TemplateSelectBarItem(BuildContext context, String title,
    String renderedWidgetName, Function onTap, bool isPro, bool isSelected) {
  const Color themePink = Color.fromARGB(255, 255, 0, 119);
  const Color themeMagenta = Color.fromARGB(255, 252, 6, 252);
  final Color selectedColor = isPro ? Colors.amber : themePink;
  final Color selectedBorderColor = isPro ? Colors.amber : themeMagenta;

  return InkWell(
    onTap: () async {
      // Allow selection of all templates - premium check will happen at save time
      onTap();
    },
    child: Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? selectedColor.withOpacity(0.16)
                      : (isPro
                          ? Colors.amber.withOpacity(0.1)
                          : Colors.transparent),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? selectedBorderColor.withOpacity(0.95)
                        : (isPro
                            ? Colors.amber.withOpacity(0.3)
                            : Colors.white.withOpacity(0.18)),
                    width: isSelected ? 1.4 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: (isPro ? Colors.amber : themeMagenta)
                                .withOpacity(0.35),
                            blurRadius: 10,
                            spreadRadius: 0.5,
                          ),
                        ]
                      : null,
                ),
                child: _TemplatePreview(
                  templateId: renderedWidgetName,
                  isPro: isPro || isSelected,
                ),
              ),
              if (isPro)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.amber, Colors.orange],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.workspace_premium,
                          color: Colors.white,
                          size: 10,
                        ),
                        SizedBox(width: 2),
                        Text(
                          'PRO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? selectedColor
                  : (isPro ? Colors.amber : Colors.white),
              fontWeight:
                  (isPro || isSelected) ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _TemplatePreview({required String templateId, required bool isPro}) {
  final Color color = isPro ? Colors.amber : Colors.white;

  switch (templateId) {
    case 'template_1':
      return SizedBox(
        width: 40,
        height: 40,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _numberBlock(width: 16, color: color.withOpacity(0.98), height: 6),
            const SizedBox(height: 3),
            _numberBlock(width: 18, color: color.withOpacity(0.95), height: 6),
            const SizedBox(height: 3),
            _numberBlock(width: 14, color: color.withOpacity(0.9), height: 5),
            const SizedBox(height: 3),
            _numberBlock(width: 12, color: color.withOpacity(0.85), height: 5),
          ],
        ),
      );
    case 'template_2':
      return SizedBox(
        width: 40,
        height: 40,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _numberBlock(width: 13, color: color.withOpacity(0.98), height: 8),
            const SizedBox(height: 6),
            SizedBox(
              width: 32,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _numberBlock(width: 8, color: color.withOpacity(0.94), height: 5),
                  _numberBlock(width: 9, color: color.withOpacity(0.9), height: 5),
                  _numberBlock(width: 9, color: color.withOpacity(0.86), height: 5),
                ],
              ),
            ),
          ],
        ),
      );
    case 'template_3':
      return _triangleThreePreview(color: color);
    case 'template_4':
      return _gridTwoByTwoPreview(color: color);
    case 'template_7':
      return _splitRowsPreview(color: color, withCenterMarker: true);
    case 'template_8':
      return _splitRowsPreview(color: color, withCenterMarker: true);
    case 'template_9':
      return _splitRowsPreview(color: color, withCenterMarker: true);
    default:
      return SizedBox(
        width: 40,
        height: 40,
        child: Center(
          child: _previewLine(width: 28, color: color, height: 8),
        ),
      );
  }
}

Widget _gridTwoByTwoPreview({required Color color}) {
  return SizedBox(
    width: 40,
    height: 40,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 32,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _numberBlock(width: 12, color: color.withOpacity(0.96), height: 7),
              _numberBlock(width: 12, color: color.withOpacity(0.96), height: 7),
            ],
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: 32,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _numberBlock(width: 12, color: color.withOpacity(0.88), height: 7),
              _numberBlock(width: 12, color: color.withOpacity(0.88), height: 7),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _triangleThreePreview({required Color color}) {
  return SizedBox(
    width: 40,
    height: 40,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _numberBlock(width: 12, color: color.withOpacity(0.96), height: 7),
        const SizedBox(height: 5),
        SizedBox(
          width: 28,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _numberBlock(width: 12, color: color.withOpacity(0.88), height: 7),
              _numberBlock(width: 12, color: color.withOpacity(0.88), height: 7),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _splitRowsPreview({required Color color, required bool withCenterMarker}) {
  return SizedBox(
    width: 40,
    height: 40,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 32,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _numberBlock(width: 12, color: color.withOpacity(0.96), height: 7),
              _numberBlock(width: 12, color: color.withOpacity(0.96), height: 7),
            ],
          ),
        ),
        const SizedBox(height: 4),
        if (withCenterMarker) ...[
          _previewDot(color: color.withOpacity(0.95), size: 5),
          const SizedBox(height: 4),
        ],
        SizedBox(
          width: 32,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _numberBlock(width: 12, color: color.withOpacity(0.88), height: 7),
              _numberBlock(width: 12, color: color.withOpacity(0.88), height: 7),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _numberBlock({
  required double width,
  required Color color,
  double height = 6,
}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(3),
    ),
  );
}

Widget _previewLine({
  required double width,
  required Color color,
  double height = 4,
}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(3),
    ),
  );
}

Widget _previewDot({required Color color, double size = 6}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
    ),
  );
}
