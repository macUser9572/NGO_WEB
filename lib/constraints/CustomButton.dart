import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ngo_web/constraints/all_colors.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool outlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsets? padding;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.outlined = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 48,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w600,
    this.padding, SizedBox? child,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AllColors.fifthColor;
    final fg = textColor ?? AllColors.secondaryColor;

    final child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: outlined ? bg : fg,
            ),
          )
        : Text(
            label,
            style: GoogleFonts.inter(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: outlined ? bg : fg,
            ),
          );

    final shapeDecoration = const RoundedRectangleBorder(
      borderRadius: BorderRadius.zero, // 🔥 ALWAYS SQUARE
    );

    final effectivePadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 12);

    Widget button = outlined
        ? OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: bg),
              shape: shapeDecoration,
              padding: effectivePadding,
            ),
            onPressed: isLoading ? null : onPressed,
            child: child,
          )
        : ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: bg,
              elevation: 0,
              shape: shapeDecoration,
              padding: effectivePadding,
            ),
            onPressed: isLoading ? null : onPressed,
            child: child,
          );

    if (width != null) {
      button = SizedBox(width: width, height: height, child: button);
    } else if (height != 48) {
      button = SizedBox(height: height, child: button);
    }

    return button;
  }
}