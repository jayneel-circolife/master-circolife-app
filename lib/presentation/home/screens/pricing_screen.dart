import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:master_circolife_app/presentation/home/screens/SetPricingScreen.dart';
import 'dart:convert';
import 'package:master_circolife_app/utils/secrets.dart';

class PricingScreen extends StatelessWidget {
  const PricingScreen({super.key, required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Devices"),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          FutureBuilder(
              future: http.get(Uri.http(AppSecrets.baseUrl, '/api/devices/$userId')),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data?.statusCode == 200) {
                  List<dynamic> data = jsonDecode(snapshot.data!.body);
                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final device = data[index];
                      return ListTile(
                        title: Text(device['deviceName']),
                        subtitle: Text(device['deviceid']),
                        trailing: const Icon(Icons.arrow_forward_rounded),
                        onTap: () {
                          log(device['deviceid'].toString(), name: "Device ID");
                          log(device['deviceName'].toString(), name: "Device Name");
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => SetPricingScreen(deviceId: device['deviceid'], deviceName: device['deviceName'])));
                        },
                      );
                    },
                    itemCount: data.length,
                    shrinkWrap: true,
                  );
                }
                return Container();
              })
        ],
      )),
    );
  }
}
