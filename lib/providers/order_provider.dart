import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import '../models/order_model.dart';

class OrderProvider with ChangeNotifier {
  final List<NOrder> orders = [];

  List<NOrder> get getOrders => orders;

  Future<List<NOrder>> fetchNOrders() async {
    final auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    var uid = user!.uid;
    try {
      await FirebaseFirestore.instance
          .collection("orders")
          .where('shopperId', isEqualTo: uid)
          .orderBy("date", descending: false)
          .get()
          .then((orderSnapshot) {
        if (orderSnapshot.docs.isNotEmpty) {
          orders.clear();
          for (var element in orderSnapshot.docs) {
            var displayProduct = DisplayProduct(
                imageUrl: element.get("displayProduct.imageUrl"),
                productTitle: element.get("displayProduct.productTitle"),
                price: element.get("displayProduct.price"),
                quantity: element.get("displayProduct.quantity"));
            orders.insert(
                0,
                NOrder(
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
