import 'package:flutter/material.dart';

import '../../core/theme/app_radii.dart';

/// White surface with soft elevation — card-based layouts.
class AppSurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double elevation;

  const AppSurfaceCard({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.onTap,
    this.elevation = 1,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadii.md);

    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: elevation,
      shadowColor: const Color(0x140F172A),
      surfaceTintColor: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
