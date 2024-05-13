import 'dart:math';
import 'package:admin/screens/inner_screen/voucher_table.dart';
import 'package:admin/screens/loading_manager.dart';
import 'package:admin/widgets/subtitle_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../const/validator.dart';
import '../widgets/title_text.dart';

class VoucherScreen extends StatefulWidget {
  static const routName = "/PayScreen";

  const VoucherScreen({super.key});
  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
  bool _isLoading = false;
  late TextEditingController _discountController;

  @override
  void initState() {
    _discountController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.arrow_back_ios, size: 20),
          ),
          title: const TitlesTextWidget(label: "Voucher", fontSize: 22,),
        ),
        body: LoadingManager(
          isLoading: _isLoading,
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // Căn giữa theo chiều dọc
                crossAxisAlignment: CrossAxisAlignment.center,
                // Căn giữa theo chiều ngang
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Image.asset(
                    "assets/images/voucherPic.png",
                    width: size.width * 0.6,
                    height: size.width * 0.6,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TitlesTextWidget(label: "Tạo voucher", fontSize: 22,),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Center(
                          child: SubtitleTextWidget(
                            label: "% giảm giá",
                            textDecoration: TextDecoration.underline,
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: TextFormField(
                              key: const ValueKey('Nhập voucher'),
                              controller: _discountController,
                              textCapitalization: TextCapitalization.sentences,
                              keyboardType: TextInputType.number,
                              // Đặt loại bàn phím là số
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                                // Chỉ cho phép nhập số
                              ],
                              decoration: const InputDecoration(
                                hintText: 'Nhập % giảm giá (có dạng xx%)',
                              ),
                              validator: (value) {
                                return MyValidators.uploadProdTexts(
                                  value: value,
                                  toBeReturnedString: "Voucher hợp lệ",
                                );
                              },
                              onTap: () {}),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_discountController.text.isEmpty) {
                        return;
                      }
                      double discount = double.parse(_discountController.text);

                      String voucher = await generateShopVoucher(); // Gọi hàm generateShopVoucher() và chờ nó trả về giá trị voucher

                      try {
                        await FirebaseFirestore.instance
                            .collection('vouchers')
                            .add({
                          'discount': discount,
                          'value': voucher,
                          'userId': '', // Đảm bảo rằng userId được thiết lập thành một giá trị mặc định ở đây
                        });
                        Fluttertoast.showToast(msg: 'Voucher mới đã được tạo');
                        _discountController.clear();
                      } catch (error) {
                        print('Lỗi khi tải lên voucher: $error');
                      }
                    },
                    child: Text(
                      "Tạo mã",
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(
                    thickness: 1,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TitlesTextWidget(label: "Voucher của shop", fontSize: 22,),
                  const SizedBox(
                    height: 10,
                  ),
                  VoucherTable(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Future<String> generateShopVoucher() async {
    QuerySnapshot voucherSnapshot = await FirebaseFirestore.instance
        .collection('vouchers')
        .get();

    List<String> existingVouchers = [];
    voucherSnapshot.docs.forEach((doc) {
      existingVouchers.add(doc['value']);
    });

    Random random = Random();
    String voucher = "";
    bool isUnique = false;

    while (!isUnique) {
      voucher = "ps";
      for (int i = 0; i < 5; i++) {
        voucher += random.nextInt(10).toString();
      }
      if (!existingVouchers.contains(voucher)) {
        isUnique = true;
      }
    }

    return voucher; // Trả về mã voucher nếu tìm thấy mã duy nhất
    // Hoặc có thể trả về một giá trị mặc định khác ở đây nếu cần
  }
}
