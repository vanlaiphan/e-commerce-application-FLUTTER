import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/constants/enums.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../personalization/models/address_model.dart';
import 'cart_item_model.dart';

class OrderModel {
  final String id;
  final String docId;
  final String userId;
  final OrderStatus status;
  final double totalAmount;
  final double subTotal;
  final double shippingFee;
  final double taxFee;
  final DateTime orderDate;
  final String paymentMethod;
  final AddressModel? address;
  final DateTime? deliveryDate;
  final List<CartItemModel> items;

  OrderModel({
    required this.id,
    this.docId = '',
    this.userId = '',
    required this.status,
    required this.items,
    required this.totalAmount,
    required this.subTotal,
    required this.shippingFee,
    required this.taxFee,
    required this.orderDate,
    this.paymentMethod = 'Paypal',
    this.address,
    this.deliveryDate,
  });

  String get formattedOrderDate => THelperFunctions.getFormattedDate(orderDate);

  String get formattedDeliveryDate => deliveryDate != null ? THelperFunctions.getFormattedDate(deliveryDate!) : '';

  String get orderStatusText => status == OrderStatus.delivered
      ? 'Delivered'
      : status == OrderStatus.shipped
          ? 'Shipment on the way'
          : 'Processing';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'docId': docId,
      'userId': userId,
      'status': status.toString(),
      'totalAmount': totalAmount,
      'subTotal': subTotal,
      'shippingFee': shippingFee,
      'taxFee': taxFee,
      'shippingCost': shippingFee,
      'taxCost': taxFee,
      'orderDate': orderDate,
      'paymentMethod': paymentMethod,
      'address': address?.toJson(),
      'shippingAddress': address?.toJson(),
      'billingAddress': address?.toJson(),
      'billingAddressSameAsShipping': true,
      'deliveryDate': deliveryDate,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  factory OrderModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return OrderModel(
      id: data['id'] as String? ?? '',
      docId: data['docId'] as String? ?? snapshot.id,
      // Use snapshot.id as docId
      userId: data['userId'] as String? ?? '',
      status: data['status'] != null ? OrderStatus.values.firstWhere((e) => e.toString() == data['status']) : OrderStatus.pending,
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      // Try both field names for compatibility
      subTotal: (data['subTotal'] as num?)?.toDouble() ?? 0.0,
      shippingFee: (data['shippingFee'] as num?)?.toDouble() ?? (data['shippingCost'] as num?)?.toDouble() ?? 0.0,
      taxFee: (data['taxFee'] as num?)?.toDouble() ?? (data['taxCost'] as num?)?.toDouble() ?? 0.0,
      orderDate: data['orderDate'] != null ? (data['orderDate'] as Timestamp).toDate() : DateTime.now(),
      paymentMethod: data['paymentMethod'] as String? ?? 'Paypal',
      // Try multiple address field names
      address: data['address'] != null
          ? AddressModel.fromMap(data['address'] as Map<String, dynamic>)
          : data['shippingAddress'] != null
              ? AddressModel.fromMap(data['shippingAddress'] as Map<String, dynamic>)
              : null,
      deliveryDate: data['deliveryDate'] != null ? (data['deliveryDate'] as Timestamp).toDate() : null,
      items: data['items'] != null
          ? (data['items'] as List<dynamic>).map((itemData) => CartItemModel.fromJson(itemData as Map<String, dynamic>)).toList()
          : [],
    );
  }
}
