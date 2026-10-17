import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StoreOverviewHeader extends StatelessWidget {
  final String name;
  final String lang;
  final int attentionCount;
  const StoreOverviewHeader({
    super.key,
    required this.name,
    required this.lang,
    required this.attentionCount,
  });

  @override
  Widget build(BuildContext context) {
    final ar = lang == 'ar';
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat(
              ar ? 'EEEE، d MMMM' : 'EEEE, d MMMM',
              lang,
            ).format(DateTime.now()),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ar ? 'نظرة على المتجر' : 'Store overview',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            ar ? 'أهلاً $name' : 'Hello, $name',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                attentionCount == 0
                    ? Icons.check_circle_outline
                    : Icons.flag_outlined,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  ar
                      ? (attentionCount == 0
                            ? 'لا توجد أصناف تحتاج متابعة اليوم'
                            : '$attentionCount أصناف تحتاج متابعة اليوم')
                      : (attentionCount == 0
                            ? 'No items need attention today'
                            : '$attentionCount items need attention today'),
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
