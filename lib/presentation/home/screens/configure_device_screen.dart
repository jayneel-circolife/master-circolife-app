import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:slide_to_act/slide_to_act.dart';
import 'dart:developer';
import 'dart:convert';

import '../../../utils/secrets.dart';

class ConfigureDeviceScreen extends StatelessWidget {
  const ConfigureDeviceScreen({super.key, required this.deviceId, required this.deviceName});
  final String deviceId;
  final String deviceName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(deviceName),
        actions: [
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Container(
                        width: double.maxFinite,
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                        decoration: const BoxDecoration(
                            color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SlideAction(
                              onSubmit: () {
                                AlertDialog(
                                  title: const Text("Are you sure you want to cut the subscription?"),
                                  actions: [
                                    TextButton(onPressed: (){}, child: const Text("OK"))
                                  ],
                                );
                                return null;
                              },
                              borderRadius: 12,
                              elevation: 0,
                              innerColor: Colors.white,
                              outerColor:  const Color(0xFF039855) ,
                              sliderButtonIcon: const Icon(
                                Icons.electric_bolt,
                                color:  Color(0xFF039855),
                              ),
                              text: "Subscription OFF >>>",
                              textStyle: const TextStyle(fontSize: 16, color: Color(0xFFFFFFFF)),
                            )
                          ],
                        ),
                      );
                    });
              },
              icon: const Icon(Icons.settings))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FutureBuilder(
                future: http.get(Uri.http(AppSecrets.baseUrl, '/api/analitics/bydays/5&$deviceId')),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data?.statusCode == 200) {
                    log(snapshot.data!.body.toString(), name: "Response >");
                    List<dynamic> response = jsonDecode(snapshot.data!.body);
                    if (response.isEmpty) {
                      return const Center(
                        child: Text("No Data"),
                      );
                    }
                    return ListView.builder(
                      itemBuilder: (context, index) {
                        final data = response[index];
                        DateTime dateTime = DateTime.parse(data['lastdate'].toString());
                        String date = "${dateTime.day.toString()}-${dateTime.month.toString()}-${dateTime.year.toString()}";
                        String time =
                            "${dateTime.hour.toString()}:${dateTime.minute.toString()}:${dateTime.second.toString()} ${(dateTime.hour >= 12) ? "PM" : "AM"}";
                        return ListTile(
                          title: Text(date),
                          trailing: Text(time),
                          subtitle: Text(data['rawdata']),
                        );
                      },
                      itemCount: response.length,
                      shrinkWrap: true,
                    );
                  }
                  return Container();
                })
          ],
        ),
      ),
    );
  }
}
