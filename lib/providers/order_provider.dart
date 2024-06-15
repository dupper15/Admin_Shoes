import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../models/order_model.dart' as ord;

class OrderProvider with ChangeNotifier {
  final List<ord.Order> orders = [];

  List<ord.Order> get getOrders => orders;

  Future<List<ord.Order>> fetchNOrders() async {
    try {
      await FirebaseFirestore.instance
          .collection("orders")
          .orderBy("date", descending: false)
          .get()
          .then((orderSnapshot) {
        if (orderSnapshot.docs.isNotEmpty) {
          orders.clear();
          for (var element in orderSnapshot.docs) {
            var displayProduct = ord.DisplayProduct(
                imageUrl: element.get("displayProduct.imageUrl"),
                productTitle: element.get("displayProduct.productTitle"),
                price: element.get("displayProduct.price"),
                quantity: element.get("displayProduct.quantity"));
            orders.insert(
                0,
                ord.Order(
                    orderId: element.get('orderId'),
                    shopperId: element.get('shopperId'),
                    total: element.get('total').toString(),
                    quantity: element.get('quantity').toString(),
                    status: element.get('status'),
                    date: element.get('date'),
                    information: element.get("information"),
                    method: element.get("method"),
                    note: element.get("note"),
                    displayProduct: displayProduct));
          }
        }
      });
      return orders;
    } catch (e) {
      rethrow;
    }
  }
}
