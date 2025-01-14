import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../utils/constants.dart';
import '../../../utils/secrets.dart';

class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key, required this.customerId, required this.userId});
  final String customerId;
  final String userId;

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
              future: http.get(
                  Uri.https(
                    AppSecrets.baseUrl,
                    '/api/customer/$userId',
                  ),
                  headers: headers),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                } else {
                  if (snapshot.data?.statusCode == 200) {
                    List<dynamic> data = jsonDecode(snapshot.data!.body);
                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        Map<String, dynamic> invoice = data[index];
                        return ListTile(
                          title: Text("Rs.${invoice["price"]}"),
                          trailing: Text(invoice["date"]),
                          onTap: (){

                          },
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {

        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
