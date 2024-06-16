import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../widgets/empty_bag.dart';
import '../../../models/order_model.dart';
import '../../../providers/order_provider.dart';
import '../../../widgets/title_text.dart';
import 'order_detail/order_detail_screen.dart';
import 'orders_widget.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/NOrderScreen';

  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrdersScreen> {
  @override
  Widget build(BuildContext context) {
    final ordersListProvider = Provider.of<OrderProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: const TitlesTextWidget(
            label: 'Đơn hàng',
          ),
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4.0),
              child: Container(
                color: Colors.grey,
                height: 1.0,
              )),
        ),
        body: FutureBuilder<List<Order>>(
          future: ordersListProvider.fetchNOrders(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: SelectableText(snapshot.error.toString()),
              );
            } else if (!snapshot.hasData ||
                ordersListProvider.getOrders.isEmpty) {
              return const EmptyBagWidget(
                imagePath: 'assets/images/emptyn.png',
                title: "Chưa có sản phẩm nào được bán",
                subtitle: "",
              );
            }
            return ListView.separated(
              itemCount: snapshot.data!.length,
              itemBuilder: (ctx, index) {
                return GestureDetector(
                  onTap: () async {
                   await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OrderDetailScreen(
                                order: snapshot.data![index])));
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                    child: OrderWidget(nOrder: snapshot.data![index]),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(height: 4.0);
              },
            );
          },
        ));
  }
}
