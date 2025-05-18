import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:master_circolife_app/presentation/home/screens/devices_screen.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:developer' as dev;

import '../models/online_device_details.dart';

class MqttManager extends ChangeNotifier {
  bool isConnected = false;

  final MqttServerClient client = MqttServerClient('mqtt.circolives.in', '');

  MqttManager() {
    getIdentifier();
  }

  void getIdentifier() async {
    isConnected = await mqttConnect(getRandomString(16));
  }

  String getRandomString(int length) {
    const characters = '+-*=?AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
    Random random = Random();
    String randomString = String.fromCharCodes(Iterable.generate(length, (_) => characters.codeUnitAt(random.nextInt(characters.length))));
    dev.log(randomString, name: "RandomString! >");
    return randomString;
  }

  Future<bool> mqttConnect(String uniqueKey) async {
    String username = "circolifeNodes";
    String password = "CircoLifeProd@6622";
    client.port = 2266;
    client.keepAlivePeriod = 60;
    client.logging(on: false);
    client.onDisconnected = onDisconnect();
    client.onAutoReconnect = onReconnect();
    client.autoReconnect = true;
    client.onConnected = onConnectMsg();
    client.pongCallback = pong;

    final MqttConnectMessage connMess = MqttConnectMessage().withClientIdentifier(uniqueKey).authenticateAs(username, password).startClean();
    client.connectionMessage = connMess;

    try {
      await client.connect(username, password);
    } on Exception catch (e) {
      dev.log(e.toString(), name: "MqttException! >");
      client.disconnect();
    }
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      dev.log("Connected to aws");
      onConnect();
    } else {
      return false;
    }
    return true;
  }

  onConnectMsg() {
    // Fluttertoast.showToast(msg: "Connected!");
  }

  onReconnect() {}
  onDisconnect() {
    isConnected = false;
  }

  pong() {
    dev.log('Log: ${client.connectionStatus}');
  }

  onConnect() {
    if (isConnected) {
      client.updates?.listen(_onMessage);
      if (allDevices.isNotEmpty) {
        for (OnlineDeviceDetails device in allDevices) {
          if (device.deviceid != null) {
            client.subscribe("${device.deviceid!}/cmdin", MqttQos.atLeastOnce);
            client.subscribe("${device.deviceid!}/cmdout", MqttQos.atLeastOnce);
            sendMessage("${device.deviceid!}/cmdin", "Hello ESP");
            dev.log('Hello ESP', name: '${device.deviceid!}/cmdin');
          }
        }
      }
    } else {}
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> c) {
    final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
    final String payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);
    final String topic = c[0].topic;

    dev.log('Received message: $payload from topic: $topic', name: 'MQTT_Message');

    final String deviceId = topic.split('/')[0];

    for (int i = 0; i < allDevices.length; i++) {
      if (allDevices[i].deviceid == deviceId) {
        if (payload.contains("Hello Master")) {
          dev.log('Device $deviceId is now connected', name: 'MQTT_Connection');

          allDevices[i].isOnline = true;

          notifyListeners();
        }
        if (payload.contains("~1")) {
          dev.log('Device $deviceId Firmware version', name: 'MQTT_Connection');

          allDevices[i].firmwareVersion = payload.split("~")[1];

          notifyListeners();
        }
      }
    }
  }

  sendMessage(String topic, String message) {
    if (isConnected) {
      final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
      builder.addString(message);
      try {
        client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
      } on Exception catch (error) {
        dev.log(error.toString(), name: "Exception Error");
      }
    }
  }
}
