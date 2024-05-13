import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VoucherTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('vouchers').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator(); // Hiển thị tiêu chí chờ nếu dữ liệu chưa được tải
          }
          final vouchers = snapshot.data!.docs;

          // Xây dựng DataTable từ dữ liệu vouchers
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text('Mã voucher',style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600),)),
                DataColumn(label: Text('Được giảm',style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600))),
                DataColumn(label: Text('Đã nhận',style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600))),
              ],
              rows: vouchers.map((voucher) {
                final voucherData = voucher.data() as Map<String, dynamic>;
                final voucherName = voucherData['value'];
                final discountPercentage = voucherData['discount'].toInt().toStringAsFixed(0);
            
                return DataRow(
                    cells: [
                  DataCell(Text(voucherName)),
                  DataCell(Text('$discountPercentage%')),
                  DataCell(
                    FutureBuilder<String>(
                      future: getUserName(voucherData['userId'] ?? ''),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        if (snapshot.hasData) {
                          return Text(snapshot.data!);
                        } else {
                          return Text('');
                        }
                      },
                    ),
                  ),
                ]);
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Future<String> getUserName(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        return userDoc.get('userName');
      } else {
        return '';
      }
    } catch (error) {
      print('Error: $error');
      return '';
    }
  }
}