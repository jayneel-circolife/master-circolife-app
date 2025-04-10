import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:master_circolife_app/firebase_options.dart';
import 'package:master_circolife_app/presentation/auth/login_screen.dart';
import 'package:master_circolife_app/presentation/auth/splash_screen.dart';
import 'package:master_circolife_app/utils/mqtt_manager.dart';
import 'package:master_circolife_app/utils/stroage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:developer';
import 'models/hiveModels/devices.dart';
import 'presentation/home/screens/home_screen.dart';

const String devicesBoxName = "master";

void main() {
  baseApp();
}

final EncryptedSharedPrefManager? appStorage = EncryptedSharedPrefManager.getInstance();

Future<void> baseApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
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
      home: const SplashScreen(),
    );
  }
}
