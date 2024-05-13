
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/order_provider.dart';
import '../../providers/products_provider.dart';
import '../screens/loading_manager.dart';
import '../services/my_app_functions.dart';

class RatingBarWidget extends StatefulWidget {
  const RatingBarWidget({super.key, required this.productRate, required this.isEditing, required this.rated});
  final ProductModel productRate;
  final bool isEditing;
  final double rated;
  @override
  State<RatingBarWidget> createState() => _RatingBarWidgetState();
}

class _RatingBarWidgetState extends State<RatingBarWidget> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {

    return LoadingManager(
      isLoading: _isLoading,
      child: RatingBar.builder(
        initialRating: !widget.isEditing ? widget.productRate.productRating.isEmpty ? 0 : ratingList(widget.productRate.productRating!) : (widget.rated) ,
        minRating: 1,
        direction: Axis.horizontal,
        allowHalfRating: true,
        unratedColor: Colors.amber.withAlpha(50),
        itemCount: 5,
        itemSize: 50.0,
        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
        itemBuilder: (context, _) => Icon(
          Icons.star,
          color: Colors.amber,
        ),
        onRatingUpdate: (rating) {
      },
        ignoreGestures: true,
      ),
    );
  }
  double ratingList(List temp) {
    double temp2 = 0;
    for (var element in temp) {
      temp2 += element;
    }
    return temp2 / temp.length;
  }
  Future<void> setRating(double rating) async {
    try {
      setState(() {
        _isLoading = true;
      });
      final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
      final ProductModel? product = productsProvider.findByProdId(widget.productRate.productId);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    } catch (error) {
      // Xử lý lỗi nếu có
      await MyAppFunctions.showErrorOrWarningDialog(
        context: context,
        subtitle: error.toString(),
        fct: () {},
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
