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

  const CustomAppBar({super.key, this.title, this.subtitle, this.extraActions});

  @override
  Size get preferredSize => const Size.fromHeight(66);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(appLocaleProvider).languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authNotifierProvider).currentUser;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Icon(
              Icons.eco_outlined,
              size: 28,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title ?? AppStrings.get('app_name', lang),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle ??
                        (lang == 'ar' ? 'الفرع الرئيسي' : 'Main branch'),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (extraActions != null) ...extraActions!,
            TextButton(
              onPressed: () =>
                  ref.read(appLocaleProvider.notifier).toggleLocale(),
              child: Text(lang == 'ar' ? 'EN' : 'عربي'),
            ),
            IconButton(
              tooltip: lang == 'ar' ? 'تغيير المظهر' : 'Change theme',
              onPressed: () =>
                  ref.read(appThemeModeProvider.notifier).toggleTheme(),
              icon: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                size: 20,
              ),
            ),
            if (user != null)
              IconButton(
                tooltip: user.role.getLocalized(lang),
                onPressed: () =>
                    _showUserMenu(context, ref, user, lang, isDark),
                icon: const Icon(Icons.account_circle_outlined, size: 24),
              ),
          ],
        ),
      ),
    );
  }

  void _showUserMenu(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
    String lang,
    bool isDark,
  ) {
    final isManager = user.role == UserRole.manager;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isManager
                      ? AppColors.primaryLight
                      : AppColors.secondaryLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isManager ? AppColors.primary : AppColors.secondary,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  isManager
                      ? Icons.admin_panel_settings_rounded
                      : Icons.point_of_sale_rounded,
                  color: isManager
                      ? AppColors.primaryDark
                      : AppColors.secondaryDark,
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
                        color: isDark
                            ? Colors.white
                            : AppColors.textPrimaryLight,
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
                      '${lang == 'ar' ? 'الرقم الوظيفي:' : 'Employee No:'} #${user.pinCode}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Fast Role Switcher
              Text(
                lang == 'ar' ? 'تبديل المستخدم الحالي:' : 'Switch Active User:',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref
                            .read(authNotifierProvider.notifier)
                            .loginAs(UserRole.manager);
                        Navigator.pop(ctx);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        lang == 'ar' ? 'مدير' : 'Manager',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref
                            .read(authNotifierProvider.notifier)
                            .loginAs(UserRole.cashier);
                        Navigator.pop(ctx);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        side: const BorderSide(color: AppColors.secondary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        lang == 'ar' ? 'كاشير' : 'Cashier',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondaryDark,
                        ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(
                  Icons.logout_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                label: Text(
                  lang == 'ar' ? 'تسجيل الخروج' : 'Sign Out',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
