import 'package:adb_file_explorer/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class Shimmered extends StatelessWidget {
  const Shimmered({
    super.key,
    required this.color,
    this.borderRadius = 5.0,
    this.width,
    this.height,
    this.margin,
    this.baseColor,
    this.highlightColor,
  });

  final double? width;
  final double? height;
  final Color color;
  final Color? baseColor;
  final Color? highlightColor;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? context.colorScheme.surfaceContainerHighest,
      highlightColor: highlightColor ?? context.colorScheme.surfaceContainerHigh,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: color,
        ),
      ),
    );
  }
}