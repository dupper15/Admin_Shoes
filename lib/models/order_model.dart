import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class DisplayProduct with ChangeNotifier {
  final String imageUrl;
  final String productTitle;
  final String price;
  final String quantity;

  DisplayProduct(
      {required this.imageUrl,
        required this.productTitle,
        required this.price,
        required this.quantity});
}

class Order with ChangeNotifier {
  final String shopperId;
  final String orderId;
  final String quantity;
  final String total;
  final Timestamp date;
  final String information;
  final int method;
  final String note;
  final String status;
  final DisplayProduct displayProduct;

  Order(
      {required this.shopperId,
        required this.orderId,
        required this.quantity,
        required this.total,
        required this.date,
        required this.information,
        required this.method,
        required this.note,
        required this.status,
        required this.displayProduct});
}
