import 'package:admin/screens/chat_list_screen.dart';
import 'package:admin/screens/voucher_screen.dart';
import 'package:flutter/material.dart';
import '../screens/edit_upload_product_form.dart';
import '../screens/inner_screen/orders/orders_screen.dart';
import '../screens/search_screen.dart';

class DashboardButtonsModel {
  final String text, imagePath;
  final Function onPressed;

  DashboardButtonsModel({
    required this.text,
    required this.imagePath,
    required this.onPressed,
  });

  static List<DashboardButtonsModel> dashboardBtnList(context) =>
      [
        DashboardButtonsModel(
          text: "Thêm sản phẩm",
          imagePath: "assets/images/addProduct.png",
          onPressed: () {
            Navigator.pushNamed(context, EditOrUploadProductScreen.routeName);
          },
        ),
        DashboardButtonsModel(
          text: "Sản phẩm của bạn",
          imagePath: "assets/images/shopShoes.png",
          onPressed: () {
            Navigator.pushNamed(context, SearchScreen.routeName);
          },
        ),
        DashboardButtonsModel(
          text: "Đơn đặt hàng",
          imagePath: "assets/images/shoesOrder.png",
          onPressed: () {
            Navigator.pushNamed(context, OrdersScreenFree.routeName);
          },
        ),
        DashboardButtonsModel(
          text: "Voucher",
          imagePath: "assets/images/iconvoucher.png",
          onPressed: () {
            Navigator.pushNamed(context, VoucherScreen.routName);
          },
        ),
        DashboardButtonsModel(
            text: "Chats", imagePath: "assets/images/chat.png", onPressed: () {
          Navigator.pushNamed(context, ChatListScreen.routName);
        })
      ];
}
