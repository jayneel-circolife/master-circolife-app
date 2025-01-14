import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:master_circolife_app/presentation/home/screens/configure_device_screen.dart';
import 'package:master_circolife_app/utils/constants.dart';
import 'package:slide_to_act/slide_to_act.dart';

import '../../../utils/secrets.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key, required this.userId, required this.fullName});
  final String userId;
  final String fullName;

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  List<String> devices = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.fullName} Devices",
        ),
        actions: [
          IconButton(
              onPressed: () async {
                await showMenu(context: context, position: RelativeRect.fromLTRB(MediaQuery.of(context).size.width - 10, 0, 10, 0), items: [
                  PopupMenuItem(
                    child: const Text("Select All"),
                    onTap: () async {
                      log(devices.toString());
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
                                      cutOffSubscription(devices, context, "!suboffon");
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
                                      cutOffSubscription(devices, context, "!suboffoff");
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
                                              cutOffSubscription(devices, context, expiry);
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
                  )
                ]);
              },
              icon: const Icon(Icons.more_vert_rounded)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 5, 16, 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              FutureBuilder(
                  future: http.get(Uri.https(AppSecrets.baseUrl, '/api/devices/${widget.userId}'), headers: headers),
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
                          if (device['receiversid'] == "") {
                            devices.add(device['deviceid'].toString());
                            return ListTile(
                              title: Text(device['deviceName']),
                              subtitle: Text(device['deviceid']),
                              trailing: const Icon(Icons.arrow_forward_rounded),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ConfigureDeviceScreen(deviceId: device['deviceid'], deviceName: device['deviceName'])));
                              },
                            );
                          } else {
                            return Container();
                          }
                        },
                        itemCount: data.length,
                        shrinkWrap: true,
                      );
                    }
                    return Container(
                      height: 0,
                    );
                  }),
              FutureBuilder(
                  future: http.get(Uri.https(AppSecrets.baseUrl, '/api/devices/shared/${widget.userId}'), headers: headers),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container();
                    }
                    if (snapshot.data?.statusCode == 200) {
                      List<dynamic> data = jsonDecode(snapshot.data!.body);
                      return MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final device = data[index];
                            devices.add(device['deviceid'].toString());
                            return ListTile(
                              leading: const Icon(
                                Icons.group,
                                color: Colors.blue,
                              ),
                              title: Text(device['deviceName']),
                              subtitle: Text(device['deviceid']),
                              trailing: const Icon(Icons.arrow_forward_rounded),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ConfigureDeviceScreen(deviceId: device['deviceid'], deviceName: device['deviceName'])));
                              },
                            );
                          },
                          itemCount: data.length,
                          shrinkWrap: true,
                        ),
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

  void cutOffSubscription(List<String> deviceIds, BuildContext context, String command) async {
    await subscriptionOff(deviceIds, context, command);
  }

  Future<void> subscriptionOff(List<String> devices, BuildContext context, String command) async {
    final url = Uri.https(AppSecrets.baseUrl, "api/customers/b2blogin/sendcommand");
    var response = await http.post(url,
        headers: headers,
        body: jsonEncode({
          "devices": devices,
          "command": command
        }));
    if (response.statusCode == 201 || response.statusCode == 200) {
      if (command == "!suboffoff") {
        Fluttertoast.showToast(msg: "${devices.length} Ac Subscription Turned ON");
      } else if (command == "suboffon") {
        Fluttertoast.showToast(msg: "${devices.length} Ac Subscription Turned OFF");
      } else {
        Fluttertoast.showToast(msg: "${devices.length} AC Expiry $command Sent Successfully! ");
      }
    } else {
      Fluttertoast.showToast(msg: "Issue Code > ${response.statusCode}");
    }
  }
}
