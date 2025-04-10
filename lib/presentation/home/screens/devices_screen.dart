import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:master_circolife_app/models/user_details_model.dart';
import 'package:master_circolife_app/presentation/home/screens/configure_device_screen.dart';
import 'package:master_circolife_app/utils/constants.dart';
import 'package:slide_to_act/slide_to_act.dart';

import '../../../main.dart';
import '../../../models/online_device_details.dart';
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
  // var mqttsupport;
  // Box<Devices>? devicesBox;
  List<OnlineDeviceDetails> ownedDevices = [];
  List<OnlineDeviceDetails> sharedDevices = [];

  @override
  void initState() {
    super.initState();
    ownedDevices.clear();
    sharedDevices.clear();
    // devicesBox = Hive.box<Devices>("master");

    // devicesBox?.clear();
    // log("${devicesBox?.length.toString()}", name: "Device Length >");
    getAllDevices();
  }

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
                            bool startTimeSet = false;
                            TimeOfDay startTime = const TimeOfDay(hour: 8, minute: 0);
                            return StatefulBuilder(builder: (context, bottomState) {
                              return Container(
                                width: double.maxFinite,
                                padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                                decoration: const BoxDecoration(
                                    color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
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
                                                    "E~${(expiryDate!.day).toString().padLeft(2, "0")}~${(expiryDate.month).toString().padLeft(2, "0")}~${expiryDate.year}~${startTime.hour.toString().padLeft(2, "0")}";
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
              // FutureBuilder(
              //     future: http.get(Uri.https(AppSecrets.baseUrl, '/api/devices/${widget.userId}'), headers: headers),
              //     builder: (context, snapshot) {
              //       if (snapshot.connectionState == ConnectionState.waiting) {
              //         return const Center(child: CircularProgressIndicator());
              //       }
              //       if (snapshot.data?.statusCode == 200) {
              //         List<dynamic> data = jsonDecode(snapshot.data!.body);
              //         return ListView.builder(
              //           physics: const NeverScrollableScrollPhysics(),
              //           itemBuilder: (context, index) {
              //             final device = data[index];
              //             if (device['receiversid'] == "") {
              //               devices.add(device['deviceid'].toString());
              //               List<OnlineDeviceDetails> deviceslist =
              //                   json.decode(snapshot.data!.body).map<OnlineDeviceDetails>((json) => OnlineDeviceDetails.fromJson(json)).toList();
              //
              //               for (OnlineDeviceDetails device in deviceslist) {
              //                 if (device.isShared == false) {
              //                   Devices deviceData = Devices(
              //                     deviceId: device.deviceid!,
              //                     deviceType: device.deviceType ?? "Split",
              //                     deviceName: device.deviceName!,
              //                     deviceTemp: 24,
              //                     deviceStatus: true,
              //                     deviceMode: "Cooling",
              //                     isadmin: true,
              //                     fanspeed: 2,
              //                     did: device.did!,
              //                     sensordata: "",
              //                     econsumption: 0,
              //                     isconnected: false,
              //                   );
              //                   log(deviceData.deviceId.toString(), name: "Device ID>");
              //                   // Check if the device already exists in Hive
              //                   final existingDeviceIndex = devicesBox!.values.toList().indexWhere((d) => d.deviceId == device.deviceid);
              //
              //                   if (existingDeviceIndex != -1) {
              //                     // Update the existing device
              //                     devicesBox!.putAt(existingDeviceIndex, deviceData);
              //                   } else {
              //                     // Add the new device
              //                     devicesBox!.add(deviceData);
              //                   }
              //                 }
              //               }
              //               mqttsupport.onConnect();
              //
              //               return ListTile(
              //                 title: Text(device['deviceName']),
              //                 subtitle: Text(device['deviceid']),
              //                 trailing: const Icon(Icons.arrow_forward_rounded),
              //                 onTap: () {
              //                   Navigator.push(
              //                       context,
              //                       MaterialPageRoute(
              //                           builder: (context) => ConfigureDeviceScreen(deviceId: device['deviceid'], deviceName: device['deviceName'])));
              //                 },
              //               );
              //             } else {
              //               return Container();
              //             }
              //           },
              //           itemCount: data.length,
              //           shrinkWrap: true,
              //         );
              //       }
              //       return Container(
              //         height: 0,
              //       );
              //     }),
              // FutureBuilder(
              //     future: http.get(Uri.https(AppSecrets.baseUrl, '/api/devices/shared/${widget.userId}'), headers: headers),
              //     builder: (context, snapshot) {
              //       if (snapshot.connectionState == ConnectionState.waiting) {
              //         return Container();
              //       }
              //       if (snapshot.data?.statusCode == 200) {
              //         List<dynamic> data = jsonDecode(snapshot.data!.body);
              //         return MediaQuery.removePadding(
              //           context: context,
              //           removeTop: true,
              //           child: ListView.builder(
              //             physics: const NeverScrollableScrollPhysics(),
              //             itemBuilder: (context, index) {
              //               final device = data[index];
              //               devices.add(device['deviceid'].toString());
              //               return ListTile(
              //                 leading: const Icon(
              //                   Icons.group,
              //                   color: Colors.blue,
              //                 ),
              //                 title: Text(device['deviceName']),
              //                 subtitle: Text(device['deviceid']),
              //                 trailing: const Icon(Icons.arrow_forward_rounded),
              //                 onTap: () {
              //                   MqttManager mqtt = MqttManager();
              //                   Navigator.push(
              //                       context,
              //                       MaterialPageRoute(
              //                           builder: (context) => ConfigureDeviceScreen(deviceId: device['deviceid'], deviceName: device['deviceName'])));
              //                 },
              //               );
              //             },
              //             itemCount: data.length,
              //             shrinkWrap: true,
              //           ),
              //         );
              //       }
              //       return Container();
              //     }),
              MediaQuery.removePadding(
                context: context,
                removeTop: true,
                removeBottom: true,
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    OnlineDeviceDetails device = ownedDevices[index];
                    devices.add(device.deviceid.toString());
                    log(device.deviceid.toString(), name: "${device.deviceName.toString()} ->");
                    log(ownedDevices.length.toString(), name: "OWNED DEVICES ->");
                    // Devices ownedDevice = Devices(deviceId: device.deviceid.toString(), deviceType: device.deviceType.toString(), deviceName: device.deviceName.toString(), deviceTemp: 24, deviceStatus: true, deviceMode: "deviceMode", isadmin: true, fanspeed: 1, did: "", sensordata: "", isconnected: true, econsumption: 0.0);
                    // devicesBox?.add(ownedDevice);
                    return ListTile(
                      title: Text(device.deviceName.toString()),
                      subtitle: Text(device.deviceid.toString()),
                      trailing: const Icon(Icons.arrow_forward_rounded),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ConfigureDeviceScreen(
                                      deviceId: device.deviceid.toString(),
                                      deviceName: device.deviceName.toString(),
                                      device: device,
                                    )));
                      },
                    );
                  },
                  itemCount: ownedDevices.length,
                  shrinkWrap: true,
                ),
              ),
              MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    OnlineDeviceDetails device = sharedDevices[index];
                    devices.add(device.deviceid.toString());
                    log(device.deviceid.toString(), name: "${device.deviceName.toString()} ->");
                    log(sharedDevices.length.toString(), name: "SHARED DEVICES ->");
                    // Devices sharedDevice = Devices(deviceId: device.deviceid.toString(), deviceType: device.deviceType.toString(), deviceName: device.deviceName.toString(), deviceTemp: 24, deviceStatus: true, deviceMode: "deviceMode", isadmin: true, fanspeed: 1, did: "", sensordata: "", isconnected: true, econsumption: 0.0);
                    // devicesBox?.add(sharedDevice);
                    return ListTile(
                      leading: const Icon(
                        Icons.group,
                        color: Colors.blue,
                      ),
                      title: Text(device.deviceName.toString()),
                      subtitle: Text(device.deviceid.toString()),
                      trailing: const Icon(Icons.arrow_forward_rounded),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ConfigureDeviceScreen(
                                      deviceId: device.deviceid.toString(),
                                      deviceName: device.deviceName.toString(),
                                      device: device,
                                    )));
                      },
                    );
                  },
                  itemCount: sharedDevices.length,
                  shrinkWrap: true,
                ),
              ),
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
    var headers = await _getHeaderConfig();
    var response = await http.post(url, headers: headers, body: jsonEncode({"devices": devices, "command": command}));
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
    await Future.delayed(const Duration(seconds: 1));
    if (command.startsWith("E~")) {
      var rebootResponse = await http.post(url, headers: headers, body: jsonEncode({"devices": devices, "command": "!rbt"}));
      if (rebootResponse.statusCode == 201 || rebootResponse.statusCode == 200) {
        Fluttertoast.showToast(msg: "Rebooting ${devices.length} AC");
      } else {
        Fluttertoast.showToast(msg: "Issue Code > ${rebootResponse.statusCode}");
      }
    }
  }

  Future<void> getDevices() async {
    var url = Uri.parse('https://${AppSecrets.baseUrl}/api/devices/${widget.userId}');
    var headers = await _getHeaderConfig();
    var response = await http.get(
      url,
      headers: headers,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() {
        ownedDevices = json.decode(response.body).map<OnlineDeviceDetails>((json) => OnlineDeviceDetails.fromJson(json)).toList();
      });
    } else {
      Fluttertoast.showToast(msg: "Something went wrong");
    }
  }

  Future<void> getSharedDevices() async {
    var url = Uri.parse('https://${AppSecrets.baseUrl}/api/devices/shared/${widget.userId}');
    var headers = await _getHeaderConfig();
    var response = await http.get(
      url,
      headers: headers,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() {
        sharedDevices = json.decode(response.body).map<OnlineDeviceDetails>((json) => OnlineDeviceDetails.fromJson(json)).toList();
      });
    } else {
      Fluttertoast.showToast(msg: "Something went wrong");
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

  void getAllDevices() async {
    await getDevices();
    await getSharedDevices();
  }
}
