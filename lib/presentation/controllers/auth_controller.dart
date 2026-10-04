import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/app_user.dart';

class AuthState {
  final AppUser? currentUser;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.currentUser,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isAuthenticated => currentUser != null;
  bool get isManager => currentUser?.role == UserRole.manager;
  bool get isCashier => currentUser?.role == UserRole.cashier;

  AuthState copyWith({
    AppUser? currentUser,
    bool? isLoading,
    String? errorMessage,
    bool clearUser = false,
  }) {
    return AuthState(
      currentUser: clearUser ? null : (currentUser ?? this.currentUser),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  // Preset Demo Accounts
  static const AppUser demoManager = AppUser(
    id: 'u_manager',
    name: 'أبو صالح (المدير)',
    email: 'manager@hasad.com',
    role: UserRole.manager,
    pinCode: '1111',
    avatarEmoji: '👨‍💼',
  );

  static const AppUser demoCashier = AppUser(
    id: 'u_cashier',
    name: 'يوسف (كاشير الصباح)',
    email: 'cashier@hasad.com',
    role: UserRole.cashier,
    pinCode: '2222',
    avatarEmoji: '🧑‍💻',
  );

  static const AppUser demoStockKeeper = AppUser(
    id: 'u_stock',
    name: 'خالد (أمين المستودع)',
    email: 'stock@hasad.com',
    role: UserRole.stockKeeper,
    pinCode: '3333',
    avatarEmoji: '👷',
  );

  @override
  AuthState build() {
    // Initial state: starts at login screen so recruiters/users can experience auth and PIN keypad
    return const AuthState(currentUser: null);
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(milliseconds: 500)); // Smooth UX transition

    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail == 'cashier@hasad.com') {
      state = state.copyWith(currentUser: demoCashier, isLoading: false);
      return true;
    } else if (cleanEmail == 'stock@hasad.com') {
      state = state.copyWith(currentUser: demoStockKeeper, isLoading: false);
      return true;
    } else {
      // Default to manager for any other credentials in demo
      state = state.copyWith(currentUser: demoManager, isLoading: false);
      return true;
    }
  }

  Future<bool> loginWithPin(String pin) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(milliseconds: 300));

    if (pin == demoManager.pinCode || pin == '1234' || pin == '0000') {
      state = state.copyWith(currentUser: demoManager, isLoading: false);
      return true;
    } else if (pin == demoCashier.pinCode) {
      state = state.copyWith(currentUser: demoCashier, isLoading: false);
      return true;
    } else if (pin == demoStockKeeper.pinCode) {
      state = state.copyWith(currentUser: demoStockKeeper, isLoading: false);
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'رمز PIN غير صحيح',
      );
      return false;
    }
  }

  void loginAs(UserRole role) {
    switch (role) {
      case UserRole.manager:
        state = state.copyWith(currentUser: demoManager, clearUser: false);
        break;
      case UserRole.cashier:
        state = state.copyWith(currentUser: demoCashier, clearUser: false);
        break;
      case UserRole.stockKeeper:
        state = state.copyWith(currentUser: demoStockKeeper, clearUser: false);
        break;
    }
  }

  void logout() {
    state = const AuthState(currentUser: null);
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
