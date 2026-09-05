enum UserRole {
  manager,
  cashier,
  stockKeeper;

  String getLocalized(String lang) {
    switch (this) {
      case UserRole.manager:
        return lang == 'ar' ? 'مدير المتجر' : 'Store Manager';
      case UserRole.cashier:
        return lang == 'ar' ? 'كاشير مبيعات' : 'Sales Cashier';
      case UserRole.stockKeeper:
        return lang == 'ar' ? 'مسؤول المخزون' : 'Stock Keeper';
    }
  }

  bool get canViewFinancials => this == UserRole.manager;
  bool get canEditProduce => this == UserRole.manager || this == UserRole.stockKeeper;
}

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String pinCode;
  final String avatarEmoji;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.pinCode,
    this.avatarEmoji = '👤',
  });
}
