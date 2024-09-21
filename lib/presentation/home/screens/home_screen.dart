import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:master_circolife_app/presentation/home/screens/devices_screen.dart';
import 'package:master_circolife_app/presentation/home/screens/pricing_screen.dart';
import 'package:master_circolife_app/utils/constants.dart';
import 'package:master_circolife_app/utils/secrets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool searching = false;
  bool validNumber = false;
  TextEditingController phoneController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Master Circolife App"),
        centerTitle: true,
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
                    }
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
                  future: http.get(
                      Uri.http(
                        AppSecrets.baseUrl,
                        '/api/user/${phoneController.text}',
                      ),
                      headers: headers),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
                    } else {
                      if (snapshot.data?.statusCode == 201 || snapshot.data?.statusCode == 200) {
                        Map<String, dynamic> data = jsonDecode(snapshot.data!.body);
                        return Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.badge_outlined),
                              title: const Text("User Id"),
                              subtitle: Text(data['userid']),
                            ),
                            ListTile(
                              leading: const Icon(Icons.person_2_outlined),
                              title: const Text("Full Name"),
                              subtitle: Text(data['Fullname']),
                            ),
                            ListTile(
                              leading: const Icon(Icons.phone_outlined),
                              title: const Text("Mobile"),
                              subtitle: Text(data['mobile']),
                            ),
                            ListTile(
                              leading: const Icon(Icons.email_outlined),
                              title: const Text("Email"),
                              subtitle: Text(data['email']),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: data['kycStatus'] ? const Color(0xFF039855) : const Color(0xFFff5964), borderRadius: BorderRadius.circular(5)),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(data['kycStatus'] ? Icons.verified_user_rounded : Icons.pending_actions_rounded, color: Colors.white),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    data['kycStatus'] ? "KYC Done" : "KYC Pending",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            ListTile(
                              title: const Text("View Devices"),
                              trailing: const Icon(Icons.arrow_forward_rounded),
                              onTap: () {
                                Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => DevicesScreen(userId: data['userid'], fullName: data['Fullname'])));
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
                            )
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
