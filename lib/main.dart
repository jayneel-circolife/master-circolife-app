import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:master_circolife_app/firebase_options.dart';
import 'package:master_circolife_app/presentation/auth/login_screen.dart';
import 'package:master_circolife_app/presentation/auth/splash_screen.dart';
import 'package:master_circolife_app/provider/mqtt_manager.dart';
import 'package:master_circolife_app/utils/stroage.dart';
import 'package:provider/provider.dart';

const String devicesBoxName = "master";

void main() {
  baseApp();
}

final EncryptedSharedPrefManager? appStorage = EncryptedSharedPrefManager.getInstance();

Future<void> baseApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MqttManager())
      ],
      child: MaterialApp(
        title: "Master Circolife",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: "Inter",
        ),
        home: const SplashScreen(),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
            child: child!,
          );
        },
      ),
    );
  }
}
