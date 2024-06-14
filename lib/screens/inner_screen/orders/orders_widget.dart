import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import '../../../const/app_constants.dart';
import '../../../models/order_model.dart';
import '../../../services/my_app_functions.dart';
import '../../../widgets/subtitle_text.dart';
import '../../../widgets/title_text.dart';

class OrdersWidgetFree extends StatefulWidget {
  const OrdersWidgetFree({super.key, required this.ordersModelAdvanced});
  final OrdersModelAdvanced ordersModelAdvanced;
  @override
  State<OrdersWidgetFree> createState() => _OrdersWidgetFreeState();
}

class _OrdersWidgetFreeState extends State<OrdersWidgetFree> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        children: [
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FancyShimmerImage(
                  height: size.width * 0.25,
                  width: size.width * 0.25,
                  imageUrl: widget.ordersModelAdvanced.imageUrl,
                ),
              ),

              SubtitleTextWidget(
                label: "Size:${widget.ordersModelAdvanced.size}",
                fontSize: 15,
              ),

            ],
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: TitlesTextWidget(
                          label: widget.ordersModelAdvanced.productTitle,
                          maxLines: 2,
                          fontSize: 15,
                        ),
                      ),
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.clear,
                            color: Colors.red,
                            size: 22,
                          )),
                    ],
                  ),
                  Row(
                    children: [
                      const TitlesTextWidget(
                        label: 'Giá:  ',
                        fontSize: 15,
                      ),
                      Flexible(
                        child: SubtitleTextWidget(
                          label: "${MyAppFunctions.getPrice(widget.ordersModelAdvanced.price)} vnđ",
                          fontSize: 15,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  SubtitleTextWidget(
                    label: "Sl:${widget.ordersModelAdvanced.quantity}",
                    fontSize: 15,
                  ),

                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      const TitlesTextWidget(
                        label: 'Khách hàng:  ',
                        fontSize: 15,
                      ),
                      SubtitleTextWidget(
                        label: "${widget.ordersModelAdvanced.userName}",
                        fontSize: 15,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

