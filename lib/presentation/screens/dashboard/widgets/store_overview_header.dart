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
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF123D32), Color(0xFF22634C)],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Icon(Icons.eco_outlined, color: Color(0xFFD2EDAD)),
              Text(
                ar ? 'حصاد • مساحة العمل' : 'HASAD / WORKSPACE',
                style: const TextStyle(
                  color: Color(0xFFD2EDAD),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                DateFormat.yMMMd(lang).format(DateTime.now()),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            ar ? 'أهلاً، $name' : 'Welcome, $name',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ar
                ? 'مخزون أنضر. هدر أقل. قرارات أوضح.'
                : 'Fresher stock. Less waste. Clearer decisions.',
            style: const TextStyle(color: Colors.white70, height: 1.6),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Icon(
                  attentionCount == 0
                      ? Icons.check_circle_outline
                      : Icons.flag_outlined,
                  size: 18,
                  color: const Color(0xFFD2EDAD),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    ar
                        ? (attentionCount == 0
                              ? 'كل الأصناف بحالة مستقرة'
                              : '$attentionCount أصناف تحتاج متابعتك اليوم')
                        : (attentionCount == 0
                              ? 'Your inventory is in good shape'
                              : '$attentionCount items need your attention'),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
