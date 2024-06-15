import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class OrderDetail with ChangeNotifier {
  final String orderItemId;
  final String orderId;
  final String userId;
  final String productId;
  final String productTitle;
  final String userName;
  final String price;
  final String imageUrl;
  final String quantity;
  final double isRated;
  final String size;
  final String information;
  final String note;
  final int method;
  final int getShoes;
  final Timestamp orderDate;

  OrderDetail(
      {required this.orderItemId,
        required this.orderId,
        required this.userId,
        required this.productId,
        required this.productTitle,
        required this.userName,
        required this.price,
        required this.imageUrl,
        required this.quantity,
        required this.isRated,
        required this.size,
        required this.information,
        required this.note,
        required this.getShoes,
        required this.method,
        required this.orderDate});
}