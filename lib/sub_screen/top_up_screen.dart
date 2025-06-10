// ignore_for_file: unnecessary_import, depend_on_referenced_packages, camel_case_types, prefer_typing_uninitialized_variables, non_constant_identifier_names, avoid_print, no_leading_underscores_for_local_identifiers, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../API_MODEL/wallet_report_api_model.dart';
import '../API_MODEL/wallet_update_api_model.dart';
import '../Common_Code/common_button.dart';
import '../config/config.dart';
import '../config/light_and_dark.dart';

class Top_up extends StatefulWidget {
  final String wallet;
  final String searchbus;

  const Top_up({super.key, required this.wallet, required this.searchbus});

  @override
  State<Top_up> createState() => _Top_upState();
}

class _Top_upState extends State<Top_up> {
  WalletReport? data;
  var daat;

  // Wallet_Report Api
  Future Walletreport(String uid) async {
    Map body = {
      'uid': uid,
    };

    print("+++ $body");

    try {
      var response = await http.post(
          Uri.parse('${config().baseUrl}/api/wallet_report.php'),
          body: jsonEncode(body),
          headers: {
            'Content-Type': 'application/json',
          });

      print(response.body);
      if (response.statusCode == 200) {
        setState(() {
          data = walletReportFromJson(response.body);
          isloading = false;
          print('+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+${data!.wallet}');
        });
      } else {
        print('failed');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  TextEditingController walletController = TextEditingController();

  var userData;
  var searchbus;

  getlocledata() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    setState(() {
      userData = jsonDecode(_prefs.getString("loginData")!);
      isloading = false;
      print('+-+-+-+-+-+-+-+-+-+-hhhhhhhhhh+-+-+-+-+-+-+-+-+-+-+-+-+${userData["name"]}');
    });
  }

  @override
  void initState() {
    setState(() {
      isloading = false;
    });
    getlocledata();
    walletController.text = "100".tr;
    super.initState();
  }

  bool isloading = true;

  // Wallet_Update_Api
  WalletUpdate? wupdate;

  Future WalletUpdateApi(String uid) async {
    Map body = {
      'uid': uid,
      'wallet': walletController.text,
    };

    print("+++ $body");
    try {
      var response = await http.post(
          Uri.parse('${config().baseUrl}/api/wallet_up.php'),
          body: jsonEncode(body),
          headers: {
            'Content-Type': 'application/json',
          });

      print(response.body);
      if (response.statusCode == 200) {
        setState(() {
          wupdate = walletUpdateFromJson(response.body);
          Walletreport(uid);
        });

        showModalBottomSheet(
          isDismissible: false,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15), topRight: Radius.circular(15))),
          context: context,
          builder: (BuildContext context) {
            return Container(
              height: 330,
              decoration: BoxDecoration(
                  color: notifier.backgroundgray,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15))),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  const CircleAvatar(
                      radius: 35,
                      backgroundColor: Color(0xff7D2AFF),
                      child: Center(
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                          ))),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Top up ${widget.searchbus}${walletController.text}.00',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: notifier.textColor),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Successfuly'.tr,
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: notifier.textColor),
                  ),
                  const SizedBox(
                    height: 28,
                  ),
                  Text(
                    '${widget.searchbus}${walletController.text} has been added to your wallet',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  const SizedBox(
                    height: 28,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: const ButtonStyle(
                                fixedSize:
                                MaterialStatePropertyAll(Size(0, 50)),
                                backgroundColor:
                                MaterialStatePropertyAll(Colors.white),
                                side: MaterialStatePropertyAll(
                                    BorderSide(color: Colors.black)),
                                shape: MaterialStatePropertyAll(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30))))),
                            onPressed: () {
                              Get.close(0);
                              Get.back(result: "12456789");
                            },
                            child: Text('Done For Now'.tr,
                                style: const TextStyle(color: Colors.black)),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            style: const ButtonStyle(
                                fixedSize:
                                MaterialStatePropertyAll(Size(0, 50)),
                                backgroundColor:
                                MaterialStatePropertyAll(Colors.black),
                                side: MaterialStatePropertyAll(
                                    BorderSide(color: Colors.black)),
                                shape: MaterialStatePropertyAll(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30))))),
                            onPressed: () {
                              Get.close(0);
                              Get.back(result: "12456789");
                            },
                            child: Text('Another Top Up'.tr,
                                style: const TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      } else {
        print('failed');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  ColorNotifier notifier = ColorNotifier();

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.backgroundgray,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: CommonButton(
          containcolore: notifier.theamcolorelight,
          txt2: 'Continue'.tr,
          context: context,
          onPressed1: () {
            // Simplified payment process - direct wallet update
            // In a real app, you would integrate with a payment gateway here
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Confirm Top Up'.tr),
                  content: Text(
                      'Add ${widget.searchbus}${walletController.text} to your wallet?'.tr),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel'.tr),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Simulate successful payment
                        WalletUpdateApi(userData['id']);
                      },
                      child: Text('Confirm'.tr),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: const Color(0xff2C2C2C),
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text('Top Up'.tr,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: isloading
            ? Center(
          child: CircularProgressIndicator(
              color: notifier.theamcolorelight),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 10,
            ),
            Stack(
              children: [
                const Image(image: AssetImage('assets/Visa_card.png')),
                Padding(
                  padding:
                  const EdgeInsets.only(top: 40, left: 30, right: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 65,
                      ),
                      Text(
                        'Your balance'.tr,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        children: [
                          Text(
                            '${widget.searchbus} ${widget.wallet}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 30),
                          ),
                          const Spacer(),
                          Padding(
                            padding:
                            const EdgeInsets.only(top: 0, right: 20),
                            child: Container(
                              height: 35,
                              width: 90,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                children: [
                                  const Spacer(),
                                  const Image(
                                    image: AssetImage('assets/Top_up.png'),
                                    height: 15,
                                    width: 15,
                                  ),
                                  const SizedBox(width: 5),
                                  Text('Top up'.tr,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)),
                                  const Spacer(),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
                child: Text(
                  'Top up Amount'.tr,
                  style: TextStyle(
                      fontSize: 18,
                      color: notifier.textColor,
                      fontWeight: FontWeight.bold),
                )),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                controller: walletController,
                cursorColor: Colors.black,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: notifier.textColor,
                ),
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  prefixIcon: SizedBox(
                    height: 20,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Image.asset(
                        'assets/a1.png',
                        width: 20,
                        color: notifier.textColor,
                      ),
                    ),
                  ),
                  hintStyle: TextStyle(
                    color: notifier.textColor,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        walletController.text = "100".tr;
                      },
                      child: Container(
                        height: 40,
                        width: 80,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "100".tr,
                          style: TextStyle(
                            color: notifier.textColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        walletController.text = "300".tr;
                      },
                      child: Container(
                        height: 40,
                        width: 80,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "300".tr,
                          style: TextStyle(
                            color: notifier.textColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        walletController.text = "500".tr;
                      },
                      child: Container(
                        height: 40,
                        width: 80,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "500".tr,
                          style: TextStyle(
                            color: notifier.textColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        walletController.text = "1000".tr;
                      },
                      child: Container(
                        height: 40,
                        width: 80,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "1000".tr,
                          style: TextStyle(
                            color: notifier.textColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        walletController.text = "1100".tr;
                      },
                      child: Container(
                        height: 40,
                        width: 80,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "1100".tr,
                          style: TextStyle(
                            color: notifier.textColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        walletController.text = "1300".tr;
                      },
                      child: Container(
                        height: 40,
                        width: 80,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "1300".tr,
                          style: TextStyle(
                            color: notifier.textColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        walletController.text = "1500".tr;
                      },
                      child: Container(
                        height: 40,
                        width: 80,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "1500".tr,
                          style: TextStyle(
                            color: notifier.textColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        walletController.text = "1700".tr;
                      },
                      child: Container(
                        height: 40,
                        width: 80,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "1700".tr,
                          style: TextStyle(
                            color: notifier.textColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        walletController.text = "2000".tr;
                      },
                      child: Container(
                        height: 40,
                        width: 80,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "2000".tr,
                          style: TextStyle(
                            color: notifier.textColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}