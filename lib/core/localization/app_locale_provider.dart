import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppStrings {
  static const Map<String, Map<String, String>> _localizedValues = {
    'ar': {
      'app_name': 'حصاد',
      'app_subtitle': 'المخزون الطازج',
      'dashboard': 'الرئيسية',
      'inventory': 'المخزون',
      'quick_pos': 'نقطة البيع',
      'spoilage': 'الهدر والتلف',
      'analytics': 'التقارير',
      'total_inventory_value': 'إجمالي قيمة المخزون',
      'todays_sales': 'مبيعات اليوم التقديرية',
      'spoilage_loss': 'خسائر الهدر اليوم',
      'low_stock_items': 'أصناف قاربت على النفاد',
      'freshness_score': 'معدل نضارة المخزون',
      'freshness_high': 'طازج جداً',
      'freshness_medium': 'طازج (استهلاك سريع)',
      'freshness_low': 'يقترب من الذبول',
      'freshness_expired': 'تالف / مهدور',
      'search_placeholder': 'ابحث عن خضار، فواكه، أو مورد...',
      'all': 'الكل',
      'vegetables': 'خضار',
      'leafy_greens': 'ورقيات',
      'fruits': 'فواكه',
      'citrus': 'حمضيات',
      'herbs': 'أعشاب وعطريات',
      'unit_kg': 'كغ',
      'unit_box': 'صندوق',
      'unit_piece': 'حبة',
      'unit_bundle': 'ربطة',
      'available_qty': 'المتوفر',
      'cost_price': 'سعر التكلفة',
      'selling_price': 'سعر البيع',
      'expected_profit': 'هامش الربح',
      'add_produce': 'إضافة صنف جديد',
      'edit_produce': 'تعديل الصنف',
      'record_waste': 'تسجيل تلف / هدر',
      'record_waste_subtitle': 'تتبع الكميات الذابلة والتالفة لتقليل الخسائر',
      'waste_reason_expired': 'انتهاء صلاحية وذبول طبيعي',
      'waste_reason_damage': 'تلف أثناء النقل والتفريغ',
      'waste_reason_storage': 'سوء تخزين أو تبريد',
      'waste_reason_other': 'أخرى',
      'weight_calculator': 'حاسبة الوزن السريع',
      'enter_weight': 'أدخل الوزن (كغ)',
      'total_price': 'السعر الإجمالي',
      'confirm_sale': 'إتمام البيع وخصم المخزون',
      'sale_completed': 'تم تسجيل البيع وتحديث المخزون بنجاح',
      'waste_recorded': 'تم قيد التلف بنجاح وتحديث الرسوم البيانية',
      'days_shelf_life': 'صلاحية تقديرية (أيام)',
      'supplier': 'المورد',
      'batch_date': 'تاريخ الدفعة',
      'price_fluctuation': 'مؤشر تقلبات سعر الجملة',
      'actions': 'الإجراءات',
      'currency': 'ر.س',
      'dark_mode': 'الوضع الداكن',
      'language': 'English',
      'no_items_found': 'لا توجد أصناف تطابق البحث',
      'view_details': 'عرض التفاصيل والتحليلات',
      'recent_batches': 'دفعات التوريد الأخيرة',
      'market_comparison': 'مقارنة بسعر سوق الجملة اليوم',
      'export_report': 'تصدير التقرير (PDF/Excel)',
      'top_selling': 'الأكثر طلباً',
      'spoilage_rate': 'معدل التلف العام',
    },
    'en': {
      'app_name': 'Hasad',
      'app_subtitle': 'Fresh Produce',
      'dashboard': 'Dashboard',
      'inventory': 'Inventory',
      'quick_pos': 'Quick POS',
      'spoilage': 'Spoilage & Waste',
      'analytics': 'Analytics',
      'total_inventory_value': 'Total Stock Value',
      'todays_sales': "Today's Est. Sales",
      'spoilage_loss': "Today's Spoilage Loss",
      'low_stock_items': 'Low Stock Produce',
      'freshness_score': 'Freshness Index',
      'freshness_high': 'Peak Freshness',
      'freshness_medium': 'Good Condition',
      'freshness_low': 'Needs Fast Sell',
      'freshness_expired': 'Spoiled / Waste',
      'search_placeholder': 'Search vegetables, fruits, or supplier...',
      'all': 'All',
      'vegetables': 'Vegetables',
      'leafy_greens': 'Leafy Greens',
      'fruits': 'Fruits',
      'citrus': 'Citrus',
      'herbs': 'Fresh Herbs',
      'unit_kg': 'kg',
      'unit_box': 'Box',
      'unit_piece': 'Pc',
      'unit_bundle': 'Bundle',
      'available_qty': 'In Stock',
      'cost_price': 'Cost Price',
      'selling_price': 'Selling Price',
      'expected_profit': 'Profit Margin',
      'add_produce': 'Add Produce Item',
      'edit_produce': 'Edit Produce',
      'record_waste': 'Record Spoilage',
      'record_waste_subtitle': 'Track decayed produce to cut operational losses',
      'waste_reason_expired': 'Natural wilting & expired',
      'waste_reason_damage': 'Transit / Handling damage',
      'waste_reason_storage': 'Poor cooling / storage',
      'waste_reason_other': 'Other reason',
      'weight_calculator': 'Produce Scale Calculator',
      'enter_weight': 'Enter Weight (kg)',
      'total_price': 'Total Amount',
      'confirm_sale': 'Complete Sale & Deduct Stock',
      'sale_completed': 'Sale recorded and inventory updated',
      'waste_recorded': 'Waste logged and analytics recalculated',
      'days_shelf_life': 'Est. Shelf Life (days)',
      'supplier': 'Supplier',
      'batch_date': 'Batch Date',
      'price_fluctuation': 'Wholesale Price Fluctuation',
      'actions': 'Actions',
      'currency': 'SAR',
      'dark_mode': 'Dark Mode',
      'language': 'العربية',
      'no_items_found': 'No produce found matching criteria',
      'view_details': 'View Details & Analytics',
      'recent_batches': 'Recent Receiving Batches',
      'market_comparison': 'Wholesale Market Comparison',
      'export_report': 'Export Report (PDF/Excel)',
      'top_selling': 'Top Fast Moving',
      'spoilage_rate': 'Overall Spoilage Rate',
    },
  };

  static String get(String key, String lang) {
    return _localizedValues[lang]?[key] ?? key;
  }
}

class AppLocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => const Locale('ar');

  void toggleLocale() {
    state = state.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
  }

  void setLocale(String langCode) {
    state = Locale(langCode);
  }
}

final appLocaleProvider = NotifierProvider<AppLocaleNotifier, Locale>(
  AppLocaleNotifier.new,
);

class AppThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.light;

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}

final appThemeModeProvider = NotifierProvider<AppThemeModeNotifier, ThemeMode>(
  AppThemeModeNotifier.new,
);
