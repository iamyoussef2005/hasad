import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_locale_provider.dart';
import '../../core/utils/app_haptics.dart';
import '../../data/models/app_user.dart';
import '../controllers/auth_controller.dart';
import '../widgets/custom_app_bar.dart';
import '../controllers/inventory_controller.dart';
import '../controllers/waste_controller.dart';
import 'dashboard/dashboard_screen.dart';
import 'inventory/inventory_screen.dart';
import 'pos/quick_pos_screen.dart';
import 'waste/waste_management_screen.dart';
import 'analytics/analytics_screen.dart';

class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key});

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  int _currentIndex = 0;
  UserRole? _previousRole;

  void _navigateToTab(int index) {
    AppHaptics.selection();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(appLocaleProvider);
    final lang = locale.languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final authState = ref.watch(authNotifierProvider);
    final userRole = authState.currentUser?.role ?? UserRole.manager;

    // Reset tab index if role switches
    if (_previousRole != null && _previousRole != userRole) {
      _currentIndex = 0;
    }
    _previousRole = userRole;

    final inventoryAsync = ref.watch(inventoryNotifierProvider);
    final wasteAsync = ref.watch(wasteNotifierProvider);

    final lowStockCount = inventoryAsync.value?.lowStockCount ?? 0;
    final wasteCount = wasteAsync.value?.records.length ?? 0;

    final List<Widget> screens;
    final List<NavigationDestination> destinations;

    if (userRole == UserRole.cashier) {
      // Cashier focused layout: Quick POS is primary, Inventory for stock check
      screens = [
        const QuickPosScreen(),
        const InventoryScreen(),
      ];
      destinations = [
        NavigationDestination(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.point_of_sale_rounded, color: Colors.white, size: 20),
          ),
          label: AppStrings.get('quick_pos', lang),
        ),
        NavigationDestination(
          icon: Badge(
            isLabelVisible: lowStockCount > 0,
            label: Text('$lowStockCount'),
            backgroundColor: AppColors.warningOrange,
            child: const Icon(Icons.inventory_2_outlined),
          ),
          selectedIcon: Badge(
            isLabelVisible: lowStockCount > 0,
            label: Text('$lowStockCount'),
            backgroundColor: AppColors.warningOrange,
            child: const Icon(Icons.inventory_2_rounded, color: AppColors.primaryDark),
          ),
          label: AppStrings.get('inventory', lang),
        ),
      ];
    } else if (userRole == UserRole.stockKeeper) {
      // Stock keeper layout: Inventory & Spoilage
      screens = [
        const InventoryScreen(),
        const WasteManagementScreen(),
      ];
      destinations = [
        NavigationDestination(
          icon: Badge(
            isLabelVisible: lowStockCount > 0,
            label: Text('$lowStockCount'),
            backgroundColor: AppColors.warningOrange,
            child: const Icon(Icons.inventory_2_outlined),
          ),
          selectedIcon: Badge(
            isLabelVisible: lowStockCount > 0,
            label: Text('$lowStockCount'),
            backgroundColor: AppColors.warningOrange,
            child: const Icon(Icons.inventory_2_rounded, color: AppColors.primaryDark),
          ),
          label: AppStrings.get('inventory', lang),
        ),
        NavigationDestination(
          icon: Badge(
            isLabelVisible: wasteCount > 0,
            label: Text('$wasteCount'),
            backgroundColor: AppColors.spoilageRed,
            child: const Icon(Icons.delete_sweep_outlined),
          ),
          selectedIcon: Badge(
            isLabelVisible: wasteCount > 0,
            label: Text('$wasteCount'),
            backgroundColor: AppColors.spoilageRed,
            child: const Icon(Icons.delete_sweep_rounded, color: AppColors.spoilageRed),
          ),
          label: AppStrings.get('spoilage', lang),
        ),
      ];
    } else {
      // Manager: full operational access
      screens = [
        DashboardScreen(onNavigateToTab: _navigateToTab),
        const InventoryScreen(),
        const QuickPosScreen(),
        const WasteManagementScreen(),
        const AnalyticsScreen(),
      ];
      destinations = [
        NavigationDestination(
          icon: const Icon(Icons.dashboard_outlined),
          selectedIcon: const Icon(Icons.dashboard_rounded, color: AppColors.primaryDark),
          label: AppStrings.get('dashboard', lang),
        ),
        NavigationDestination(
          icon: Badge(
            isLabelVisible: lowStockCount > 0,
            label: Text('$lowStockCount'),
            backgroundColor: AppColors.warningOrange,
            child: const Icon(Icons.inventory_2_outlined),
          ),
          selectedIcon: Badge(
            isLabelVisible: lowStockCount > 0,
            label: Text('$lowStockCount'),
            backgroundColor: AppColors.warningOrange,
            child: const Icon(Icons.inventory_2_rounded, color: AppColors.primaryDark),
          ),
          label: AppStrings.get('inventory', lang),
        ),
        NavigationDestination(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.point_of_sale_rounded, color: Colors.white, size: 20),
          ),
          label: AppStrings.get('quick_pos', lang),
        ),
        NavigationDestination(
          icon: Badge(
            isLabelVisible: wasteCount > 0,
            label: Text('$wasteCount'),
            backgroundColor: AppColors.spoilageRed,
            child: const Icon(Icons.delete_sweep_outlined),
          ),
          selectedIcon: Badge(
            isLabelVisible: wasteCount > 0,
            label: Text('$wasteCount'),
            backgroundColor: AppColors.spoilageRed,
            child: const Icon(Icons.delete_sweep_rounded, color: AppColors.spoilageRed),
          ),
          label: AppStrings.get('spoilage', lang),
        ),
        NavigationDestination(
          icon: const Icon(Icons.bar_chart_outlined),
          selectedIcon: const Icon(Icons.bar_chart_rounded, color: AppColors.primaryDark),
          label: AppStrings.get('analytics', lang),
        ),
      ];
    }

    final safeIndex = _currentIndex.clamp(0, screens.length - 1);

    return Scaffold(
      appBar: const CustomAppBar(),
      body: IndexedStack(
        index: safeIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 0.8,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: safeIndex,
          onDestinationSelected: _navigateToTab,
          backgroundColor: Colors.transparent,
          elevation: 0,
          indicatorColor: AppColors.primaryLight,
          destinations: destinations,
        ),
      ),
    );
  }
}
