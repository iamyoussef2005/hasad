import 'package:flutter/material.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../../widgets/frosted_glass_container.dart';

class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final double? numericValue;
  final String? currencySuffix;
  final int decimalDigits;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String? trendText;
  final bool isTrendPositive;
  final VoidCallback? onTap;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    this.numericValue,
    this.currencySuffix,
    this.decimalDigits = 0,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.trendText,
    this.isTrendPositive = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FrostedGlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 10,
      onTap: onTap == null
          ? null
          : () {
              AppHaptics.light();
              onTap!();
            },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              numericValue == null
                  ? value
                  : '${numericValue!.toStringAsFixed(decimalDigits)}${currencySuffix == null ? '' : ' $currencySuffix'}',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
