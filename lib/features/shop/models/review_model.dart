import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  String id;
  String productId;
  String userId;
  String userName;
  String userImage;
  double rating;
  String comment;
  DateTime createdAt;
  String? companyReply;
  DateTime? companyReplyDate;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.companyReply,
    this.companyReplyDate,
  });

  static ReviewModel empty() => ReviewModel(
    id: '',
    productId: '',
    userId: '',
    userName: '',
    userImage: '',
    rating: 0.0,
    comment: '',
    createdAt: DateTime.now(),
  );

  Map<String, dynamic> toJson() {
    return {
      'ProductId': productId,
      'UserId': userId,
      'UserName': userName,
      'UserImage': userImage,
      'Rating': rating,
      'Comment': comment,
      'CreatedAt': Timestamp.fromDate(createdAt),
      'CompanyReply': companyReply,
      'CompanyReplyDate': companyReplyDate != null ? Timestamp.fromDate(companyReplyDate!) : null,
    };
  }

  factory ReviewModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() == null) return ReviewModel.empty();
    final data = document.data()!;
    return ReviewModel(
      id: document.id,
      productId: data['ProductId'] ?? '',
      userId: data['UserId'] ?? '',
      userName: data['UserName'] ?? '',
      userImage: data['UserImage'] ?? '',
      rating: double.parse((data['Rating'] ?? 0.0).toString()),
      comment: data['Comment'] ?? '',
      createdAt: (data['CreatedAt'] as Timestamp).toDate(),
      companyReply: data['CompanyReply'],
      companyReplyDate: data['CompanyReplyDate'] != null
          ? (data['CompanyReplyDate'] as Timestamp).toDate()
          : null,
    );
  }
}