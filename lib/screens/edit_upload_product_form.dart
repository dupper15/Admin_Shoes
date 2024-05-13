import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../const/app_constants.dart';
import '../const/validator.dart';
import '../models/product_model.dart';
import '../services/my_app_functions.dart';
import '../widgets/subtitle_text.dart';
import '../widgets/title_text.dart';
import 'loading_manager.dart';

class EditOrUploadProductScreen extends StatefulWidget {
  static const routeName = '/EditOrUploadProductScreen';

  const EditOrUploadProductScreen({super.key, this.productModel});

  final ProductModel? productModel;

  @override
  State<EditOrUploadProductScreen> createState() =>
      _EditOrUploadProductScreenState();
}

class _EditOrUploadProductScreenState extends State<EditOrUploadProductScreen> {
  final _formKey = GlobalKey<FormState>();
  XFile? _pickedImage;
  late TextEditingController _titleController,
      _priceController,
      _descriptionController,
      _quantityController,
      _sizeController;
  String? _categoryValue;
  bool isEditing = false;
  String? productNetworkImage;
  bool _isLoading = false;
  String? productImageUrl;

  @override
  void initState() {
    if (widget.productModel != null) {
      isEditing = true;
      productNetworkImage = widget.productModel!.productImage;
      _categoryValue = widget.productModel!.productCategory;
    }
    _titleController =
        TextEditingController(text: widget.productModel?.productTitle);
    _priceController =
        TextEditingController(text: widget.productModel?.productPrice);
    _descriptionController =
        TextEditingController(text: widget.productModel?.productDescription);
    _quantityController =
        TextEditingController(text: '');
    _sizeController =
        TextEditingController(text: '');
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  void clearForm() {
    _titleController.clear();
    _priceController.clear();
    _descriptionController.clear();
    _quantityController.clear();
    _sizeController.clear();
    removePickedImage();
  }

  void removePickedImage() {
    setState(() {
      _pickedImage = null;
      productNetworkImage = null;
    });
  }

  Future<void> _uploadProduct() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (_pickedImage == null) {
      MyAppFunctions.showErrorOrWarningDialog(
          context: context, subtitle: "Vui lòng chọn ảnh", fct: () {});
      return;
    }
    if (isValid) {
      try {
        setState(() {
          _isLoading = true;
        });
        final snapshot = await FirebaseFirestore.instance
            .collection("products")
            .where('productTitle', isEqualTo: _titleController.text)
            .get();

        final productId = const Uuid().v4();


        final existingData = snapshot.docs.isNotEmpty ? snapshot.docs.first.data() : null;

        if (existingData != null) {
          List<Map<String, dynamic>> productQuantity =
          List<Map<String, dynamic>>.from(existingData['productQuantity'] ?? []);
          bool found = false;

          for (int i = 0; i < productQuantity.length; i++) {
            if (productQuantity[i]['size'] == _sizeController.text) {
              productQuantity[i]['productQuantity'] =
                  (int.parse(productQuantity[i]['productQuantity']) +
                      int.parse(_quantityController.text))
                      .toString();
              await FirebaseFirestore.instance
                  .collection("products")
                  .doc(snapshot.docs.first.id)
                  .update({
                'productQuantity.$i.productQuantity': productQuantity[i]['productQuantity'],
              });

              found = true;
              break;
            }
          }

          if (!found) {
            productQuantity.add({
              'size': _sizeController.text,
              'productQuantity': _quantityController.text,
            });
          }
          await FirebaseFirestore.instance
              .collection("products")
              .doc(snapshot.docs.first.id)
              .update({
            'productQuantity': productQuantity,
          });
        }
        if(snapshot.docs.isEmpty) {
          final ref = FirebaseStorage.instance
              .ref()
              .child("productsImages")
              .child("$productId.jpg");
          await ref.putFile(File(_pickedImage!.path));
          productImageUrl = await ref.getDownloadURL();
          List<Map<String, dynamic>> productQuantity = [
            {
              'size': _sizeController.text,
              'productQuantity': _quantityController.text,
            }
          ];
          await FirebaseFirestore.instance.collection("products").doc(productId).set({
            'productId': productId,
            'productTitle': _titleController.text,
            'productPrice': _priceController.text,
            'productImage': productImageUrl,
            'productCategory': _categoryValue,
            'productDescription': _descriptionController.text,
            'productQuantity': productQuantity,
            'productRating': [],
            'createdAt': Timestamp.now(),
          });
        }
        Fluttertoast.showToast(
          msg: "Sản phẩm đã được thêm vào",
          textColor: Colors.white,
        );
        if (!mounted) return;
        MyAppFunctions.showErrorOrWarningDialog(
            isError: false,
            context: context,
            subtitle: "Bạn có muốn làm mới thông tin?",
            fct: () {
              clearForm();
            });
      } on FirebaseException catch (error) {
        await MyAppFunctions.showErrorOrWarningDialog(
          context: context,
          subtitle: error.message.toString(),
          fct: () {},
        );
      } catch (error) {
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

  Future<void> _editProduct() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (_pickedImage == null && productNetworkImage == null) {
      MyAppFunctions.showErrorOrWarningDialog(
        context: context,
        subtitle: "Vui lòng chọn ảnh",
        fct: () {},
      );
      return;
    }
    if (isValid) {
      try {
        setState(() {
          _isLoading = true;
        });

        if (_pickedImage != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child("productsImages")
              .child("${widget.productModel!.productId}.jpg");
          await ref.putFile(File(_pickedImage!.path));
          productImageUrl = await ref.getDownloadURL();
        }

        // Lấy dữ liệu sản phẩm hiện tại
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection("products")
            .doc(widget.productModel!.productId)
            .get();
        Map<String, dynamic> existingData =
        snapshot.data() as Map<String, dynamic>;

        // Cập nhật thông tin sản phẩm
        Map<String, dynamic> updatedProduct = {
          'productId': widget.productModel!.productId,
          'productTitle': _titleController.text,
          'productPrice': _priceController.text,
          'productImage': productImageUrl ?? productNetworkImage,
          'productCategory': _categoryValue,
          'productDescription': _descriptionController.text,
          'createdAt': widget.productModel!.createdAt,
        };

        // Cập nhật productQuantity
        List<Map<String, dynamic>> productQuantity =
        List<Map<String, dynamic>>.from(existingData['productQuantity'] ??
            []); // Sao chép danh sách hiện tại

        String existingSize = _sizeController.text;
        String existingProductQuantityText = _quantityController.text;
        int newQuantity = int.parse(existingProductQuantityText);

        // Tìm và cập nhật hoặc thêm mới thông tin size và quantity
        bool found = false;
        for (int i = 0; i < productQuantity.length; i++) {
          if (productQuantity[i]['size'] == existingSize) {
            productQuantity[i]['productQuantity'] =
                newQuantity.toString(); // Cập nhật quantity nếu đã tồn tại size
            found = true;
            break;
          }
        }

        // Nếu không tìm thấy size trong danh sách, thêm mới
        if (!found) {
          productQuantity.add({
            'size': existingSize,
            'productQuantity': newQuantity.toString(),
          });
        }

        // Cập nhật thông tin sản phẩm với productQuantity mới
        updatedProduct['productQuantity'] = productQuantity;

        // Thực hiện cập nhật
        await FirebaseFirestore.instance
            .collection("products")
            .doc(widget.productModel!.productId)
            .update(updatedProduct);

        Fluttertoast.showToast(
          msg: "Sản phẩm đã được sửa đổi",
          textColor: Colors.white,
        );

        if (!mounted) return;
        MyAppFunctions.showErrorOrWarningDialog(
          isError: false,
          context: context,
          subtitle: "Bạn có muốn làm mới thông tin?",
          fct: () {
            clearForm();
          },
        );
      } on FirebaseException catch (error) {
        await MyAppFunctions.showErrorOrWarningDialog(
          context: context,
          subtitle: error.message.toString(),
          fct: () {},
        );
      } catch (error) {
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

  Future<void> localImagePicker() async {
    final ImagePicker picker = ImagePicker();
    await MyAppFunctions.imagePickerDialog(
      context: context,
      cameraFCT: () async {
        _pickedImage = await picker.pickImage(source: ImageSource.camera);
        setState(() {
          productNetworkImage == null;
        });
      },
      galleryFCT: () async {
        _pickedImage = await picker.pickImage(source: ImageSource.gallery);
        setState(() {
          productNetworkImage == null;
        });
      },
      removeFCT: () {
        setState(() {
          _pickedImage = null;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return LoadingManager(
      isLoading: _isLoading,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          bottomSheet: SizedBox(
            height: kBottomNavigationBarHeight + 10,
            child: Material(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                    ),
                    icon: const Icon(
                      Icons.clear,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Xóa",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      clearForm();
                    },
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.upload),
                    label: Text(
                      isEditing ? "Sửa sản phẩm" : "Thêm sản phẩm",
                    ),
                    onPressed: () {
                      if (isEditing) {
                        _editProduct();
                      } else {
                        _uploadProduct();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          appBar: AppBar(
            centerTitle: true,
            title: TitlesTextWidget(
              label: isEditing ? "Sửa sản phẩm" : "Thêm sản phẩm",
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  if (isEditing && productNetworkImage != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        productNetworkImage!,
                        height: size.width * 0.5,
                        alignment: Alignment.center,
                      ),
                    ),
                  ] else if (_pickedImage == null) ...[
                    SizedBox(
                      width: size.width * 0.4 + 10,
                      height: size.width * 0.4,
                      child: DottedBorder(
                          child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.image_outlined,
                              size: 80,
                              color: Colors.blue,
                            ),
                            TextButton(
                              onPressed: () {
                                localImagePicker();
                              },
                              child: const Text("Thêm hình ảnh"),
                            ),
                          ],
                        ),
                      )),
                    ),
                  ] else ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(
                          _pickedImage!.path,
                        ),
                        // width: size.width * 0.7,
                        height: size.width * 0.5,
                        alignment: Alignment.center,
                      ),
                    ),
                  ],
                  if (_pickedImage != null || productNetworkImage != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            localImagePicker();
                          },
                          child: const Text("Chọn ảnh khác"),
                        ),
                        TextButton(
                          onPressed: () {
                            removePickedImage();
                          },
                          child: const Text(
                            "Xóa ảnh",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    )
                  ],
                  const SizedBox(
                    height: 25,
                  ),
                  // Category dropdown widget
                  DropdownButton(
                      items: AppConstants.categoriesDropDownList,
                      value: _categoryValue,
                      hint: const Text("Thương hiệu"),
                      onChanged: (String? value) {
                        setState(() {
                          _categoryValue = value;
                        });
                      }),
                  const SizedBox(
                    height: 25,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _titleController,
                            key: const ValueKey('Title'),
                            maxLength: 80,
                            minLines: 1,
                            maxLines: 2,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            decoration: const InputDecoration(
                              hintText: 'Tên sản phẩm',
                            ),
                            validator: (value) {
                              return MyValidators.uploadProdTexts(
                                value: value,
                                toBeReturnedString:
                                    "Vui lòng nhập tên sản phẩm ",
                              );
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 2,
                                child: TextFormField(
                                  textAlign: TextAlign.left,
                                  controller: _priceController,
                                  key: const ValueKey('Price \$'),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^(\d+)?\.?\d{0,2}'),
                                    ),
                                  ],
                                  decoration: const InputDecoration(
                                      hintText: 'Giá',
                                      prefix: SubtitleTextWidget(
                                        label: "vnđ ",
                                        color: Colors.blue,
                                        fontSize: 16,
                                      )),
                                  validator: (value) {
                                    return MyValidators.uploadProdTexts(
                                      value: value,
                                      toBeReturnedString:
                                          "Giá tiền không hợp lệ",
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  controller: _quantityController,
                                  keyboardType: TextInputType.number,
                                  key: const ValueKey('Quantity'),
                                  decoration: const InputDecoration(
                                    hintText: 'Số lượng',
                                  ),
                                  validator: (value) {
                                    return MyValidators.uploadProdTexts(
                                      value: value,
                                      toBeReturnedString:
                                          "Số lượng không hợp lệ",
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  controller: _sizeController,
                                  keyboardType: TextInputType.number,
                                  key: const ValueKey('Size'),
                                  decoration: const InputDecoration(
                                    hintText: 'Size',
                                  ),
                                  validator: (value) {
                                    return MyValidators.uploadProdTexts(
                                      value: value,
                                      toBeReturnedString: "Size không hợp lệ",
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            key: const ValueKey('Description'),
                            controller: _descriptionController,
                            minLines: 5,
                            maxLines: 15,
                            maxLength: 2000,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              hintText: 'Mô tả',
                            ),
                            validator: (value) {
                              return MyValidators.uploadProdTexts(
                                value: value,
                                toBeReturnedString: "Mô tả không hợp lệ",
                              );
                            },
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: kBottomNavigationBarHeight + 10,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
