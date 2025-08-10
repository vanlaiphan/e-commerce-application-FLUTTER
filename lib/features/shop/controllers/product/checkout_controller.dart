import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:t_store/common/widgets/payment/payment_tile.dart';
import 'package:t_store/common/widgets/texts/section_heading.dart';
import 'package:t_store/features/shop/models/payment_method_model.dart';
import 'package:t_store/utils/constants/image_strings.dart';
import 'package:t_store/utils/constants/sizes.dart';

class CheckoutController extends GetxController {
  static CheckoutController get instance => Get.find();

  final Rx<PaymentMethodModel> selectedPaymentMethod = PaymentMethodModel.empty().obs;

  @override
  void onInit() {
    selectedPaymentMethod.value = PaymentMethodModel(image: TImages.paypal, name: 'Paypal');
    super.onInit();
  }

  void handlePaypalPayment(BuildContext context, double amount) {
    print("Initiating PayPal payment with amount: $amount");
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => UsePaypal(
          sandboxMode: true, // Set to false in production
          clientId: "AeDXiPOfSsPhaFetf7KtKi6j195_lUWIRydNmaAjYgKCJNGT5CVRqW4GwUtz6zG1tVnCMOR4iyvUKHGZ",
          secretKey: "EHFQTFBJmwpLoo0KFuvfWlLgepOwSbAyPTQkw2qOoXofn6K6kuckhvcr2qHX63eRBXkwyMKw_jpuLLwZ",
          returnURL: "https://samplesite.com/return",
          cancelURL: "https://samplesite.com/cancel",
          transactions: [
            {
              "amount": {
                "total": amount.toString(),
                "currency": "USD",
              },
              "description": "Payment for products",
            }
          ],
          onSuccess: (Map params) async {
            print("Payment Successful: $params");
            // Handle success - Update order status, show confirmation, etc.
          },
          onError: (error) {
            print("Payment Error: $error");
            // Handle error
          },
          onCancel: (params) {
            print("Payment Cancelled: $params");
            // Handle cancellation
          },
        ),
      ),
    );
  }

  Future<dynamic> selectPaymentMethod(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (_) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(TSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TSectionHeading(title: 'Select Payment Method', showActionButton: false),
              const SizedBox(height: TSizes.spaceBtwSections),
              GestureDetector(
                onTap: () => handlePaypalPayment(context, 99.99), // Replace with actual amount
                child: TPaymentTile(paymentMethod: PaymentMethodModel(name: 'Paypal', image: TImages.paypal)),
              ),
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              TPaymentTile(paymentMethod: PaymentMethodModel(name: 'Stripe', image: TImages.stripe)),
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              TPaymentTile(paymentMethod: PaymentMethodModel(name: 'Google Pay', image: TImages.googlePay)),
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              TPaymentTile(paymentMethod: PaymentMethodModel(name: 'Apple Pay', image: TImages.applePay)),
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              TPaymentTile(paymentMethod: PaymentMethodModel(name: 'VISA', image: TImages.visa)),
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              TPaymentTile(paymentMethod: PaymentMethodModel(name: 'Master Card', image: TImages.masterCard)),
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              TPaymentTile(paymentMethod: PaymentMethodModel(name: 'Credit Card', image: TImages.creditCard)),
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              const SizedBox(height: TSizes.spaceBtwSections),
            ],
          ),
        ),
      ),
    );
  }
}