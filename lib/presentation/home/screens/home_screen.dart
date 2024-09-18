import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:master_circolife_app/presentation/home/screens/devices_screen.dart';
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
                  controller: phoneController,
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
                  future: http.get(Uri.http(AppSecrets.baseUrl,'/api/user/${phoneController.text}')),
                  builder: (context, snapshot) {
                    log(snapshot.data!.statusCode.toString(), name: "STATUS CODE");
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.data?.statusCode == 201) {
                      Map<String, dynamic> data = jsonDecode(snapshot.data!.body);
                      return Column(
                        children: [
                          ListTile(
                            title: const Text("User Id"),
                            subtitle: Text(data['userid']),
                          ),
                          ListTile(
                            title: const Text("Full Name"),
                            subtitle: Text(data['Fullname']),
                          ),
                          ListTile(
                            title: const Text("Mobile"),
                            subtitle: Text(data['mobile']),
                          ),
                          ListTile(
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
                          )
                        ],
                      );
                    }
                    return Container();
                  })
          ],
        ),
      ),
    );
  }
}
