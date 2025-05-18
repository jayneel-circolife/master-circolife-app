import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:master_circolife_app/models/user_details_model.dart';
import 'package:master_circolife_app/presentation/home/screens/configure_device_screen.dart';
import 'package:master_circolife_app/utils/constants.dart';
import 'package:master_circolife_app/widgets/device_id_text_field.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:provider/provider.dart';
import 'package:slide_to_act/slide_to_act.dart';

import '../../../main.dart';
import '../../../models/online_device_details.dart';
import '../../../provider/mqtt_manager.dart';
import '../../../utils/secrets.dart';
import '../../../widgets/button_styles.dart';
import 'home_screen.dart';

List<OnlineDeviceDetails> allDevices = [];

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key, required this.userId, required this.fullName});
  final String userId;
  final String fullName;

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  Map<String, OnlineDeviceDetails> deviceLookup = {};
  List<String> devices = [];
  List<OnlineDeviceDetails> ownedDevices = [];
  List<OnlineDeviceDetails> sharedDevices = [];
  TextEditingController deviceIdController = TextEditingController();
  TextEditingController deviceNameController = TextEditingController();
  var mqttClient;

  @override
  void initState() {
    super.initState();
    ownedDevices.clear();
    sharedDevices.clear();
    getAllDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MqttManager>(builder: (context, mqttSupport, child) {
      mqttClient = mqttSupport;
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
                              TimeOfDay startTime = const TimeOfDay(hour: 11, minute: 0);
                              List<String?> selectAllDevices = allDevices.map((device) => device.deviceid).toList();
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
                                          cutOffSubscription(selectAllDevices, context, "!suboffon");
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
                                          cutOffSubscription(selectAllDevices, context, "!suboffoff");
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
                                                  cutOffSubscription(selectAllDevices, context, expiry);
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
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await showModalBottomSheet(
                context: context,
                builder: (context) {
                  return StatefulBuilder(builder: (context, bottomState) {
                    return Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          DeviceIdTextField(deviceIdController: deviceIdController),
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            keyboardType: TextInputType.text,
                            controller: deviceNameController,
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey.shade800,
                            ),
                            onTapOutside: (event) => FocusScope.of(context).unfocus(),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              hintText: "Enter Device Name",
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(color: Color(0xFFD0D5DD), width: 1),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Color(0xFFD0D5DD), width: 1),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Color(0xFFD0D5DD), width: 1),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              counterText: "",
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await addDevice(deviceIdController.text, deviceNameController.text, widget.userId, context);
                            },
                            child: Text(
                              "Add Device",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: filledButtonStyle(),
                          )
                        ],
                      ),
                    );
                  });
                });
          },
          child: Icon(Icons.add),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 5, 16, 16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  removeBottom: true,
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      OnlineDeviceDetails device = allDevices[index];
                      devices.add(device.deviceid.toString());
                      log(device.deviceid.toString(), name: "${device.deviceName.toString()} ->");
                      log(allDevices.length.toString(), name: "OWNED DEVICES ->");
                      // Devices ownedDevice = Devices(deviceId: device.deviceid.toString(), deviceType: device.deviceType.toString(), deviceName: device.deviceName.toString(), deviceTemp: 24, deviceStatus: true, deviceMode: "deviceMode", isadmin: true, fanspeed: 1, did: "", sensordata: "", isconnected: true, econsumption: 0.0);
                      // devicesBox?.add(ownedDevice);
                      return ListTile(
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // device.isOnline
                            //     ? const Icon(Icons.circle, color: Colors.green, size: 12)
                            //     : const Icon(Icons.circle, color: Colors.grey, size: 12),
                            // const SizedBox(width: 8),
                            Icon(
                              Icons.wifi,
                              color: device.isOnline ? Colors.green : Colors.blueGrey,
                            ),
                          ],
                        ),
                        title: Row(
                          children: [
                            Text(device.deviceName.toString()),
                            if(device.isShared!)...[
                              const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: const Color(0xFFE2EEF3),
                              ),
                              child: const Text(
                                "Shared",
                                style: TextStyle(fontSize: 12, color: Color(0xff108EBE)),
                              ),
                            )]
                          ],
                        ),
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
                    itemCount: allDevices.length,
                    shrinkWrap: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void cutOffSubscription(List<String?> deviceIds, BuildContext context, String command) async {
    await subscriptionOff(deviceIds, context, command);
  }

  Future<void> subscriptionOff(List<String?> devices, BuildContext context, String command) async {
    final url = Uri.https(AppSecrets.baseUrl, "api/customers/masterapp/sendcommand");
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
        ownedDevices = removeDuplicateDevices(ownedDevices);
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
        sharedDevices = removeDuplicateDevices(sharedDevices);
        allDevices = [...ownedDevices, ...sharedDevices];
        mqttClient.onConnect();
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

  List<OnlineDeviceDetails> removeDuplicateDevices(List<OnlineDeviceDetails> devices) {
    final seen = <String>{};
    return devices.where((device) {
      final id = device.deviceid ?? '';
      if (seen.contains(id)) {
        return false;
      } else {
        seen.add(id);
        return true;
      }
    }).toList();
  }

  void getAllDevices() async {
    await getDevices();
    await getSharedDevices();
    // await setupMqttClient();
  }

  addDevice(String deviceId, String deviceName, String userId, BuildContext context) async {
    var url = Uri.https(AppSecrets.baseUrl, '/api/devices/');
    var headers = await _getHeaderConfig();
    Map<String, dynamic> deviceData = {
      "userid": userId,
      "deviceid": deviceId,
      "deviceName": deviceName,
      "isShared": false,
      "isadmin": true,
      "receiversid": "",
      "sendersName": "",
      "receiversName": "",
      "deviceType": "Split"
    };
    log(deviceData.toString(), name: "Payload");

    var response = await http.post(url, headers: headers, body: jsonEncode(deviceData));
    log(response.body, name: "Payload");
    if (response.statusCode == 200 || response.statusCode == 201) {
      Fluttertoast.showToast(msg: "Device Added Successfully");
      // Navigator.pop(context);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DevicesScreen(userId: widget.userId, fullName: widget.fullName)));
    } else {
      Fluttertoast.showToast(msg: "something went wrong ${response.statusCode}");
    }
  }
}

// Imports
// import 'dart:convert';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;
// import 'package:master_circolife_app/models/online_device_details.dart';
// import 'package:master_circolife_app/presentation/home/screens/configure_device_screen.dart';
// import 'package:master_circolife_app/utils/constants.dart';
// import 'package:mqtt_client/mqtt_client.dart';
// import 'package:mqtt_client/mqtt_server_client.dart';
// import 'package:slide_to_act/slide_to_act.dart';
//
// import '../../../main.dart';
// import '../../../utils/secrets.dart';
//
// late MqttServerClient mqttClient;
//
// class DevicesScreen extends StatefulWidget {
//   const DevicesScreen({super.key, required this.userId, required this.fullName});
//   final String userId;
//   final String fullName;
//
//   @override
//   State<DevicesScreen> createState() => _DevicesScreenState();
// }
//
// class _DevicesScreenState extends State<DevicesScreen> {
//   List<String?> devices = [];
//   List<OnlineDeviceDetails> ownedDevices = [];
//   List<OnlineDeviceDetails> sharedDevices = [];
//   Map<String?, OnlineDeviceDetails> deviceLookup = {};
//   bool _mqttListenerAttached = false;
//
//   @override
//   void initState() {
//     super.initState();
//     ownedDevices.clear();
//     sharedDevices.clear();
//     getAllDevices();
//   }
//
//   Future<void> getAllDevices() async {
//     await getDevices();
//     await getSharedDevices();
//
//     // Populate device lookup
//     deviceLookup.clear();
//     for (var d in [...ownedDevices, ...sharedDevices]) {
//       devices.add(d.deviceid);
//       deviceLookup[d.deviceid] = d;
//     }
//
//     await setupMqttClient();
//     await pingAllDevices();
//   }
//
//   Future<void> getDevices() async {
//     var url = Uri.parse('https://${AppSecrets.baseUrl}/api/devices/${widget.userId}');
//     var headers = await _getHeaderConfig();
//     var response = await http.get(url, headers: headers);
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       ownedDevices = (json.decode(response.body) as List)
//           .map<OnlineDeviceDetails>((json) => OnlineDeviceDetails.fromJson(json))
//           .toList();
//       setState(() {});
//     } else {
//       Fluttertoast.showToast(msg: "Failed to load devices");
//     }
//   }
//
//   Future<void> getSharedDevices() async {
//     var url = Uri.parse('https://${AppSecrets.baseUrl}/api/devices/shared/${widget.userId}');
//     var headers = await _getHeaderConfig();
//     var response = await http.get(url, headers: headers);
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       sharedDevices = (json.decode(response.body) as List)
//           .map<OnlineDeviceDetails>((json) => OnlineDeviceDetails.fromJson(json))
//           .toList();
//       setState(() {});
//     } else {
//       Fluttertoast.showToast(msg: "Failed to load shared devices");
//     }
//   }
//
//   Future<Map<String, String>> _getHeaderConfig() async {
//     String? token = await appStorage?.retrieveEncryptedData('token');
//     return {
//       'Content-Type': 'application/json',
//       'Accept': 'application/json',
//       if (token != null) 'Authorization': token
//     };
//   }
//
//   Future<void> setupMqttClient() async {
//     mqttClient = MqttServerClient.withPort('mqtt.circolives.in', 'flutter_client_${DateTime.now().millisecondsSinceEpoch}', 2266);
//     mqttClient.logging(on: false);
//     mqttClient.keepAlivePeriod = 20;
//
//     mqttClient.onConnected = () => log("MQTT Connected");
//     // mqttClient.onDisconnected = () => log("MQTT Disconnected");
//     mqttClient.onSubscribed = (String topic) => log("Subscribed to $topic");
//
//
//     mqttClient.updates?.listen((List<MqttReceivedMessage<MqttMessage?>>? messages) {
//       if (messages == null || messages.isEmpty) return;
//
//       final message = messages.first;
//       final topic = message.topic;
//       final payload =
//       MqttPublishPayload.bytesToStringAsString((message.payload as MqttPublishMessage).payload.message);
//       log("MQTT Message: $payload from $topic");
//
//       if (payload.contains("Hello Master")) {
//         final deviceId = topic.split("/")[0];
//         if (deviceLookup.containsKey(deviceId)) {
//           setState(() {
//             deviceLookup[deviceId]!.isOnline = true;
//           });
//         }
//       }
//     });
//
//     final connMessage = MqttConnectMessage()
//         .withClientIdentifier('flutter_client')
//         .authenticateAs("circolifeNodes", "CircoLifeProd@6622")
//         .keepAliveFor(20)
//         .startClean()
//         .withWillQos(MqttQos.atLeastOnce);
//
//     mqttClient.connectionMessage = connMessage;
//
//     try {
//       await mqttClient.connect();
//     } catch (e) {
//       log("MQTT Connect Error: $e");
//       mqttClient.disconnect();
//     }
//   }
//
//   Future<void> pingAllDevices() async {
//     for (var device in deviceLookup.values) {
//       final cmdInTopic = "${device.deviceid}/cmdin";
//       final builder = MqttClientPayloadBuilder();
//       final payload = "Hello ESP";
//
//       builder.addString(payload);
//       mqttClient.subscribe("${device.deviceid}/cmdout", MqttQos.atLeastOnce);
//
//       log("⏳ Sending PING to $cmdInTopic");
//       log("📤 Payload: $payload");
//
//       mqttClient.publishMessage(cmdInTopic, MqttQos.atLeastOnce, builder.payload!);
//     }
//
//   }
//
//
//   Future<void> subscriptionOff(List<String> deviceIds, BuildContext context, String command) async {
//     final url = Uri.https(AppSecrets.baseUrl, "api/customers/masterapp/sendcommand");
//     final headers = await _getHeaderConfig();
//
//     final response = await http.post(url, headers: headers, body: jsonEncode({
//       "devices": deviceIds,
//       "command": command
//     }));
//
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       if (command == "!suboffoff") {
//         Fluttertoast.showToast(msg: "${deviceIds.length} AC Subscription Turned ON");
//       } else if (command == "!suboffon") {
//         Fluttertoast.showToast(msg: "${deviceIds.length} AC Subscription Turned OFF");
//       } else {
//         Fluttertoast.showToast(msg: "${deviceIds.length} AC Expiry Updated");
//       }
//     } else {
//       Fluttertoast.showToast(msg: "Failed to send command. Code: ${response.statusCode}");
//     }
//
//     // Send reboot if expiry update
//     if (command.startsWith("E~")) {
//       await http.post(url, headers: headers, body: jsonEncode({
//         "devices": deviceIds,
//         "command": "!rbt"
//       }));
//     }
//   }
//
//   void cutOffSubscription(List<String> deviceIds, BuildContext context, String command) {
//     subscriptionOff(deviceIds, context, command);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("${widget.fullName} Devices")),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           ...ownedDevices.map((device) => ListTile(
//             leading: Icon(Icons.wifi, color: deviceLookup[device.deviceid]!.isOnline ? Colors.green : Colors.grey),
//             title: Text(device.deviceName.toString()),
//             subtitle: Text(device.deviceid.toString()),
//             trailing: const Icon(Icons.arrow_forward_ios),
//             onTap: () => Navigator.push(context, MaterialPageRoute(
//               builder: (_) {
//                 log(deviceLookup[device.deviceid]!.isOnline.toString());
//                 return ConfigureDeviceScreen(
//                 deviceId: device.deviceid.toString(),
//                 deviceName: device.deviceName.toString(),
//                 device: device,
//               );
//               },
//             )),
//           )),
//           ...sharedDevices.map((device) => ListTile(
//             leading: Icon(Icons.wifi, color: deviceLookup[device.deviceid]!.isOnline ? Colors.green : Colors.grey),
//             title: Row(
//               children: [
//                 Text(device.deviceName.toString()),
//                 const SizedBox(width: 8),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(6),
//                     color: const Color(0xFFE2EEF3),
//                   ),
//                   child: const Text(
//                     "Shared",
//                     style: TextStyle(fontSize: 12, color: Color(0xff108EBE)),
//                   ),
//                 )
//               ],
//             ),
//             subtitle: Text(device.deviceid.toString()),
//             trailing: const Icon(Icons.arrow_forward_ios),
//             onTap: () => Navigator.push(context, MaterialPageRoute(
//               builder: (_) => ConfigureDeviceScreen(
//                 deviceId: device.deviceid.toString(),
//                 deviceName: device.deviceName.toString(),
//                 device: device,
//               ),
//             )),
//           )),
//         ],
//       ),
//     );
//   }
// }
