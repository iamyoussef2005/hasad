import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_locale_provider.dart';
import '../../../controllers/markdown_controller.dart';
import '../../../widgets/frosted_glass_container.dart';
import '../../ai_scanner/ai_freshness_scanner_screen.dart';

class AiMarkdownInsightsCard extends ConsumerWidget {
  const AiMarkdownInsightsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(appLocaleProvider).languageCode;
    final ar = lang == 'ar';
    final state = ref.watch(markdownNotifierProvider);
    final theme = Theme.of(context);
    final currency = AppStrings.get('currency', lang);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: FrostedGlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    ar ? 'تخفيضات مقترحة' : 'Suggested markdowns',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: ar ? 'فحص الجودة' : 'Quality inspection',
                  icon: const Icon(Icons.document_scanner_outlined, size: 20),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const AiFreshnessScannerScreen(),
                    ),
                  ),
                ),
              ],
            ),
            Text(
              ar
                  ? 'راجع السعر قبل تطبيقه على المخزون.'
                  : 'Review prices before applying them to inventory.',
              style: theme.textTheme.bodySmall,
            ),
            if (state.proposals.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  ar
                      ? 'لا توجد تخفيضات مقترحة حالياً.'
                      : 'No markdowns suggested right now.',
                ),
              ),
            for (final proposal in state.proposals) ...[
              const Divider(height: 28),
              Text(
                proposal.getName(lang),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '${proposal.currentSellingPrice.toStringAsFixed(2)} $currency',
                    style: theme.textTheme.bodySmall?.copyWith(
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  Text(
                    '${proposal.recommendedPrice.toStringAsFixed(2)} $currency',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '−${proposal.discountPercent.round()}%',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  TextButton(
                    onPressed: state.isProcessing
                        ? null
                        : () async {
                            await ref
                                .read(markdownNotifierProvider.notifier)
                                .applyMarkdown(proposal);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ar
                                      ? 'تم تحديث سعر الصنف'
                                      : 'Item price updated',
                                ),
                              ),
                            );
                          },
                    child: Text(ar ? 'تطبيق السعر' : 'Apply price'),
                  ),
                ],
              ),
              Text(
                proposal.getReason(lang),
                style: theme.textTheme.bodySmall?.copyWith(height: 1.6),
              ),
            ],
            if (state.proposals.isNotEmpty) ...[
              const Divider(height: 28),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    ar
                        ? 'قيمة مخزون معرض للهدر: ${state.totalPreventedLoss.toStringAsFixed(0)} $currency'
                        : 'Stock at risk: ${state.totalPreventedLoss.toStringAsFixed(0)} $currency',
                    style: theme.textTheme.bodySmall,
                  ),
                  OutlinedButton(
                    onPressed: state.isProcessing
                        ? null
                        : () async {
                            await ref
                                .read(markdownNotifierProvider.notifier)
                                .applyAllProposals();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ar
                                      ? 'تم تطبيق التخفيضات'
                                      : 'Markdowns applied',
                                ),
                              ),
                            );
                          },
                    child: Text(ar ? 'تطبيق الكل' : 'Apply all'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
