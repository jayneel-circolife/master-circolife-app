import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:master_circolife_app/utils/constants.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

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
                            const Text("Slide to cut off Subscription"),
                            SlideAction(
                              onSubmit: () {
                                cutOffSubscription(deviceId, context, "!suboffon");
                                return null;
                              },
                              borderRadius: 12,
                              elevation: 0,
                              innerColor: Colors.white,
                              outerColor: const Color(0xFFF34545),
                              sliderButtonIcon: const Icon(
                                Icons.cut,
                                color: Color(0xFFF34545),
                              ),
                              text: "Subscription OFF >>>",
                              textStyle: const TextStyle(fontSize: 16, color: Color(0xFFFFFFFF)),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const Text("Slide to resume Subscription"),
                            SlideAction(
                              onSubmit: () {
                                cutOffSubscription(deviceId, context, "!suboffoff");
                                return null;
                              },
                              borderRadius: 12,
                              elevation: 0,
                              innerColor: Colors.white,
                              outerColor: const Color(0xFF039855),
                              sliderButtonIcon: const Icon(
                                Icons.electric_bolt,
                                color: Color(0xFF039855),
                              ),
                              text: "Subscription ON >>>",
                              textStyle: const TextStyle(fontSize: 16, color: Color(0xFFFFFFFF)),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                ElevatedButton(
                                    onPressed: () async {
                                      DateTime dt = DateTime.now();
                                      DateTime? expiryDate = await showDatePicker(
                                          context: context, firstDate: DateTime(dt.year, dt.month, dt.day - 1), lastDate: DateTime(dt.year + 10));
                                      if (expiryDate != null) {
                                        String expiry =
                                            "E~${(expiryDate!.day).toString().padLeft(2, "0")}~${(expiryDate.month).toString().padLeft(2, "0")}~${expiryDate.year}";
                                        log(expiry, name: "Expiry Date >");
                                        cutOffSubscription(deviceId, context, expiry);
                                      }
                                    },
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [Text("Extend Expiry")],
                                    )),
                              ],
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Latest State"),
            FutureBuilder(
                future: http.get(Uri.https("production.circolife.vip", '/api/analItics/checdeviceStatus/getdeviceActive/$deviceId'), headers: headers),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data?.statusCode == 200 || snapshot.data?.statusCode == 201) {
                    List<dynamic> response = jsonDecode(snapshot.data!.body)['data'];
                    if (response.isEmpty) {
                      return const Center(
                        child: Text("No Data"),
                      );
                    }
                    return ListView.builder(
                      itemBuilder: (context, index) {
                        final data = response[index];
                        List<String> values = data['rawdata'].toString().split("-");
                        String commands = data['commandStatus'];

                        DateTime dateTime = DateTime.parse(data['lastdate'].toString());
                        String date = "${dateTime.day.toString()}-${dateTime.month.toString()}-${dateTime.year.toString()}";
                        String time =
                            "${dateTime.hour.toString()}:${dateTime.minute.toString()}:${dateTime.second.toString()} ${(dateTime.hour >= 12) ? "PM" : "AM"}";
                        bool powerStatus = (commands.contains("!on")) ? true : false;
                        String temp = commands.split("!tem")[1].substring(0,2) ?? "";
                        return ListTile(
                            title: Text("Date: $date\t\t\tTime: $time"),
                            subtitle: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration:
                                      BoxDecoration(color: (powerStatus) ? Colors.green : Colors.red, borderRadius: BorderRadius.circular(5)),
                                  child: Text(
                                    (powerStatus) ? "ON" : "OFF",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(5)),
                                  child: Text(
                                    "TEMP $temp°C",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ));
                      },
                      itemCount: response.length,
                      shrinkWrap: true,
                    );
                  }
                  return Text("No Data Found");
                })
          ],
        ),
      ),
    );
  }

  void cutOffSubscription(String deviceId, BuildContext context, String command) async {
    await subscriptionOff(deviceId, context, command);
  }

  Future<void> subscriptionOff(String deviceId, BuildContext context, String command) async {
    final url = Uri.https(AppSecrets.baseUrl, "api/customers/b2blogin/sendcommand");
    var response = await http.post(url,
        headers: headers,
        body: jsonEncode({
          "devices": [deviceId],
          "command": command
        }));
    if (response.statusCode == 201 || response.statusCode == 200) {
      if (command == "!suboffoff") {
        Fluttertoast.showToast(msg: "Ac Subscription Turned ON");
      } else if (command == "suboffon") {
        Fluttertoast.showToast(msg: "Ac Subscription Turned OFF");
      } else {
        Fluttertoast.showToast(msg: "Expiry $command Sent Successfully! ");
      }
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ac Subscription Turned OFF Successfully")));
    } else {
      Fluttertoast.showToast(msg: "Issue Code > ${response.statusCode}");
    }
  }
}
