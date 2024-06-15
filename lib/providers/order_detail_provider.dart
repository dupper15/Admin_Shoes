import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../models/order_detail_model.dart';

class OrderDetailProvider with ChangeNotifier {
  final List<OrderDetail> orders = [];

  List<OrderDetail> get getOrders => orders;

  Future<List<OrderDetail>> fetchOrder(String orderId) async {
    try {
      await FirebaseFirestore.instance
          .collection("ordersAdvanced")
          .orderBy("productTitle", descending: false)
          .get()
          .then((orderSnapshot) {
        orders.clear();
        for (var element in orderSnapshot.docs) {
          orders.insert(
              0,
              OrderDetail(
                  orderItemId: element.get('orderItemId'),
                  orderId: element.get('orderId'),
                  productId: element.get('productId'),
                  userId: element.get('userId'),
                  price: element.get('price').toString(),
                  productTitle: element.get('productTitle').toString(),
                  quantity: element.get('quantity').toString(),
                  imageUrl: element.get('imageUrl'),
                  userName: element.get('userName'),
                  isRated: element.get('isRated'),
                  size: element.get('size'),
                  method: element.get('method'),
                  getShoes: element.get('getShoes'),
                  information: element.get('information'),
                  note: element.get('note'),
                  orderDate: element.get('orderDate')));
        }
      });
      return orders;
    } catch (e) {
      rethrow;
    }
  }
}
