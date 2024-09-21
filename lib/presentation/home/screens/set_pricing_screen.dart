import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SetPricingScreen extends StatelessWidget {
  const SetPricingScreen({super.key, required this.deviceId, required this.deviceName});
  final String deviceId;
  final String deviceName;
  static List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$deviceName Pricing"),
      ),
        body: GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: (){
            showDialog(context: context, builder: (context){
              return AlertDialog(
                actions: [TextButton(onPressed: (){}, child: const Text("Ok"))],
                title: const Text("New Price"),
                content: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "Enter new price"
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
              );
            });
          },
          child: Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(months[index % months.length]),
                const Text("₹ 1299")
              ],
            ),
          ),
        );
      },
      itemCount: 60,
    ));
  }
}
