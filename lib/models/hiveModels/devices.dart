import 'package:hive/hive.dart';

part 'devices.g.dart';
// Run this command to convert .g.dart file >> flutter packages pub run build_runner build
@HiveType(typeId: 1)
class Devices extends HiveObject {
  Devices(
      {required this.deviceId,
        required this.deviceType,
        required this.deviceName,
        required this.deviceTemp,
        required this.deviceStatus,
        required this.deviceMode,
        required this.isadmin,
        required this.fanspeed,
        required this.did,
        required this.sensordata,
        required this.isconnected,
        required this.econsumption,
        this.deviceTimer = 0,
        this.selfClean = false,
        this.swing = false,
        this.childLock = false,
        this.convertible = 0,
        this.tempLock = 0,
        this.firmwareVersion = ""});

  @HiveField(0)
  String deviceId;

  @HiveField(1)
  String deviceType;

  @HiveField(2)
  String deviceName;

  @HiveField(3)
  int deviceTemp;

  @HiveField(4)
  bool deviceStatus;

  @HiveField(5)
  String deviceMode;

  @HiveField(6)
  bool isadmin;

  @HiveField(7)
  int fanspeed;

  @HiveField(8)
  String did;

  @HiveField(9)
  String sensordata;

  @HiveField(10)
  bool isconnected;

  @HiveField(11)
  double econsumption;

  @HiveField(12)
  int deviceTimer;

  @HiveField(13, defaultValue: false)
  bool selfClean;

  @HiveField(14, defaultValue: false)
  bool swing;

  @HiveField(15, defaultValue: false)
  bool childLock;

  @HiveField(16, defaultValue: 0)
  int convertible;

  @HiveField(17, defaultValue: 0)
  int tempLock;

  @HiveField(18, defaultValue: "")
  String firmwareVersion;
}
