import 'package:admin/models/order_detail_model.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/products_provider.dart';
import '../../../../services/my_app_functions.dart';
import '../../../../widgets/subtitle_text.dart';
import '../../../../widgets/title_text.dart';

class OrderDetailWidget extends StatefulWidget {
  const OrderDetailWidget({super.key, required this.order});

  final OrderDetail order;

  @override
  State<OrderDetailWidget> createState() => _OrderDetailWidgetState();
}

class _OrderDetailWidgetState extends State<OrderDetailWidget> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery
        .of(context)
        .size;
    final productsProvider = Provider.of<ProductsProvider>(context);
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
                  imageUrl: widget.order.imageUrl,
                ),
              ),
              SubtitleTextWidget(
                label: "Size:${widget.order.size}",
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
                          label: widget.order.productTitle,
                          maxLines: 2,
                          fontSize: 15,
                        ),
                      ),
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
                          label:
                          "${MyAppFunctions.getPrice(widget.order.price)} vnđ",
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
                    label: "Sl:${widget.order.quantity}",
                    fontSize: 15,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const SizedBox(
                    height: 5,
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
