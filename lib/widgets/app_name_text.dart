import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'title_text.dart';

class AppNameTextWidget extends StatelessWidget {
  const AppNameTextWidget({super.key, this.fontSize = 30});
  final double fontSize;
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        period: const Duration(seconds: 4),
        baseColor: const Color(0xFFF7EEDD),
        highlightColor: const Color(0xFF008DDA),
        child: TitlesTextWidget(
          label: "Peach Sneaker",
          fontSize: fontSize,
        )
    );
  }
}