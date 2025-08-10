import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
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
  // void processOrder(double totalAmount) async {
  //   try {
  //     // Start Loader
  //     TFullScreenLoader.openLoadingDialog('Processing your order', TImages.pencilAnimation);
  //
  //     // Get user authentication id
  //     final userId = AuthenticationRepository.instance.authUser.uid;
  //     if (userId.isEmpty) return;
  //
  //     // Tính toán các thành phần giá
  //     final subTotal = cartController.totalCartPrice.value;
  //     const location = ''; // Bạn có thể lấy từ address nếu cần
  //     final shippingFee = double.parse(TPricingCalculator.calculateShippingCost(subTotal, location));
  //     final taxFee = double.parse(TPricingCalculator.calculateTax(subTotal, location));
  //
  //     // Add Details - Use UniqueKey() to generate ID
  //     final order = OrderModel(
  //       id: UniqueKey().toString(),
  //       userId: userId,
  //       status: OrderStatus.pending,
  //       totalAmount: totalAmount,
  //       subTotal: subTotal,
  //       shippingFee: shippingFee,
  //       taxFee: taxFee,
  //       orderDate: DateTime.now(),
  //       paymentMethod: checkoutController.selectedPaymentMethod.value.name,
  //       address: addressController.selectedAddress.value,
  //       deliveryDate: DateTime.now(),
  //       items: cartController.cartItems.toList(),
  //     );
  //
  //     // Save the order to FireStore (both collections)
  //     await orderRepository.saveOrder(order, userId);
  //
  //     // Update the cart status
  //     cartController.clearCart();
  //
  //     // Show Success screen
  //     Get.off(() => SuccessScreen(
  //       image: TImages.orderCompletedAnimation,
  //       title: 'Payment Success!',
  //       subTitle: 'Your item will be shipped soon!',
  //       onPressed: () => Get.offAll(() => const NavigationMenu()),
  //     ));
  //   } catch (e) {
  //     TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
  //   }
  // }

  void processOrder(double totalAmount) async {
    try {
      // Show PayPal payment interface
      Navigator.of(Get.context!).push(
        MaterialPageRoute(
          builder: (BuildContext context) => UsePaypal(
            sandboxMode: true,
            clientId: "AeDXiPOfSsPhaFetf7KtKi6j195_lUWIRydNmaAjYgKCJNGT5CVRqW4GwUtz6zG1tVnCMOR4iyvUKHGZ",
            secretKey: "EHFQTFBJmwpLoo0KFuvfWlLgepOwSbAyPTQkw2qOoXofn6K6kuckhvcr2qHX63eRBXkwyMKw_jpuLLwZ",
            returnURL: "https://samplesite.com/return",
            cancelURL: "https://samplesite.com/cancel",
            transactions: [
              {
                "amount": {
                  "total": totalAmount.toString(),
                  "currency": "USD",
                },
                "description": "Payment for your order",
              }
            ],
            note: "Contact us for any questions on your order.",
            onSuccess: (Map params) async {
              // Process order after successful payment
              await _processOrderAfterPayment(totalAmount);
            },
            onError: (error) {
              TLoaders.errorSnackBar(
                title: 'Payment Error',
                message: 'Payment failed. Please try again.',
              );
            },
            onCancel: () {
              TLoaders.warningSnackBar(
                title: 'Payment Cancelled',
                message: 'You cancelled the payment.',
              );
            },
          ),
        ),
      );

    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  // Helper method to process order after successful payment
  Future<void> _processOrderAfterPayment(double totalAmount) async {
    try {
      // Start Loader
      TFullScreenLoader.openLoadingDialog('Processing your order', TImages.pencilAnimation);

      // Get user authentication id
      final userId = AuthenticationRepository.instance.authUser.uid;
      if (userId.isEmpty) return;

      // Calculate price components
      final subTotal = cartController.totalCartPrice.value;
      const location = '';
      final shippingFee = double.parse(TPricingCalculator.calculateShippingCost(subTotal, location));
      final taxFee = double.parse(TPricingCalculator.calculateTax(subTotal, location));

      // Create order
      final order = OrderModel(
        id: UniqueKey().toString(),
        userId: userId,
        status: OrderStatus.pending,
        totalAmount: totalAmount,
        subTotal: subTotal,
        shippingFee: shippingFee,
        taxFee: taxFee,
        orderDate: DateTime.now(),
        paymentMethod: 'PayPal',
        address: addressController.selectedAddress.value,
        deliveryDate: DateTime.now(),
        items: cartController.cartItems.toList(),
      );

      // Save order
      await orderRepository.saveOrder(order, userId);
      cartController.clearCart();

      // Show success screen
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