import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import '../../../const/app_constants.dart';
import '../../../models/order_model.dart';
import '../../../services/my_app_functions.dart';
import '../../../widgets/subtitle_text.dart';
import '../../../widgets/title_text.dart';
import '../../../models/order_model.dart' as MyOrder; // Use 'as' to provide a prefix

class OrderWidget extends StatefulWidget {
  const OrderWidget({Key? key, required this.nOrder}) : super(key: key);

  final MyOrder.Order nOrder; // Use the prefix for the specific Order class

  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  late Future<String> _userNameFuture;

  @override
  void initState() {
    super.initState();
    _userNameFuture = getUserName(widget.nOrder.shopperId);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(
                  height: 80,
                  width: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FancyShimmerImage(
                      height: MediaQuery.of(context).size.width * 0.25,
                      width: MediaQuery.of(context).size.width * 0.25,
                      imageUrl: widget.nOrder.displayProduct.imageUrl,
                      boxFit: BoxFit.scaleDown,
                      shimmerBaseColor: Colors.grey[300]!,
                      shimmerHighlightColor: Colors.grey[100]!,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          widget.nOrder.displayProduct.productTitle,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16.0),
                        ),
                        Text(
                          "${MyAppFunctions.getPrice(widget.nOrder.displayProduct.price)} vnđ",
                          style: const TextStyle(fontSize: 16.0),
                        ),
                        Text(
                          "x${widget.nOrder.displayProduct.quantity}",
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          const Divider(
            indent: 4.0,
            endIndent: 4.0,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${widget.nOrder.quantity} sản phẩm",
                  style: const TextStyle(fontSize: 16.0),
                ),
                Text(
                  "Thành tiền: ${MyAppFunctions.getPrice(widget.nOrder.total)} vnđ",
                  style: const TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          ),
          const Divider(
            indent: 4.0,
            endIndent: 4.0,
          ),
          FutureBuilder<String>(
            future: _userNameFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(); // Hiển thị loading khi đang tải dữ liệu
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}'); // Hiển thị lỗi nếu có lỗi xảy ra
              } else {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Khách hàng: ${snapshot.data ?? 'Unknown User'}",
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.nOrder.status,
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ),

                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

Future<String> getUserName(String userId) async {
  var userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
  if (userDoc.exists) {
    return userDoc.data()?['userName'] ?? 'Unknown User';
  } else {
    return 'Unknown User';
  }
}