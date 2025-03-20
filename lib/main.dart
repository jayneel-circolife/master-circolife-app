import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:master_circolife_app/utils/mqtt_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:developer';
import 'models/hiveModels/devices.dart';
import 'presentation/home/screens/home_screen.dart';

const String devicesBoxName = "master";

void main() {
  baseApp();
}

Future<void> baseApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await connectToHive();
  runApp(const MyApp());
}

connectToHive() async {
  // Fluttertoast.showToast(msg: 'HIVE INIT');
  try {
    final document = await getApplicationDocumentsDirectory();
    Hive.init(document.path);
    Hive.registerAdapter(DevicesAdapter());
    // Fluttertoast.showToast(msg: 'HIVE SETUP');
    log("HIVE SETUP", name: "HIVE>");
    await Hive.openBox<Devices>(devicesBoxName);
    // Fluttertoast.showToast(msg: 'HIVE OPEN BOX COMPLETE');
    log("HIVE OPEN BOX COMPLETE", name: "HIVE>");
  } catch (e) {
    // Fluttertoast.showToast(msg: 'HIVE ISSUE');
    log("HIVE ISSUE $e", name: "HIVE>");
    log("TRY AGAIN", name: "HIVE>");
    if (await Hive.boxExists(devicesBoxName)) {
      // Fluttertoast.showToast(msg: 'DELETE DB');
      log("DELETE DB", name: "HIVE>");
      await Hive.deleteBoxFromDisk(devicesBoxName);
      // Fluttertoast.showToast(msg: 'DELETE DB COMPLETE');
      log("DELETE DB COMPLETE", name: "HIVE>");
    }
    // Fluttertoast.showToast(msg: 'SETTING HIVE AGAIN');
    log("SETTING UP HIVE AGAIN", name: "HIVE>");
    connectToHive();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Master Circolife",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: "Inter",
      ),
      home: const HomeScreen(),
    );
  }
}
