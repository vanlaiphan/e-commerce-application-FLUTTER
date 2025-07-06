import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_store/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:t_store/common/widgets/texts/section_heading.dart';
import 'package:t_store/features/shop/controllers/product/checkout_controller.dart';
import 'package:t_store/utils/constants/colors.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';

class TBillingPaymentSection extends StatelessWidget {
  const TBillingPaymentSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = CheckoutController.instance;
    final dark = THelperFunctions.isDarkMode(context);

    return Column(
      children: [
        TSectionHeading(
          title: 'Payment Methods',
          buttonTitle: 'Change',
          onPressed: () => controller.selectPaymentMethod(context),
        ),
        const SizedBox(height: TSizes.spaceBtwItems / 2),
        Obx(
          () => Row(
            children: [
              TRoundedContainer(
                  width: 60,
                  height: 35,
                  backgroundColor: dark ? TColors.light : TColors.white,
                  padding: const EdgeInsets.all(TSizes.sm),
                  child: Image(image: AssetImage(controller.selectedPaymentMethod.value.image), fit: BoxFit.contain)),
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              Text(controller.selectedPaymentMethod.value.name, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        )
      ],
    );
  }
}
