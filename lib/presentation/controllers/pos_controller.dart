import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/produce_item.dart';
import 'inventory_controller.dart';

class CartItem {
  final ProduceItem produce;
  final double quantity; // e.g. 1.75 kg
  final double totalPrice;

  const CartItem({
    required this.produce,
    required this.quantity,
    required this.totalPrice,
  });
}

class PosState {
  final List<CartItem> cart;
  final ProduceItem? selectedItem;
  final double inputWeight; // current weight on scale
  final double todaySalesTotal;

  const PosState({
    this.cart = const [],
    this.selectedItem,
    this.inputWeight = 1.0,
    this.todaySalesTotal = 2450.0, // Initial baseline sales
  });

  double get cartTotal => cart.fold(0.0, (sum, item) => sum + item.totalPrice);
  int get itemCount => cart.length;

  PosState copyWith({
    List<CartItem>? cart,
    ProduceItem? selectedItem,
    double? inputWeight,
    double? todaySalesTotal,
    bool clearSelectedItem = false,
  }) {
    return PosState(
      cart: cart ?? this.cart,
      selectedItem: clearSelectedItem ? null : (selectedItem ?? this.selectedItem),
      inputWeight: inputWeight ?? this.inputWeight,
      todaySalesTotal: todaySalesTotal ?? this.todaySalesTotal,
    );
  }
}

class PosNotifier extends Notifier<PosState> {
  @override
  PosState build() => const PosState();

  void selectProduce(ProduceItem item) {
    state = state.copyWith(selectedItem: item, inputWeight: 1.0);
  }

  void updateWeight(double weight) {
    state = state.copyWith(inputWeight: weight);
  }

  void addToCart() {
    if (state.selectedItem == null || state.inputWeight <= 0) return;

    final item = state.selectedItem!;
    final totalPrice = item.sellingPrice * state.inputWeight;

    final existingIndex = state.cart.indexWhere((c) => c.produce.id == item.id);
    List<CartItem> updatedCart = List.from(state.cart);

    if (existingIndex != -1) {
      final old = updatedCart[existingIndex];
      final newQty = old.quantity + state.inputWeight;
      updatedCart[existingIndex] = CartItem(
        produce: item,
        quantity: newQty,
        totalPrice: item.sellingPrice * newQty,
      );
    } else {
      updatedCart.add(
        CartItem(
          produce: item,
          quantity: state.inputWeight,
          totalPrice: totalPrice,
        ),
      );
    }

    state = state.copyWith(
      cart: updatedCart,
      clearSelectedItem: true,
      inputWeight: 1.0,
    );
  }

  void removeFromCart(int index) {
    final updated = List<CartItem>.from(state.cart)..removeAt(index);
    state = state.copyWith(cart: updated);
  }

  void clearCart() {
    state = state.copyWith(cart: []);
  }

  Future<void> checkout() async {
    if (state.cart.isEmpty) return;

    final repo = ref.read(produceRepositoryProvider);
    final saleAmount = state.cartTotal;

    for (final cartItem in state.cart) {
      await repo.processSale(cartItem.produce.id, cartItem.quantity);
    }

    state = state.copyWith(
      cart: [],
      todaySalesTotal: state.todaySalesTotal + saleAmount,
      clearSelectedItem: true,
    );

    // Refresh inventory so stock updates on all screens
    ref.invalidate(inventoryNotifierProvider);
  }
}

final posNotifierProvider = NotifierProvider<PosNotifier, PosState>(
  PosNotifier.new,
);
