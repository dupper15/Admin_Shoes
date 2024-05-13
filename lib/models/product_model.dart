import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductModel with ChangeNotifier {
  final String productId,
      productTitle,
      productPrice,
      productCategory,
      productDescription,
      productImage;
  final List<dynamic> productQuantity; // Sử dụng Map thay vì String
  final List productRating;
  Timestamp? createdAt;
  ProductModel({
    required this.productId,
    required this.productTitle,
    required this.productPrice,
    required this.productCategory,
    required this.productDescription,
    required this.productImage,
    required this.productQuantity, // Thay đổi kiểu dữ liệu thành Map
    required this.productRating,
    this.createdAt,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    // data.containsKey("")
    return ProductModel(
      productId: data["productId"], //doc.get(field),
      productTitle: data['productTitle'],
      productPrice: data['productPrice'],
      productCategory: data['productCategory'],
      productDescription: data['productDescription'],
      productImage: data['productImage'],
      productQuantity: data['productQuantity'], // Sử dụng dữ liệu từ map
      productRating: data['productRating'],
      createdAt: data['createdAt'],
    );
  }
}