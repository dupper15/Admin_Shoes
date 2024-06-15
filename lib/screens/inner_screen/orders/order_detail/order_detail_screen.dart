import 'package:admin/models/order_detail_model.dart';
import 'package:admin/screens/inner_screen/chats/util.dart';
import 'package:admin/screens/inner_screen/orders/order_detail/order_detail_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/order_model.dart';
import '../../../../providers/order_detail_provider.dart';
import '../../../../services/my_app_functions.dart';
import '../../../../widgets/empty_bag.dart';
import '../../../../widgets/title_text.dart';

class OrderDetailScreen extends StatefulWidget {
  static const routeName = '/OrderDetailScreen';
  final Order order;

  const OrderDetailScreen({required this.order, super.key});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool hasChanged = false;
  final TextEditingController statusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    statusController.text = widget.order.status;
  }

  @override
  Widget build(BuildContext context) {
    final ordersProvider = Provider.of<OrderDetailProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: const TitlesTextWidget(
            label: 'Thông tin đơn hàng',
          ),
          actions: <Widget>[
            IconButton(
                onPressed: hasChanged
                    ? () async {
                        await saveChanges(
                            widget.order, statusController.text, hasChanged);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Cập nhật thành công")));
                      }
                    : null,
                icon: const Icon(Icons.save))
          ],
        ),
        body: FutureBuilder<List<OrderDetail>>(
          future: ordersProvider.fetchOrder(widget.order.orderId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: SelectableText(snapshot.error.toString()),
              );
            } else if (!snapshot.hasData || ordersProvider.getOrders.isEmpty) {
              return const EmptyBagWidget(
                imagePath: 'images/emptyn.png',
                title: "Có vẻ như bạn chưa mua sản phẩm nào",
                subtitle: "",
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Địa chỉ nhận hàng: "),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(widget.order.information),
                      ),
                      const Divider(),
                      const Text("Ghi chú: : "),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(widget.order.note),
                      ),
                      const Divider(),
                      const Text("Trạng thái: : "),
                      DropdownButton(
                        items: const [
                          DropdownMenuItem(
                              value: "Đã nhận được thông tin",
                              child: Text("Đã nhận được thông tin")),
                          DropdownMenuItem(
                              value: "Đang đóng gói hàng",
                              child: Text("Đang đóng gói hàng")),
                          DropdownMenuItem(
                              value: "Đang vận chuyển hàng",
                              child: Text("Đang vận chuyển hàng")),
                          DropdownMenuItem(
                              value: "Đã gửi hàng thành công",
                              child: Text("Đã gửi hàng thành công")),
                        ],
                        value: statusController.text,
                        onChanged: (String? newValue) {
                          if (newValue != null &&
                              newValue != statusController.text) {
                            setState(() {
                              statusController.text = newValue;
                              if (newValue != widget.order.status) {
                                hasChanged = true;
                              } else {
                                hasChanged = false;
                              }
                            });
                          }
                        },
                      ),
                      const Divider()
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (ctx, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 2, vertical: 6),
                        child: OrderDetailWidget(order: snapshot.data![index]),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const Divider();
                    },
                  ),
                ),
                const Divider(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Phương thức thanh toán: "),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(getPaymentMethod(widget.order.method)),
                      ),
                      const Divider(),
                      const Text("Thành tiền: "),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(
                            "${MyAppFunctions.getPrice(widget.order.total)} vnđ"),
                      )
                    ],
                  ),
                )
              ],
            );
          },
        ));
  }
}

String getPaymentMethod(int method) {
  switch (method) {
    case 0:
      return "Thanh toán bằng Momo";
    case 1:
      return "Thanh toán bằng ngân hàng";
    case 2:
      return "Thanh toán bằng tiền mặt";
    default:
      return "Thanh toán bằng tiền mặt";
  }
}

Future<void> saveChanges(Order order, String status, bool hasChanged) async {
  await db.collection("orders").doc(order.orderId).update({
    'status': status,
  });
  hasChanged = false;
}
