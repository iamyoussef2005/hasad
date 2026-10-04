import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_locale_provider.dart';
import '../../data/models/app_user.dart';
import '../controllers/auth_controller.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String? title;
  final String? subtitle;
  final List<Widget>? extraActions;

  const CustomAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.extraActions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(66);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = locale.languageCode;

    final displayTitle = title ?? AppStrings.get('app_name', lang);

    return Container(
      padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.bgDark.withValues(alpha: 0.95)
            : AppColors.bgLight.withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.8,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Modern High-End Brand Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF047857),
                    Color(0xFF10B981),
                    Color(0xFF34D399),
                  ],
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.45),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.38),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Subtle gloss highlight on top
                  Positioned(
                    top: 2,
                    left: 3,
                    right: 3,
                    child: Container(
                      height: 18,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.4),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                      ),
                    ),
                  ),
                  // Premium vector leaf icon
                  const Icon(
                    Icons.eco_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Title Only (Larger and Bolder)
            // Title & Subtitle / Live Cloud Indicator
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.successGreen,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.successGreen.withValues(alpha: 0.6),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        subtitle ?? (lang == 'ar' ? 'سحابي متصل' : 'Cloud Sync Active'),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Extra actions if any
            if (extraActions != null) ...extraActions!,

            // Language Switcher Button
            InkWell(
              onTap: () => ref.read(appLocaleProvider.notifier).toggleLocale(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.language_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      lang == 'ar' ? 'EN' : 'عربي',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Dark Mode Switcher
            InkWell(
              onTap: () => ref.read(appThemeModeProvider.notifier).toggleTheme(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Icon(
                  themeMode == ThemeMode.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  size: 18,
                  color: isDark ? AppColors.secondary : AppColors.textSecondaryLight,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // User Profile Avatar & Logout Dialog
            Consumer(
              builder: (context, ref, _) {
                final authState = ref.watch(authNotifierProvider);
                final user = authState.currentUser;
                if (user == null) return const SizedBox.shrink();

                return InkWell(
                  onTap: () => _showUserMenu(context, ref, user, lang, isDark),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: authState.isManager
                          ? AppColors.primaryLight
                          : AppColors.secondaryLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: authState.isManager
                            ? AppColors.primary
                            : AppColors.secondary,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          authState.isManager
                              ? Icons.admin_panel_settings_rounded
                              : Icons.point_of_sale_rounded,
                          size: 14,
                          color: authState.isManager
                              ? AppColors.primaryDark
                              : AppColors.secondaryDark,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          user.role.getLocalized(lang),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: authState.isManager
                                ? AppColors.primaryDark
                                : AppColors.secondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUserMenu(BuildContext context, WidgetRef ref, dynamic user, String lang, bool isDark) {
    final isManager = user.role == UserRole.manager;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isManager ? AppColors.primaryLight : AppColors.secondaryLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isManager ? AppColors.primary : AppColors.secondary,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  isManager ? Icons.admin_panel_settings_rounded : Icons.point_of_sale_rounded,
                  color: isManager ? AppColors.primaryDark : AppColors.secondaryDark,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      user.role.getLocalized(lang),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.bgDark : AppColors.bgLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${lang == 'ar' ? 'البريد:' : 'Email:'} ${user.email}',
                      style: const TextStyle(fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${lang == 'ar' ? 'معرف الموظف:' : 'Employee ID:'} #${user.pinCode}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Fast Role Switcher
              Text(
                lang == 'ar' ? 'تبديل المستخدم الحالي:' : 'Switch Active User:',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref.read(authNotifierProvider.notifier).loginAs(UserRole.manager);
                        Navigator.pop(ctx);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        lang == 'ar' ? 'مدير' : 'Manager',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref.read(authNotifierProvider.notifier).loginAs(UserRole.cashier);
                        Navigator.pop(ctx);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        side: const BorderSide(color: AppColors.secondary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        lang == 'ar' ? 'كاشير' : 'Cashier',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondaryDark),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Logout Button
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(authNotifierProvider.notifier).logout();
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.spoilageRed,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.logout_rounded, size: 16, color: Colors.white),
                label: Text(
                  lang == 'ar' ? 'تسجيل الخروج' : 'Sign Out',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
