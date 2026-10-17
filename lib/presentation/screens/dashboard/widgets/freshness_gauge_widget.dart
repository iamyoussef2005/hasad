import 'package:flutter/material.dart';
import '../../../widgets/frosted_glass_container.dart';
import '../../ai_scanner/ai_freshness_scanner_screen.dart';

class FreshnessGaugeWidget extends StatelessWidget {
  final double score;
  final String lang;
  const FreshnessGaugeWidget({
    super.key,
    required this.score,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final ar = lang == 'ar';
    final theme = Theme.of(context);
    final color = score >= 0.6
        ? theme.colorScheme.primary
        : theme.colorScheme.error;
    return FrostedGlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ar ? 'متوسط النضارة' : 'Average freshness',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${(score * 100).round()}%',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Semantics(
            label: ar ? 'متوسط النضارة' : 'Average freshness',
            value: '${(score * 100).round()}%',
            child: LinearProgressIndicator(
              value: score.clamp(0, 1),
              minHeight: 5,
              color: color,
              backgroundColor: theme.dividerColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            ar
                ? 'متوسط درجات النضارة المسجلة للأصناف.'
                : 'Average of the recorded freshness scores.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const AiFreshnessScannerScreen(),
              ),
            ),
            icon: const Icon(Icons.document_scanner_outlined, size: 18),
            label: Text(ar ? 'فحص صنف' : 'Inspect an item'),
          ),
        ],
      ),
    );
  }
}
