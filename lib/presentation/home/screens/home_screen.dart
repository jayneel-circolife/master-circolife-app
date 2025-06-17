import 'dart:convert';
import 'dart:developer' as dev;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:master_circolife_app/presentation/home/screens/InvoicesScreen.dart';
import 'package:master_circolife_app/presentation/home/screens/devices_screen.dart';
import 'package:master_circolife_app/presentation/home/screens/pricing_screen.dart';
import 'package:master_circolife_app/utils/constants.dart';
import 'package:master_circolife_app/utils/secrets.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../main.dart';
import '../../../models/user_details_model.dart';

late MqttServerClient mqttClient;
bool mqttListenerAttached = false;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool searching = false;
  bool validNumber = false;
  TextEditingController phoneController = TextEditingController();
  SharedPreferences? preferences;
  UserDetails? userdata;
  final _auth = FirebaseAuth.instance;
  User? user;
  String? username;

  Future<void> _checkLogin() async {
    preferences = await SharedPreferences.getInstance();
    username = await appStorage?.retrieveEncryptedData("username");
    setState(() {});
    if (user == null) {
    } else {
      await getuserdata(user!.phoneNumber.toString());
    }
  }

  Future<void> getuserdata(String contact) async {
    setState(() {
      // isloading = true;
    });
    dev.log(">>>$contact");
    var headers = await _getHeaderConfig();
    var url = Uri.https(AppSecrets.baseUrl, 'api/user/existUser/${contact.replaceFirst("+91", "")}');
    var response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() {
        userdata = UserDetails.fromJson(json.decode(response.body));
        // isloading = false;
      });
      // dev.log(orders[0].oId ?? "NULL", name: "ORDER ID>>");
    } else {
      // logout();
    }
  }

  Future<Map<String, String>> _getHeaderConfig() async {
    String? token = await appStorage?.retrieveEncryptedData('token');
    Map<String, String> headers = {};
    headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers.putIfAbsent("Authorization", () => token);
    }
    return headers;
  }

  Future getUserDataByPhoneNumber() async {
    return http.get(
        Uri.https(
          AppSecrets.baseUrl,
          '/api/user/existUser/${phoneController.text}',
        ),
        headers: await _getHeaderConfig());
  }

  @override
  void initState() {
    super.initState();
    login();
  }

  login() async {
    await _checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Welcome ${username ?? ""}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
                  onPressed: () {
                    if (phoneController.text.length == 10) {
                      setState(() {
                        validNumber = true;
                      });
                    } else {}
                  },
                  icon: const Icon(Icons.search),
                  enableFeedback: true,
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            if (validNumber)
              FutureBuilder(
                  future: getUserDataByPhoneNumber(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      dev.log(snapshot.data.toString(), name: "BODY>>>>");
                      return Text(snapshot.error.toString());
                    } else {
                      if (snapshot.data?.statusCode == 201 || snapshot.data?.statusCode == 200) {
                        dev.log(snapshot.data.toString(), name: "BODY>>>>");
                        Map<String, dynamic> data = jsonDecode(snapshot.data?.body);
                        String userId = data['userid'] ?? "";
                        String fullName = data['Fullname'] ?? "";
                        String mobile = data['mobile'] ?? "";
                        String email = data['email'] ?? "";
                        String customerId = data['customer_id'] ?? "";
                        String onboardingDate = data['onBoardingDate'].toString().split("T")[0] ?? "";
                        bool kycStatus = data['kycStatus'] ?? false;
                        return Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.badge_outlined),
                              title: const Text("User Id"),
                              subtitle: Text(userId),
                            ),
                            ListTile(
                              leading: const Icon(Icons.person_2_outlined),
                              title: const Text("Full Name"),
                              subtitle: Text(fullName),
                            ),
                            ListTile(
                              leading: const Icon(Icons.phone_outlined),
                              title: const Text("Mobile"),
                              subtitle: Text(mobile),
                            ),
                            ListTile(
                              leading: const Icon(Icons.email_outlined),
                              title: const Text("Email"),
                              subtitle: Text(email),
                            ),
                            ListTile(
                              leading: const Icon(Icons.flight_land_outlined),
                              title: const Text("OnBoarded on"),
                              subtitle: Text(onboardingDate),
                            ),
                            Container(
                              decoration:
                                  BoxDecoration(color: kycStatus ? const Color(0xFF039855) : const Color(0xFFff5964), borderRadius: BorderRadius.circular(5)),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(kycStatus ? Icons.verified_user_rounded : Icons.pending_actions_rounded, color: Colors.white),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    kycStatus ? "KYC Done" : "KYC Pending",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            if (userId != "") ...[
                              ListTile(
                                title: const Text("View Devices"),
                                trailing: const Icon(Icons.arrow_forward_rounded),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => DevicesScreen(
                                                userId: userId,
                                                fullName: fullName,
                                              )));
                                },
                              ),
                              ListTile(
                                title: const Text("Custom Pricing"),
                                trailing: const Icon(Icons.arrow_forward_rounded),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PricingScreen(
                                                userId: data['userid'],
                                              )));
                                },
                              ),
                              if (customerId != "")
                                ListTile(
                                  title: const Text("Invoices"),
                                  trailing: const Icon(Icons.arrow_forward_rounded),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => InvoicesScreen(
                                                  customerId: customerId,
                                                  userId: userId,
                                                )));
                                  },
                                ),
                            ],
                          ],
                        );
                      }
                      return Text(snapshot.error.toString());
                    }
                  })
          ],
        ),
      ),
    );
  }
}
