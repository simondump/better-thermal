import 'package:better_thermal/styles/themes.dart';
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
    final colors = context.theme.colors;

    final styles = {
      AlertType.primary: AlertStyle(
        backgroundColor: colors.primary.withValues(alpha: 0.1),
        borderColor: colors.primary,
        textColor: colors.onPrimary,
      ),
      AlertType.secondary: AlertStyle(
        backgroundColor: colors.secondary.withValues(alpha: 0.1),
        borderColor: colors.secondary,
        textColor: colors.onSecondary,
      ),
      AlertType.success: AlertStyle(
        backgroundColor: colors.success.withValues(alpha: 0.1),
        borderColor: colors.success,
        textColor: colors.onSuccess,
      ),
      AlertType.warning: AlertStyle(
        backgroundColor: colors.warning.withValues(alpha: 0.1),
        borderColor: colors.warning,
        textColor: colors.onWarning,
      ),
      AlertType.danger: AlertStyle(
        backgroundColor: colors.danger.withValues(alpha: 0.1),
        borderColor: colors.danger,
        textColor: colors.onDanger,
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
