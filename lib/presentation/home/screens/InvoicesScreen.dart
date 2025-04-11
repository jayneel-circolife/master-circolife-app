import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../main.dart';
import '../../../utils/constants.dart';
import '../../../utils/secrets.dart';

class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key, required this.customerId, required this.userId});
  final String customerId;
  final String userId;

  Future getInvoicesByCustomer() async {
    return http.get(
        Uri.https(
          AppSecrets.baseUrl,
          '/api/invoice/$customerId/inv',
        ),
        headers: await _getHeaderConfig());
  }

  Future<Map<String, String>> _getHeaderConfig() async {
    String? token = await appStorage?.retrieveEncryptedData('token');
    Map<String, String> headers = {};
    headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers.putIfAbsent("Authorization", () => token);
    }
    return headers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Invoices"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          FutureBuilder(
              future: getInvoicesByCustomer(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                } else {
                  if (snapshot.data?.statusCode == 200) {
                    List<dynamic> data = jsonDecode(snapshot.data!.body)["data"];
                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        Map<String, dynamic> invoice = data[index];
                        bool isPaid = invoice["payment_status"] == "paid";
                        return ListTile(
                          title: Text("Rs.${invoice["subscription_price"]}"),
                          subtitle: Text(
                            isPaid ? "Paid" : "Unpaid",
                            style: TextStyle(color: isPaid ? const Color(0xFF1EAD12) : const Color(0xFFD01515), fontSize: 12),
                          ),
                          trailing: Text(invoice["current_payment_date"].toString().split("T")[0]),
                        );
                      },
                      itemCount: data.length,
                      shrinkWrap: true,
                    );
                  }
                  return Container();
                }
              })
        ],
      ),
    );
  }
}
