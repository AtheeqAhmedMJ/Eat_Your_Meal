import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? tint;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(16),
    this.tint,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        splashColor: AppTheme.primary.withAlphaPercent(0.08),
        highlightColor: Colors.transparent,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: (tint ?? Colors.white).withAlphaPercent(0.72),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.white.withAlphaPercent(0.6), width: 1.5),
            boxShadow: [
              BoxShadow(color: Colors.white.withAlphaPercent(0.5), blurRadius: 10, offset: const Offset(-3, -3)),
              BoxShadow(color: AppTheme.primary.withAlphaPercent(0.07), blurRadius: 18, offset: const Offset(6, 6)),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
