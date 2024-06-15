import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import '../../../const/app_constants.dart';
import '../../../models/order_model.dart';
import '../../../services/my_app_functions.dart';
import '../../../widgets/subtitle_text.dart';
import '../../../widgets/title_text.dart';

class OrderWidget extends StatefulWidget {
  const OrderWidget({super.key, required this.nOrder});

  final Order nOrder;

  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  bool isLoading = false;

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
                Container(
                  decoration:
                  BoxDecoration(border: Border.all(color: Colors.black)),
                  child: SizedBox(
                    height: 80,
                    width: 80,
                    child: Image.network(
                      widget.nOrder.displayProduct.imageUrl,
                      fit: BoxFit.scaleDown,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.nOrder.status,
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }
}

