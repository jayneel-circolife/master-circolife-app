import 'dart:math';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../models/hiveModels/devices.dart';

Box<Devices>? devicesBox;

class MqttManager extends ChangeNotifier {
  bool isConnected = false;
  final MqttServerClient _client = MqttServerClient('mqtt.circolives.in', '');

  MqttManager() {
    asyncMethod();
    devicesBox = Hive.box<Devices>("master");
  }
  void asyncMethod() async {
    isConnected = await mqttconnect(getRandomString(16));
  }

  String getRandomString(int length) {
    const characters = '+-*=?AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
    Random random = Random();
    String randomString = String.fromCharCodes(Iterable.generate(length, (_) => characters.codeUnitAt(random.nextInt(characters.length))));
    dev.log(randomString, name: "RandomString! >");
    return randomString;
  }

  Future<bool> mqttconnect(String uniquekey) async {
    //Fluttertoast.showToast(msg: "Mqtt Connecting..");
    String username = "circolifeNodes";
    String password = "CircoLifeProd@6622";
    _client.port = 2266;
    _client.keepAlivePeriod = 90;
    _client.logging(on: false);
    _client.onDisconnected = onDiscnnect();
    _client.onAutoReconnect = onReconnect();
    _client.autoReconnect = true;
    _client.onConnected = onConnectmsg();
    _client.pongCallback = pong;

    final MqttConnectMessage connMess = MqttConnectMessage().withClientIdentifier(uniquekey).authenticateAs(username, password).startClean();
    _client.connectionMessage = connMess;
    try {
      await _client.connect();
    } on Exception catch (e) {
      dev.log('client Connection exception - $e');
    }
    if (_client.connectionStatus!.state == MqttConnectionState.connected) {
      dev.log("Connected to aws");
      onConnect();
    } else {
      return false;
    }
    return true;
  }

  onConnectmsg() {
    //Fluttertoast.showToast(msg: "Connected!");
  }

  onReconnect() {}

  onConnect() {
    if (devicesBox != null) {
      for (int index = 0; index < devicesBox!.length; index++) {
        Devices device = devicesBox!.getAt(index)!;
        if (device.deviceId != "Null") {
          device.isconnected = false;
          device.deviceStatus = false;
          device.econsumption = 0;
          device.save();
          _client.subscribe("${device.deviceId}/cmdin", MqttQos.atLeastOnce);
          _client.subscribe("${device.deviceId}/cmdout", MqttQos.atLeastOnce);
          _client.subscribe("${device.deviceId}/sensordata", MqttQos.atLeastOnce);
          sendMessage("${device.deviceId}/cmdin", "Hello ESP");
          // sendMessage("${device.deviceId}/cmdin", "!stat");
        }
        dev.log("Subscribed!");
        _client.updates?.listen(_onMessage);
      }
    }
  }

  void _onMessage(List<MqttReceivedMessage> c) {
    dev.log(c.length.toString(), name: "MQTT Message Length");
    final MqttPublishMessage recMess = c[0].payload;
    final String message = MqttPublishPayload.bytesToStringAsString(recMess.payload.message).replaceAll("\r", "-");
    dev.log(message, name: "Received message:");
    dev.log(c[0].topic, name: "from topic:");
    List messageDeviceId = c[0].topic.split('/');
    Iterable<Devices> devices = devicesBox!.values.where((element) => element.deviceId == messageDeviceId[0]);
    Devices selecteddevice = devices.first;
    if (messageDeviceId[1] == "sensordata") {
      dev.log(message.split("~")[2], name: "Sensor Data >");
      selecteddevice.sensordata = message.split("~")[2];
    }
    if (messageDeviceId[1] == "cmdout") {
      dev.log(message, name: ">>cmdout>>");
      try {
        if (message.contains("~")) {
          dev.log("In Firmware Block");
          selecteddevice.firmwareVersion = message.split("~")[1];
          dev.log(selecteddevice.firmwareVersion.toString(), name: "Firmware Version >>");
        }else if (message.length > 15 && !message.contains("!")) {
          dev.log(">>>$message", name: "Before Split");
          dev.log(">>>${message.split('-')[0]}", name: "Split 0th");
          dev.log(">>>${message.split('-')[1]}", name: "Split 1th");
          if (double.parse(message.split('-')[0]) > 0 && double.parse(message.split('-')[1]) == 0) {
            selecteddevice.econsumption = .04;
          } else {
            double watt = double.parse(message.split('-')[0]) * double.parse(message.split('-')[1]);
            selecteddevice.econsumption = watt / 1000;
          }
        }
      } catch (e) {
        dev.log("Catch Block");
        dev.log(">>>$message", name: "Fault Message");
      }
      if (message.contains("Hello Master")) {
        selecteddevice.isconnected = true;
        dev.log("Wifi Connected", name: selecteddevice.deviceName);
      }
      if (message.contains("I am dead")) {
        selecteddevice.isconnected = false;
        dev.log("Offline", name: selecteddevice.deviceName);
      }
      if (message.contains("!on")) {
        selecteddevice.deviceStatus = true;
        dev.log("AC On!", name: selecteddevice.deviceName);
      }
      if (message.contains("!off")) {
        selecteddevice.deviceStatus = false;
        dev.log("AC Off!", name: selecteddevice.deviceName);
      }
      if (message.contains("!fl")) {
        selecteddevice.fanspeed = 0;
        dev.log("Fan Low", name: selecteddevice.deviceName);
      }
      if (message.contains("!fm")) {
        selecteddevice.fanspeed = 1;
        dev.log("Fan Medium", name: selecteddevice.deviceName);
      }
      if (message.contains("!fh")) {
        selecteddevice.fanspeed = 2;
        dev.log("Fan High", name: selecteddevice.deviceName);
      }
      if (message.contains("!tem")) {
        try {
          final tempPart = message.split("!tem")[1].split("-!")[0];
          selecteddevice.deviceTemp = int.parse(tempPart);
          dev.log("Temp ${selecteddevice.deviceTemp.toString()}", name: selecteddevice.deviceName);
        } catch (e) {
          dev.log("Error parsing temperature: $e", name: "Temp Error");
        }
      }
      if (message.contains("!tim")) {
        try {
          final timerPart = message.split("!tim")[1].split("-!")[0];
          selecteddevice.deviceTimer = int.parse(timerPart);
          dev.log("Timer ${selecteddevice.deviceTimer.toString()}", name: selecteddevice.deviceName);
        } catch (e) {
          dev.log("Error parsing timer: $e", name: "Timer Error");
        }
      }
      if (message.contains("!clnoff")) {
        selecteddevice.selfClean = false;
        dev.log("Self Clean Off", name: selecteddevice.deviceName);
      }
      if (message.contains("!clnon")) {
        selecteddevice.selfClean = true;
        dev.log("Self Clean On", name: selecteddevice.deviceName);
      }
      if (message.contains("!m1")) {
        selecteddevice.deviceMode = "Cooling";
        dev.log("Mode ${selecteddevice.deviceMode.toString()}", name: selecteddevice.deviceName);
      }
      if (message.contains("!trbon")) {
        selecteddevice.deviceMode = "Turbo";
        dev.log("Mode ${selecteddevice.deviceMode.toString()}", name: selecteddevice.deviceName);
      }
      if (message.contains("!qiton")) {
        selecteddevice.deviceMode = "Quiet";
        dev.log("Mode ${selecteddevice.deviceMode.toString()}", name: selecteddevice.deviceName);
      }
      if (message.contains("!m2")) {
        selecteddevice.deviceMode = "Dry";
        dev.log("Mode ${selecteddevice.deviceMode.toString()}", name: selecteddevice.deviceName);
      }
      if (message.contains("!swon")) {
        selecteddevice.swing = true;
        dev.log("Swing On", name: selecteddevice.deviceName);
      }
      if (message.contains("!swoff")) {
        selecteddevice.swing = false;
        dev.log("Swing Off", name: selecteddevice.deviceName);
      }
      if (message.contains("!chlockoff")) {
        selecteddevice.childLock = false;
        dev.log("ChildLock Off", name: selecteddevice.deviceName);
      }
      if (message.contains("!chlockon")) {
        selecteddevice.childLock = true;
        dev.log("ChildLock On", name: selecteddevice.deviceName);
      }
      if (message.contains("!tmlock")) {
        try {
          final tmLockPart = message.split("!tmlock")[1].split("-!")[0];
          selecteddevice.tempLock = int.parse(tmLockPart);
          dev.log(selecteddevice.tempLock.toString(), name: "Temp Lock >");
        } catch (e) {
          dev.log("Error parsing timer lock: $e", name: "Temp Lock Error");
        }
      }
    }
    selecteddevice.save;
    notifyListeners();
  }

  onDiscnnect() {
    isConnected = false;
  }

  pong() {
    dev.log('Log: ${_client.connectionStatus}');
  }

  sendMessage(String topic, String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    try {
      _client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    } on Exception catch (error) {
      dev.log(error.toString(), name: "Exception Error");
    }
  }
}
