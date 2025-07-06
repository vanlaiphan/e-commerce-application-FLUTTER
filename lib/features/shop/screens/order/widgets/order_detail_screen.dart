import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/common/widgets/appbar/appbar.dart';
import 'package:t_store/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:t_store/common/widgets/texts/section_heading.dart';
import 'package:t_store/features/shop/controllers/product/order_controller.dart';
import 'package:t_store/features/shop/models/order_model.dart';
import 'package:t_store/utils/constants/colors.dart';
import 'package:t_store/utils/constants/sizes.dart';
import 'package:t_store/utils/helpers/helper_functions.dart';
import 'package:t_store/utils/loaders/animation_loader.dart';
import 'package:t_store/utils/constants/image_strings.dart';

import '../../../../../common/widgets/images/t_circular_image.dart';
import '../../../../../utils/constants/enums.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final controller = OrderController.instance;
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: TAppBar(
        title: Text('Order Details', style: Theme.of(context).textTheme.headlineSmall),
        showBackArrow: true,
      ),
      body: FutureBuilder<List<OrderModel>>(
        future: controller.fetchUserOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: TAnimationLoaderWidget(
                text: 'Something went wrong!',
                animation: TImages.orderCompletedAnimation,
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: TAnimationLoaderWidget(
                text: 'No orders found!',
                animation: TImages.orderCompletedAnimation,
              ),
            );
          }

          // Find the specific order
          final order = snapshot.data!.firstWhere(
            (order) => order.id == orderId,
            orElse: () => throw Exception('Order not found'),
          );

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Order Status Section
                  _buildOrderStatusSection(context, order, dark),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  /// Order Information Section
                  _buildOrderInfoSection(context, order, dark),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  /// Shipping Address Section
                  _buildShippingAddressSection(context, order, dark),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  /// Payment Method Section
                  _buildPaymentMethodSection(context, order, dark),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  /// Order Items Section
                  _buildOrderItemsSection(context, order, dark),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  /// Pricing Details Section
                  _buildPricingDetailsSection(context, order, dark),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderStatusSection(BuildContext context, OrderModel order, bool dark) {
    return TRoundedContainer(
      showBorder: true,
      padding: const EdgeInsets.all(TSizes.md),
      backgroundColor: dark ? TColors.dark : TColors.light,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                order.status == OrderStatus.delivered
                    ? Iconsax.tick_circle
                    : order.status == OrderStatus.shipped
                        ? Iconsax.ship
                        : Iconsax.timer_1,
                color: order.status == OrderStatus.delivered
                    ? Colors.green
                    : order.status == OrderStatus.shipped
                        ? Colors.blue
                        : Colors.orange,
              ),
              const SizedBox(width: TSizes.spaceBtwItems),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderStatusText,
                      style: Theme.of(context).textTheme.headlineSmall?.apply(
                            color: order.status == OrderStatus.delivered
                                ? Colors.green
                                : order.status == OrderStatus.shipped
                                    ? Colors.blue
                                    : Colors.orange,
                          ),
                    ),
                    Text(
                      'Order placed on ${order.formattedOrderDate}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoSection(BuildContext context, OrderModel order, bool dark) {
    return TRoundedContainer(
      showBorder: true,
      padding: const EdgeInsets.all(TSizes.md),
      backgroundColor: dark ? TColors.dark : TColors.light,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TSectionHeading(title: 'Order Information', showActionButton: false),
          const SizedBox(height: TSizes.spaceBtwItems),
          _buildInfoRow(context, 'Order ID:', order.id),
          _buildInfoRow(context, 'Order Date:', order.formattedOrderDate),
          _buildInfoRow(context, 'Delivery Date:', order.formattedDeliveryDate.isNotEmpty ? order.formattedDeliveryDate : 'TBD'),
          _buildInfoRow(context, 'Total Amount:', '\$${order.totalAmount.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget _buildShippingAddressSection(BuildContext context, OrderModel order, bool dark) {
    return TRoundedContainer(
      showBorder: true,
      padding: const EdgeInsets.all(TSizes.md),
      backgroundColor: dark ? TColors.dark : TColors.light,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TSectionHeading(title: 'Shipping Address', showActionButton: false),
          const SizedBox(height: TSizes.spaceBtwItems),
          if (order.address != null) ...[
            Text(
              order.address!.name,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: TSizes.spaceBtwItems / 2),
            Row(
              children: [
                const Icon(Icons.phone, color: Colors.grey, size: 16),
                const SizedBox(width: TSizes.spaceBtwItems / 2),
                Text(
                  order.address!.formattedPhoneNo,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwItems / 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: Colors.grey, size: 16),
                const SizedBox(width: TSizes.spaceBtwItems / 2),
                Expanded(
                  child: Text(
                    order.address!.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ] else
            Text(
              'No shipping address provided',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection(BuildContext context, OrderModel order, bool dark) {
    return TRoundedContainer(
      showBorder: true,
      padding: const EdgeInsets.all(TSizes.md),
      backgroundColor: dark ? TColors.dark : TColors.light,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TSectionHeading(title: 'Payment Method', showActionButton: false),
          const SizedBox(height: TSizes.spaceBtwItems),
          Row(
            children: [
              const Icon(Iconsax.card, color: Colors.grey, size: 20),
              const SizedBox(width: TSizes.spaceBtwItems / 2),
              Text(
                order.paymentMethod,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsSection(BuildContext context, OrderModel order, bool dark) {
    return TRoundedContainer(
      showBorder: true,
      padding: const EdgeInsets.all(TSizes.md),
      backgroundColor: dark ? TColors.dark : TColors.light,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TSectionHeading(title: 'Order Items (${order.items.length})', showActionButton: false),
          const SizedBox(height: TSizes.spaceBtwItems),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwItems),
            itemBuilder: (_, index) {
              final item = order.items[index];
              return Row(
                children: [
                  // Product Image
                  item.image != null
                      ? TCircularImage(
                          image: item.image!,
                          width: 60,
                          height: 60,
                          padding: TSizes.sm,
                          backgroundColor: dark ? TColors.darkerGrey : TColors.light,
                          fit: BoxFit.contain,
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          padding: const EdgeInsets.all(TSizes.sm),
                          decoration: BoxDecoration(
                            color: dark ? TColors.darkerGrey : TColors.light,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Icon(
                            Iconsax.image,
                            color: Colors.grey,
                            size: 24,
                          ),
                        ),
                  const SizedBox(width: TSizes.spaceBtwItems),

                  // Product Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.bodyLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems / 2),
                        if (item.selectedVariation != null && item.selectedVariation!.isNotEmpty)
                          Text(
                            'Variation: ${item.selectedVariation!.entries.map((e) => '${e.key}: ${e.value}').join(', ')}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        const SizedBox(height: TSizes.spaceBtwItems / 2),
                        Row(
                          children: [
                            Text(
                              'Amount: ${item.quantity}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const Spacer(),
                            Text(
                              '\$${item.price.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodyLarge?.apply(fontWeightDelta: 1),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPricingDetailsSection(BuildContext context, OrderModel order, bool dark) {
    return TRoundedContainer(
      showBorder: true,
      padding: const EdgeInsets.all(TSizes.md),
      backgroundColor: dark ? TColors.dark : TColors.light,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TSectionHeading(title: 'Pricing Details', showActionButton: false),
          const SizedBox(height: TSizes.spaceBtwItems),
          _buildPricingRow(context, 'SubTotal:', '\$${order.subTotal.toStringAsFixed(2)}'),
          _buildPricingRow(context, 'Shipping Fee:', '\$${order.shippingFee.toStringAsFixed(2)}'),
          _buildPricingRow(context, 'Tax Fee:', '\$${order.taxFee.toStringAsFixed(2)}'),
          const Divider(),
          _buildPricingRow(
            context,
            'Total Amount:',
            '\$${order.totalAmount.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              softWrap: false,
              style: Theme.of(context).textTheme.bodyMedium?.apply(color: Colors.grey),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingRow(BuildContext context, String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal ? Theme.of(context).textTheme.titleMedium : Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: isTotal ? Theme.of(context).textTheme.titleMedium?.apply(fontWeightDelta: 1) : Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
