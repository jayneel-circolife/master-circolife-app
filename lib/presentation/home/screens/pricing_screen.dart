import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:master_circolife_app/presentation/home/screens/set_pricing_screen.dart';
import 'package:master_circolife_app/utils/constants.dart';
import 'dart:convert';
import 'package:master_circolife_app/utils/secrets.dart';

import '../../../main.dart';

class PricingScreen extends StatelessWidget {
  const PricingScreen({super.key, required this.userId});
  final String userId;


  Future getUserDevicesByPhoneNumber() async {
    return http.get(Uri.https(AppSecrets.baseUrl, '/api/devices/${userId}',), headers: await _getHeaderConfig());
  }

  Future getUserSharedDevicesByPhoneNumber() async {
    return http.get(Uri.https(AppSecrets.baseUrl, '/api/devices/${userId}',), headers: await _getHeaderConfig());
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
        title: const Text("Select Devices"),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 5, 16, 16),
        child: SingleChildScrollView(
            child: Column(
          children: [
            FutureBuilder(
                future: getUserDevicesByPhoneNumber(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data?.statusCode == 200 || snapshot.data?.statusCode == 201) {
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
                }),
            FutureBuilder(
                future: getUserSharedDevicesByPhoneNumber(),
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
                          leading: const Icon(
                            Icons.group,
                            color: Colors.blue,
                          ),
                          title: Text(device['deviceName']),
                          subtitle: Text(device['deviceid']),
                          trailing: const Icon(Icons.arrow_forward_rounded),
                          onTap: () {
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
                }),
          ],
        )),
      ),
    );
  }
}
