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
      screens = [const QuickPosScreen(), const InventoryScreen()];
      destinations = [
        NavigationDestination(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: AppColors.primaryDark,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.point_of_sale_rounded,
              color: Colors.white,
              size: 20,
            ),
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
            child: const Icon(Icons.inventory_2_rounded),
          ),
          label: AppStrings.get('inventory', lang),
        ),
      ];
    } else if (userRole == UserRole.stockKeeper) {
      // Stock keeper layout: Inventory & Spoilage
      screens = [const InventoryScreen(), const WasteManagementScreen()];
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
            child: const Icon(Icons.inventory_2_rounded),
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
            child: const Icon(
              Icons.delete_sweep_rounded,
              color: AppColors.spoilageRed,
            ),
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
          selectedIcon: const Icon(Icons.dashboard_rounded),
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
            child: const Icon(Icons.inventory_2_rounded),
          ),
          label: AppStrings.get('inventory', lang),
        ),
        NavigationDestination(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: AppColors.primaryDark,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.point_of_sale_rounded,
              color: Colors.white,
              size: 20,
            ),
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
            child: const Icon(
              Icons.delete_sweep_rounded,
              color: AppColors.spoilageRed,
            ),
          ),
          label: AppStrings.get('spoilage', lang),
        ),
        NavigationDestination(
          icon: const Icon(Icons.bar_chart_outlined),
          selectedIcon: const Icon(Icons.bar_chart_rounded),
          label: AppStrings.get('analytics', lang),
        ),
      ];
    }

    final safeIndex = _currentIndex.clamp(0, screens.length - 1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 840;
        final extended = constraints.maxWidth >= 1200;
        final content = SafeArea(
          top: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: IndexedStack(index: safeIndex, children: screens),
            ),
          ),
        );
        return Scaffold(
          appBar: const CustomAppBar(),
          body: wide
              ? Row(
                  children: [
                    NavigationRail(
                      selectedIndex: safeIndex,
                      extended: extended,
                      minExtendedWidth: 220,
                      backgroundColor: isDark
                          ? AppColors.surfaceDark
                          : Colors.white,
                      indicatorColor: AppColors.primary.withValues(alpha: 0.14),
                      labelType: extended
                          ? NavigationRailLabelType.none
                          : NavigationRailLabelType.all,
                      onDestinationSelected: _navigateToTab,
                      leading: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Icon(
                          Icons.eco_outlined,
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      destinations: [
                        for (final destination in destinations)
                          NavigationRailDestination(
                            icon: destination.icon,
                            selectedIcon:
                                destination.selectedIcon ?? destination.icon,
                            label: Text(destination.label),
                          ),
                      ],
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: content),
                  ],
                )
              : content,
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  selectedIndex: safeIndex,
                  onDestinationSelected: _navigateToTab,
                  backgroundColor: isDark
                      ? AppColors.surfaceDark
                      : Colors.white,
                  elevation: 0,
                  indicatorColor: AppColors.primary.withValues(alpha: 0.14),
                  destinations: destinations,
                ),
        );
      },
    );
  }
}
