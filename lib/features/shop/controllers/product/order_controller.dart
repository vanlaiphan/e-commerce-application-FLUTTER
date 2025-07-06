import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:t_store/data/repositories/orders/order_repository.dart';
import 'package:t_store/features/personalization/controllers/address_controller.dart';
import 'package:t_store/features/shop/controllers/product/cart_controller.dart';
import 'package:t_store/features/shop/controllers/product/checkout_controller.dart';
import 'package:t_store/features/shop/models/order_model.dart';
import 'package:t_store/navigation_menu.dart';
import 'package:t_store/utils/popups/loaders.dart';
import 'package:t_store/utils/helpers/pricing_calculator.dart';

import '../../../../common/widgets/success_screen/success_screen.dart';
import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/popups/full_screen_loader.dart';

class OrderController extends GetxController {
  static OrderController get instance => Get.find();

  /// Variables
  final cartController = CartController.instance;
  final addressController = AddressController.instance;
  final checkoutController = CheckoutController.instance;
  final orderRepository = Get.put(OrderRepository());

  /// Fetch user's order history
  Future<List<OrderModel>> fetchUserOrders() async {
    try {
      final userOrders = await orderRepository.fetchUserOrders();
      return userOrders;
    } catch (e) {
      TLoaders.warningSnackBar(title: 'Oh Snap!', message: e.toString());
      return [];
    }
  }

  /// Fetch specific order by ID
  Future<OrderModel?> fetchOrderById(String orderId) async {
    try {
      final userOrders = await orderRepository.fetchUserOrders();
      return userOrders.firstWhere(
            (order) => order.id == orderId,
        orElse: () => throw Exception('Order not found'),
      );
    } catch (e) {
      TLoaders.warningSnackBar(title: 'Oh Snap!', message: e.toString());
      return null;
    }
  }

  /// Add methods for order processing
  void processOrder(double totalAmount) async {
    try {
      // Start Loader
      TFullScreenLoader.openLoadingDialog('Processing your order', TImages.pencilAnimation);

      // Get user authentication id
      final userId = AuthenticationRepository.instance.authUser.uid;
      if (userId.isEmpty) return;

      // Tính toán các thành phần giá
      final subTotal = cartController.totalCartPrice.value;
      const location = ''; // Bạn có thể lấy từ address nếu cần
      final shippingFee = double.parse(TPricingCalculator.calculateShippingCost(subTotal, location));
      final taxFee = double.parse(TPricingCalculator.calculateTax(subTotal, location));

      // Add Details
      final order = OrderModel(
        // Generate a unique ID for the order
        id: UniqueKey().toString(),
        userId: userId,
        status: OrderStatus.pending,
        totalAmount: totalAmount,
        subTotal: subTotal,           // Thêm SubTotal
        shippingFee: shippingFee,     // Thêm Shipping Fee
        taxFee: taxFee,               // Thêm Tax Fee
        orderDate: DateTime.now(),
        paymentMethod: checkoutController.selectedPaymentMethod.value.name,
        address: addressController.selectedAddress.value,
        // Set date as needed
        deliveryDate: DateTime.now(),
        items: cartController.cartItems.toList(),
      );

      // Save the order to FireStore
      await orderRepository.saveOrder(order, userId);

      // Update the cart status
      cartController.clearCart();

      // Show Success screen
      Get.off(() => SuccessScreen(
        image: TImages.orderCompletedAnimation,
        title: 'Payment Success!',
        subTitle: 'Your item will be shipped soon!',
        onPressed: () => Get.offAll(() => const NavigationMenu()),
      ));
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      // This would require additional repository method
      // await orderRepository.updateOrderStatus(orderId, newStatus);
      TLoaders.successSnackBar(title: 'Success', message: 'Order status updated successfully');
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }
}