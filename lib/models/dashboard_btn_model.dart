import 'package:flutter/material.dart';
import '../screens/edit_upload_product_form.dart';
import '../screens/inner_screen/orders/orders_screen.dart';
import '../screens/search_screen.dart';
import '../services/assets_manager.dart';

class DashboardButtonsModel {
  final String text, imagePath;
  final Function onPressed;

  DashboardButtonsModel({
    required this.text,
    required this.imagePath,
    required this.onPressed,
  });

  static List<DashboardButtonsModel> dashboardBtnList(context) => [
    DashboardButtonsModel(
      text: "Add a new product",
      imagePath: "assets/images/categories/pc.png",
      onPressed: () {
        Navigator.pushNamed(context, EditOrUploadProductScreen.routeName);
      },
    ),
    DashboardButtonsModel(
      text: "inspect all products",
      imagePath: "assets/images/bag/shopping_cart.png",
      onPressed: () {
        Navigator.pushNamed(context, SearchScreen.routeName);
      },
    ),
    DashboardButtonsModel(
      text: "View Orders",
      imagePath: "assets/images/bag/order.png",
      onPressed: () {
        Navigator.pushNamed(context, OrdersScreenFree.routeName);
      },
    ),
  ];
}
