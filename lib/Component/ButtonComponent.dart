import 'package:flutter/material.dart';
import 'package:timecountdown/Theme/AppColors.dart';

class Buttoncomponent extends StatefulWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final bool isOutlined;

  const Buttoncomponent({
    super.key,
    required this.onPressed,
    required this.buttonText,
    this.isOutlined = false,
  });

  @override
  State<Buttoncomponent> createState() => _ButtoncomponentState();
}

class _ButtoncomponentState extends State<Buttoncomponent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: widget.isOutlined ? null : AppColors.accentGradient,
            borderRadius: AppRadius.mdAll,
            border: widget.isOutlined
                ? Border.all(color: AppColors.accentPrimary, width: 2)
                : null,
            boxShadow: widget.isOutlined ? null : AppColors.buttonShadow,
          ),
          child: Center(
            child: Text(
              widget.buttonText,
              style: TextStyle(
                color:
                    widget.isOutlined ? AppColors.accentPrimary : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Helper for animated builder (reused from OnboardingScreen)
class AnimatedBuilder extends StatelessWidget {
  final Animation<double> animation;
  final Widget Function(BuildContext, Widget?) builder;
  final Widget? child;

  const AnimatedBuilder({
    Key? key,
    required this.animation,
    required this.builder,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _AnimatedBuilderWidget(
      animation: animation,
      builder: builder,
      child: child,
    );
  }
}

class _AnimatedBuilderWidget extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;
  final Widget? child;

  const _AnimatedBuilderWidget({
    Key? key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
