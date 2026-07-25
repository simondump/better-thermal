import 'package:flutter/material.dart';

enum AlertType { primary, secondary, success, warning, danger }

class AlertStyle {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  const AlertStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });
}

class Alert extends StatelessWidget {
  final AlertType type;
  final String message;
  final IconData? icon;

  const Alert({
    super.key,
    required this.type,
    required this.message,
    this.icon,
  });

  AlertStyle _getStyle(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final styles = {
      AlertType.primary: AlertStyle(
        backgroundColor: colors.primaryContainer,
        borderColor: colors.primary,
        textColor: colors.onPrimaryContainer,
      ),
      AlertType.secondary: AlertStyle(
        backgroundColor: colors.secondaryContainer,
        borderColor: colors.secondary,
        textColor: colors.onSecondaryContainer,
      ),
      AlertType.success: AlertStyle(
        backgroundColor: colors.tertiaryContainer,
        borderColor: colors.tertiary,
        textColor: colors.onTertiaryContainer,
      ),
      AlertType.warning: AlertStyle(
        backgroundColor: colors.surfaceContainerHighest,
        borderColor: colors.outline,
        textColor: colors.onSurface,
      ),
      AlertType.danger: AlertStyle(
        backgroundColor: colors.errorContainer,
        borderColor: colors.error,
        textColor: colors.onErrorContainer,
      ),
    };

    return styles[type]!;
  }

  @override
  Widget build(BuildContext context) {
    final style = _getStyle(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: style.backgroundColor,
        border: Border.all(color: style.borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: style.textColor, size: 20),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: style.textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
