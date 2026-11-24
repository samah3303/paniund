import 'package:flutter/material.dart';
import '../../core/theme/nordic_colors.dart';

enum NordicButtonVariant {
  primary, // Warm yellow accent with dark text
  navy, // Deep navy with white text
  outline, // Navy border with navy text
  ghost, // No border, muted or navy text
}

class NordicButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final NordicButtonVariant variant;
  final bool isLoading;
  final Widget? icon;
  final bool fullWidth;
  final double height;

  const NordicButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = NordicButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
    this.height = 46.0,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case NordicButtonVariant.primary:
        backgroundColor = NordicColors.yellow;
        foregroundColor = NordicColors.textDark;
        break;
      case NordicButtonVariant.navy:
        backgroundColor = NordicColors.navy;
        foregroundColor = NordicColors.textInverse;
        break;
      case NordicButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = NordicColors.navy;
        borderSide = const BorderSide(color: NordicColors.navy, width: 1.5);
        break;
      case NordicButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = NordicColors.navy;
        break;
    }

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: variant == NordicButtonVariant.primary ? 1 : 0,
      shadowColor: Colors.black.withOpacity(0.1),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: borderSide,
      ),
      disabledBackgroundColor: NordicColors.borderLight,
      disabledForegroundColor: NordicColors.textLight,
    );

    Widget content;
    if (isLoading) {
      content = SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
        ),
      );
    } else if (icon != null) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon!,
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: foregroundColor,
            ),
          ),
        ],
      );
    } else {
      content = Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: foregroundColor,
        ),
      );
    }

    final button = SizedBox(
      height: height,
      child: ElevatedButton(
        style: buttonStyle,
        onPressed: isLoading ? null : onPressed,
        child: content,
      ),
    );

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}
