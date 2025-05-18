import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:master_circolife_app/models/online_device_details.dart';
import 'package:master_circolife_app/utils/constants.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../main.dart';
import '../../../utils/secrets.dart';

class ConfigureDeviceScreen extends StatefulWidget {
  const ConfigureDeviceScreen({super.key, required this.deviceId, required this.deviceName, required this.device});
  final OnlineDeviceDetails device;
  final String deviceId;
  final String deviceName;
  // final Devices device;

  @override
  State<ConfigureDeviceScreen> createState() => _ConfigureDeviceScreenState();
}

class _ConfigureDeviceScreenState extends State<ConfigureDeviceScreen> {
  @override
  Widget build(BuildContext context) {
    TextEditingController phoneController = TextEditingController();
    // MqttManager mqtt = MqttManager();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.deviceName.toString()),
        actions: [
          IconButton(
              onPressed: () async {
                await showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Container(
                        width: double.maxFinite,
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                        decoration: const BoxDecoration(
                            color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Share device to",
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 23),
                            ),
                            Row(
                              children: [
                                Expanded(
                                    child: TextField(
                                  keyboardType: TextInputType.number,
                                  controller: phoneController,
                                  onTapOutside: (event) => FocusScope.of(context).unfocus(),
                                  decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      hintText: "Enter Customer No.",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      counterText: "",
                                      prefix: const Text(" +91  ")),
                                  maxLength: 10,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                )),
                                IconButton(
                                  onPressed: () async {
                                    if (phoneController.text.length == 10) {
                                      var headers = await _getHeaderConfig();
                                      var response = await http.get(Uri.https(AppSecrets.baseUrl, "/api/user/${phoneController.text}"), headers: headers);
                                      if (response.statusCode == 200 || response.statusCode == 201) {
                                        Map<String, dynamic> data = jsonDecode(response.body.toString());
                                        log(data["userid"], name: "UserDATA");
                                        log(widget.deviceId, name: "Device Id >");
                                        Map<String, dynamic> deviceData = {
                                          "userid": data["userid"],
                                          "deviceid": widget.deviceId,
                                          "deviceName": widget.deviceName,
                                          "isShared": false,
                                          "isadmin": true,
                                          "receiversid": "",
                                          "sendersName": "",
                                          "receiversName": "",
                                          "deviceType": "Split"
                                        };
                                        log(deviceData.toString(), name: "Payload");
                                        var deviceResponse =
                                            await http.post(Uri.https(AppSecrets.baseUrl, "/api/devices/"), body: jsonEncode(deviceData), headers: headers);
                                        if (deviceResponse.statusCode == 200 || deviceResponse.statusCode == 201) {
                                          Fluttertoast.showToast(msg: "Device Added Successfully");
                                          Navigator.pop(context);
                                        } else {
                                          log(deviceResponse.body.toString(), name: "Payload");
                                        }
                                      } else {
                                        Fluttertoast.showToast(msg: "User does not exists!");
                                      }
                                    } else {}
                                  },
                                  icon: const Icon(Icons.send_outlined),
                                  enableFeedback: true,
                                )
                              ],
                            ),
                          ],
                        ),
                      );
                    });
              },
              icon: const Icon(Icons.add_to_home_screen_rounded)),
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      bool startTimeSet = false;
                      TimeOfDay startTime = const TimeOfDay(hour: 11, minute: 0);
                      return StatefulBuilder(builder: (context, bottomState) {
                        return Container(
                          width: double.maxFinite,
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                          decoration: const BoxDecoration(
                              color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Select time"),
                              const SizedBox(
                                height: 5,
                              ),
                              InkWell(
                                onTap: () async {
                                  TimeOfDay? dt = await showTimePicker(context: context, initialTime: startTime);
                                  log(dt.toString(), name: "From Time >");
                                  bottomState(() {
                                    startTime = dt!;
                                    startTimeSet = true;
                                  });
                                  log(dt.toString(), name: "From Time >");
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFD6D6D6)),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                                  child: Text(
                                    startTime.format(context),
                                    style: TextStyle(
                                        color: startTimeSet ? const Color(0xFF1D2939) : const Color(0xFF667085),
                                        fontSize: 18,
                                        fontWeight: startTimeSet ? FontWeight.w600 : FontWeight.w400),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const Text("Slide to cut off Subscription"),
                              const SizedBox(
                                height: 5,
                              ),
                              SlideAction(
                                onSubmit: () {
                                  cutOffSubscription(widget.deviceId, context, "!suboffon");
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
                              const SizedBox(
                                height: 5,
                              ),
                              SlideAction(
                                onSubmit: () {
                                  cutOffSubscription(widget.deviceId, context, "!suboffoff");
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
                                              "E~${(expiryDate!.day).toString().padLeft(2, "0")}~${(expiryDate.month).toString().padLeft(2, "0")}~${expiryDate.year}~${(startTime.hour).toString().padLeft(2, "0")}";
                                          log(expiry, name: "Expiry Date >");
                                          cutOffSubscription(widget.deviceId, context, expiry);
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
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Icon(
            //       widget.device.isconnected ? Icons.wifi : Icons.wifi_off_rounded,
            //       color: widget.device.isconnected ? Colors.green : Colors.blueGrey,
            //     ),
            //     Text(
            //       widget.device.isconnected ? "Wifi Connected" : "Offline",
            //     )
            //   ],
            // ),
            Text("Firmware Version ${widget.device.firmwareVersion ?? "N/A"}"),
            const Text("Latest State"),
            FutureBuilder(
                future: http.get(Uri.https(AppSecrets.baseUrl, '/api/analItics/checdeviceStatus/getdeviceActive/${widget.deviceId}'), headers: headers),
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
                        String temp = commands.split("!tem")[1].substring(0, 2) ?? "";
                        return ListTile(
                            title: Text("Date: $date\t\t\tTime: $time"),
                            subtitle: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: (powerStatus) ? Colors.green : Colors.red, borderRadius: BorderRadius.circular(5)),
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
                  return const Text("No Data Found");
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
    final url = Uri.https(AppSecrets.baseUrl, "api/customers/masterapp/sendcommand");
    var headers = await _getHeaderConfig();
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
    } else {
      Fluttertoast.showToast(msg: "Issue Code > ${response.statusCode}");
    }
    await Future.delayed(const Duration(seconds: 1));
    if (command.startsWith("E~")) {
      var rebootResponse = await http.post(url,
          headers: headers,
          body: jsonEncode({
            "devices": [deviceId],
            "command": "!rbt"
          }));
      if (rebootResponse.statusCode == 201 || rebootResponse.statusCode == 200) {
        Fluttertoast.showToast(msg: "Rebooting");
      } else {
        Fluttertoast.showToast(msg: "Issue Code > ${rebootResponse.statusCode}");
      }
    }
  }

  Future<Map<String, String>> _getHeaderConfig() async {
    String? token = await appStorage?.retrieveEncryptedData('token');
    Map<String, String> headers = {};
    headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    log(token.toString(), name: "Token>>>>>>");
    if (token != null) {
      headers.putIfAbsent("Authorization", () => token);
    }
    log(headers.toString(), name: "IS EXISTING HEADERS");
    return headers;
  }
}
