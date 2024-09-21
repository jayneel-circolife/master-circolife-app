import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:master_circolife_app/presentation/home/screens/configure_device_screen.dart';

import '../../../utils/secrets.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key, required this.userId, required this.fullName});
  final String userId;
  final String fullName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "$fullName Devices",
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 5, 16, 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              FutureBuilder(
                  future: http.get(Uri.http(AppSecrets.baseUrl,'/api/devices/$userId'), headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                  }),
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
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => ConfigureDeviceScreen(deviceId: device['deviceid'], deviceName: device['deviceName'])));
                            },
                          );
                        },
                        itemCount: data.length,
                        shrinkWrap: true,
                      );
                    }
                    return Container(height: 0,);
                  }),
              FutureBuilder(
                  future: http.get(Uri.http(AppSecrets.baseUrl,'/api/devices/shared/$userId'), headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                  }),
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
                            leading: const Icon(Icons.group, color: Colors.blue,),
                            title: Text(device['deviceName']),
                            subtitle: Text(device['deviceid']),
                            trailing: const Icon(Icons.arrow_forward_rounded),
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => ConfigureDeviceScreen(deviceId: device['deviceid'], deviceName: device['deviceName'])));
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
          ),
        ),
      ),
    );
  }
}
