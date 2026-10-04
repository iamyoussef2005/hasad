import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/localization/app_locale_provider.dart';
import '../../../../data/models/markdown_proposal.dart';
import '../../../controllers/markdown_controller.dart';
import '../../ai_scanner/ai_freshness_scanner_screen.dart';

class AiMarkdownInsightsCard extends ConsumerWidget {
  const AiMarkdownInsightsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    final lang = locale.languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final markdownState = ref.watch(markdownNotifierProvider);
    final proposals = markdownState.proposals;

    if (proposals.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang == 'ar' ? 'المخزون في حالة نضارة ممتازة' : 'All Stock in Optimal Freshness',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lang == 'ar'
                        ? 'لا توجد أصناف معرضة لخطر التلف حالياً بفضل إدارة المخزون الذكية.'
                        : 'No produce currently at risk of spoilage.',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.document_scanner_outlined, color: AppColors.primary),
              tooltip: AppStrings.get('ai_scan_camera', lang),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AiFreshnessScannerScreen()),
                );
              },
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF1B2333)]
              : [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.warningOrange.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.warningOrange.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.citrusGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            AppStrings.get('ai_pricing_title', lang),
                            style: AppTypography.titleMedium(isDark: isDark).copyWith(fontSize: 13),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.spoilageRed,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${proposals.length}',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppStrings.get('ai_pricing_subtitle', lang),
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.document_scanner_rounded, color: AppColors.warningOrange),
                  tooltip: AppStrings.get('ai_scan_camera', lang),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AiFreshnessScannerScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          // Proposals Horizontal Slider
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: proposals.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final proposal = proposals[index];
                return _buildProposalItem(context, ref, proposal, lang, isDark);
              },
            ),
          ),

          // Bottom Quick Batch Apply Action
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shield_outlined, size: 16, color: AppColors.primaryDark),
                    const SizedBox(width: 6),
                    Text(
                      '${AppStrings.get('potential_loss_prevented', lang)}: ${markdownState.totalPreventedLoss.toStringAsFixed(0)} ${AppStrings.get('currency', lang)}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    ref.read(markdownNotifierProvider.notifier).applyAllProposals();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          lang == 'ar'
                              ? 'تم تطبيق كافة الخصومات الذكية وتحديث الأسعار في نقطة البيع!'
                              : 'All smart markdowns applied across store inventory and POS!',
                        ),
                        backgroundColor: AppColors.primaryDark,
                      ),
                    );
                  },
                  icon: const Icon(Icons.done_all_rounded, size: 16, color: AppColors.warningOrange),
                  label: Text(
                    AppStrings.get('apply_all_discounts', lang),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.warningOrange,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProposalItem(
    BuildContext context,
    WidgetRef ref,
    MarkdownProposal proposal,
    String lang,
    bool isDark,
  ) {
    final currency = AppStrings.get('currency', lang);
    final isCritical = proposal.urgency == MarkdownUrgency.critical;

    return Container(
      width: 260,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCritical
              ? AppColors.spoilageRed.withValues(alpha: 0.5)
              : AppColors.warningOrange.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  proposal.getName(lang),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isCritical
                      ? AppColors.spoilageRed.withValues(alpha: 0.15)
                      : AppColors.warningOrange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '-${proposal.discountPercent.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: isCritical ? AppColors.spoilageRed : AppColors.warningOrange,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Price comparison
          Row(
            children: [
              Text(
                '${proposal.currentSellingPrice} $currency',
                style: const TextStyle(
                  fontSize: 11,
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                '${proposal.recommendedPrice} $currency',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Reason text
          Expanded(
            child: Text(
              proposal.getReason(lang),
              style: const TextStyle(fontSize: 10, color: Colors.grey, height: 1.3),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 6),

          // Action button
          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton.icon(
              onPressed: () {
                ref.read(markdownNotifierProvider.notifier).applyMarkdown(proposal);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      lang == 'ar'
                          ? 'تم تطبيق خصم ${proposal.discountPercent.toStringAsFixed(0)}% على ${proposal.getName(lang)}'
                          : 'Discount applied to ${proposal.getName(lang)}',
                    ),
                    backgroundColor: AppColors.primaryDark,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isCritical ? AppColors.spoilageRed : AppColors.warningOrange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.flash_on_rounded, size: 14),
              label: Text(
                AppStrings.get('apply_discount', lang),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
