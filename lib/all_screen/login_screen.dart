// ignore_for_file: camel_case_types, file_names, avoid_print, depend_on_referenced_packages, empty_catches, unnecessary_brace_in_string_interps, non_constant_identifier_names, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Common_Code/common_button.dart';
import '../api_controller/forgot_api_controller.dart';
import '../api_controller/msg_controller.dart';
import '../api_controller/signup_api_controller.dart';
import '../api_controller/sms_api_controller.dart';
import '../api_controller/twilyo_api_controller.dart';
import '../api_model/agent_signup_api_model.dart';
import '../config/config.dart';
import '../config/light_and_dark.dart';
import '../config/push_notification_function.dart';
import 'bottom_navigation_bar_screen.dart';
import 'otp_verfication_forgot_screen.dart';
import 'otp_verfication_screen.dart';

// MOBILCHECK API - VERSION CORRIGÉE
Future<Map<String, dynamic>> mobileCheck(String mobile, String ccode) async {
  Map body = {
    'mobile': mobile,
    'ccode': ccode,
  };

  print('Mobile check request: $body');

  try {
    var response = await http.post(
      Uri.parse('${config().baseUrl}/api/mobile_check.php'),
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 30)); // Ajout d'un timeout

    print('Mobile check response status: ${response.statusCode}');
    print('Mobile check response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        var data = jsonDecode(response.body.toString());
        print('Parsed data: $data');

        // Vérifier que data est bien un Map
        if (data is Map<String, dynamic>) {
          return data;
        } else {
          return {
            "Result": "false",
            "ResponseMsg": "Format de réponse invalide",
            "ResponseCode": "500"
          };
        }
      } catch (e) {
        print('Erreur de parsing JSON: $e');
        return {
          "Result": "false",
          "ResponseMsg": "Erreur de parsing des données",
          "ResponseCode": "500"
        };
      }
    } else {
      print('Erreur HTTP: ${response.statusCode}');
      return {
        "Result": "false",
        "ResponseMsg": "Erreur serveur: ${response.statusCode}",
        "ResponseCode": response.statusCode.toString()
      };
    }
  } catch (e) {
    print('Erreur mobile check: $e');
    return {
      "Result": "false",
      "ResponseMsg": "Erreur de connexion: ${e.toString()}",
      "ResponseCode": "500"
    };
  }
}

// LOGIN API - VERSION CORRIGÉE
Future<Map<String, dynamic>> login(String mobile, String ccode, String password) async {
  Map body = {
    'mobile': mobile,
    'ccode': ccode,
    'password': password
  };

  print('Login request: $body');

  try {
    var response = await http.post(
      Uri.parse('${config().baseUrl}/api/user_login.php'),
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 30));

    print('Login response status: ${response.statusCode}');
    print('Login response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        var data = jsonDecode(response.body.toString());
        print("Login data parsed: $data");

        if (data is Map<String, dynamic>) {
          // Sauvegarder les données si la connexion est réussie
          if (data["ResponseCode"] == "200") {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            initPlatformState();
            prefs.setString("loginData", jsonEncode(data["UserLogin"]));
            prefs.setString("currency", jsonEncode(data["currency"]));
          }
          return data;
        } else {
          return {
            "Result": "false",
            "ResponseMsg": "Format de réponse invalide",
            "ResponseCode": "500"
          };
        }
      } catch (e) {
        print('Erreur de parsing login: $e');
        return {
          "Result": "false",
          "ResponseMsg": "Erreur de parsing des données",
          "ResponseCode": "500"
        };
      }
    } else {
      return {
        "Result": "false",
        "ResponseMsg": "Erreur serveur: ${response.statusCode}",
        "ResponseCode": response.statusCode.toString()
      };
    }
  } catch (e) {
    print('Erreur login: $e');
    return {
      "Result": "false",
      "ResponseMsg": "Erreur de connexion: ${e.toString()}",
      "ResponseCode": "500"
    };
  }
}

class LoginScreenFixed extends StatefulWidget {
  const LoginScreenFixed({super.key});

  @override
  State<LoginScreenFixed> createState() => _LoginScreenFixedState();
}

class _LoginScreenFixedState extends State<LoginScreenFixed> {
  bool referralcode = false;
  String ccode = "";
  String ccode1 = "";

  TextEditingController mobileController = TextEditingController();
  TextEditingController mobileController1 = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordController1 = TextEditingController();
  TextEditingController newpasswordController = TextEditingController();
  TextEditingController conformpasswordController = TextEditingController();

  List lottie12 = [
    "assets/lottie/slider1.json",
    "assets/lottie/slider2.json",
    "assets/lottie/slider3.json",
    "assets/lottie/slider4.json",
  ];

  List title = [
    "Your Journey, Your Way",
    "Seamless Travel Simplified",
    "Book, Ride, Enjoy",
    "Explore, One Bus at a Time"
  ];

  List description = [
    'Customize your travel effortlessly.',
    'Easy booking and boarding for a stress-free journey.',
    'Swift booking and delightful bus rides.',
    'Discover new places, one bus ride after another.',
  ];

  @override
  void dispose() {
    super.dispose();
    isloding = false;
    mobileController.dispose();
    mobileController1.dispose();
    passwordController.dispose();
    passwordController1.dispose();
    newpasswordController.dispose();
    conformpasswordController.dispose();
  }

  bool isloding = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController rcodeController = TextEditingController();

  MasgapiController masgapiController = Get.put(MasgapiController());
  TwilioapiController twilioapiController = Get.put(TwilioapiController());
  SignupApiController signupApiController = Get.put(SignupApiController());
  ForGotApiController forGotApiController = Get.put(ForGotApiController());
  SmstypeApiController smstypeApiController = Get.put(SmstypeApiController());

  String phonenumber = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future _signInWithMobileNumber(String usertype) async {
    setState(() {
      isloding = true;
    });

    if (smstypeApiController.smaApiModel!.otpAuth == "Yes") {
      if (smstypeApiController.smaApiModel!.smsType == "Msg91") {
        print("----ccode signup------:-- ${ccode1}");
        print("-----mobileController.text signup-----:-- ${mobileController1.text}");

        masgapiController.msgApi(mobilenumber: ccode1 + mobileController1.text, context: context).then((value) {
          setState(() {
            isloding = false;
          });
          Get.bottomSheet(Otp_Screen(
            verificationId: "",
            ccode: ccode1,
            email: emailController.text,
            name: nameController.text,
            mobile: mobileController1.text,
            password: passwordController1.text,
            rcode: rcodeController.text,
            agettype: usertype,
            verId: masgapiController.msgApiModel!.otp.toString(),
          )).then((value) {});
        });
      } else if (smstypeApiController.smaApiModel!.smsType == "Twilio") {
        twilioapiController.twilioApi(mobilenumber: ccode1 + mobileController1.text, context: context).then((value) {
          setState(() {
            isloding = false;
          });
          Get.bottomSheet(Otp_Screen(
            verificationId: "",
            ccode: ccode1,
            email: emailController.text,
            name: nameController.text,
            mobile: mobileController1.text,
            password: passwordController1.text,
            rcode: rcodeController.text,
            agettype: usertype,
            verId: twilioapiController.twilioApiModel!.otp.toString(),
          )).then((value) {});
        });
      } else {
        Fluttertoast.showToast(msg: "No Service".tr);
      }
    } else {
      setState(() {
        isloding = false;
      });
      Get.back();

      signupApiController.signupapi(
        name: nameController.text,
        email: emailController.text,
        mobile: mobileController1.text,
        password: passwordController1.text,
        ccode: ccode1,
        rcode: rcodeController.text,
        agettype: usertype,
      ).then((value) {
        print("+++++++++++++++$value");
        if (value["ResponseCode"] == "200") {
          Fluttertoast.showToast(msg: value["ResponseMsg"]);
          OneSignal.User.addTagWithKey("user_id", value["UserLogin"]["id"]);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Bottom_Navigation()),
                (route) => false,
          );
        } else {
          Fluttertoast.showToast(msg: value["ResponseMsg"]);
        }
      });
    }
  }

  bool isPassword = false;

  // Forgot screen code
  String ccodeforgot = "";
  String phonenumberforgot = '';
  TextEditingController mobileControllerforgot = TextEditingController();

  final FirebaseAuth _auth1 = FirebaseAuth.instance;

  Future<void> bootomshet() {
    return Get.bottomSheet(
      isScrollControlled: true,
      Container(
        height: 250,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 15),
              const Text('Create A New Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 15),
              CommonTextfiled2(txt: 'New Password', controller: newpasswordController, context: context),
              const SizedBox(height: 15),
              CommonTextfiled2(txt: 'Confirm Password', controller: conformpasswordController, context: context),
              const SizedBox(height: 15),
              CommonButton(
                containcolore: notifier.theamcolorelight,
                txt1: 'Confirm',
                context: context,
                onPressed1: () {
                  print("dsddds");
                  if (newpasswordController.text.compareTo(conformpasswordController.text) == 0) {
                    forGotApiController.Forgot(mobileController.text, ccode, conformpasswordController.text).then((value) {
                      print("++++++${value}");
                      if (value["ResponseCode"] == "200") {
                        Get.back();
                        Fluttertoast.showToast(msg: value["ResponseMsg"]);
                      } else {
                        Fluttertoast.showToast(msg: value["ResponseMsg"]);
                      }
                    });
                  } else {
                    Fluttertoast.showToast(msg: "Please enter current password");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  _signInWithMobileNumber1() async {
    setState(() {
      isloding = true;
    });

    if (smstypeApiController.smaApiModel!.otpAuth == "Yes") {
      if (smstypeApiController.smaApiModel!.smsType == "Msg91") {
        print("----ccode------:-- ${ccode}");
        print("-----mobileController.text-----:-- ${mobileController.text}");

        masgapiController.msgApi(mobilenumber: ccode + mobileController.text, context: context).then((value) {
          setState(() {
            isloding = false;
          });
          Get.bottomSheet(Otp_Verfication_Forgot(
            verificationId: "",
            ccode: ccode,
            mobileNumber: mobileController.text,
            verId: masgapiController.msgApiModel!.otp.toString(),
          )).then((value) {});
        });
      } else if (smstypeApiController.smaApiModel!.smsType == "Twilio") {
        twilioapiController.twilioApi(mobilenumber: ccode + mobileController.text, context: context).then((value) {
          setState(() {
            isloding = false;
          });
          Get.bottomSheet(Otp_Verfication_Forgot(
            verificationId: "",
            ccode: ccode,
            mobileNumber: mobileController.text,
            verId: twilioapiController.twilioApiModel!.otp.toString(),
          )).then((value) {});
        });
      } else {
        Fluttertoast.showToast(msg: "No Service".tr);
      }
    } else {
      setState(() {
        isloding = false;
      });
      Get.back();
      bootomshet();
    }
  }

  // 1 time Login and remove code
  resetNew() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLogin', false);
  }

  bool passwordvalidate = false;
  bool? isLogin;

  @override
  void initState() {
    SearchGet();
    smstypeApiController.smsApi(context);
    super.initState();
  }

  ColorNotifier notifier = ColorNotifier();
  int langth = 10;

  // GET API CALLING
  Agentsignup? from12;

  Future SearchGet() async {
    try {
      var response1 = await http.get(Uri.parse('${config().baseUrl}/api/agent_status.php'));
      if (response1.statusCode == 200) {
        var jsonData = json.decode(response1.body);
        print(jsonData["citylist"]);
        setState(() {
          from12 = agentsignupFromJson(response1.body);
        });
      }
    } catch (e) {
      print('Erreur SearchGet: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return WillPopScope(
      onWillPop: () async {
        setState(() {
          referralcode = false;
        });
        return Future(() => false);
      },
      child: Scaffold(
        bottomNavigationBar: Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.4)),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text('Welcome To kkc_reservation'.tr, style: TextStyle(fontFamily: 'SofiaProBold', fontSize: 16, color: notifier.textColor)),
                      const SizedBox(height: 6),
                      Text('We Will send OTP on this mobile number.'.tr, style: TextStyle(fontWeight: FontWeight.bold, color: notifier.textColor)),
                      const SizedBox(height: 20),
                      IntlPhoneField(
                        controller: mobileController,
                        style: TextStyle(color: notifier.textColor),
                        decoration: InputDecoration(
                          counterText: "",
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.4)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.only(top: 8),
                          hintText: 'Phone Number'.tr,
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: notifier.theamcolorelight),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        flagsButtonPadding: EdgeInsets.zero,
                        showCountryFlag: false,
                        showDropdownIcon: false,
                        initialCountryCode: 'IN',
                        dropdownTextStyle: TextStyle(color: notifier.textColor, fontSize: 15),
                        onChanged: (number) {
                          setState(() {
                            ccode = number.countryCode;
                            passwordController.text.isEmpty ? passwordvalidate = true : false;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      isPassword
                          ? Column(
                        children: [
                          CommonTextfiled10(controller: passwordController, txt: 'Enter Your Password'.tr, context: context),
                          const SizedBox(height: 10)
                        ],
                      )
                          : const SizedBox(),
                      const SizedBox(height: 0),
                      CommonButton(
                        txt1: 'PROCEED'.tr,
                        containcolore: notifier.theamcolorelight,
                        context: context,
                        onPressed1: () async {
                          if (mobileController.text.isNotEmpty) {
                            try {
                              // CORRECTION PRINCIPALE ICI
                              var value = await mobileCheck(mobileController.text, ccode);

                              // Vérification sécurisée de la réponse
                              if (value != null && value is Map<String, dynamic>) {
                                if (value["Result"] == "true") {
                                  setState(() {
                                    isPassword = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Number is not register'.tr),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  );
                                } else {
                                  setState(() {
                                    isPassword = true;
                                  });

                                  // LOGIN API CALLING CODE
                                  if (mobileController.text.isNotEmpty && passwordController.text.isNotEmpty) {
                                    try {
                                      var loginResult = await login(mobileController.text, ccode, passwordController.text);

                                      print("Login result: $loginResult");

                                      if (loginResult != null && loginResult is Map<String, dynamic>) {
                                        if (loginResult["ResponseCode"] == "200") {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(loginResult["ResponseMsg"] ?? "Connexion réussie"),
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                          );
                                          OneSignal.User.addTagWithKey("user_id", loginResult["UserLogin"]["id"]);
                                          resetNew();
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(builder: (context) => const Bottom_Navigation()),
                                                (route) => false,
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(loginResult["ResponseMsg"] ?? "Erreur de connexion"),
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                          );
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text("Erreur de connexion - Réponse invalide"),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      print("Erreur lors de la connexion: $e");
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Erreur de connexion: ${e.toString()}"),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                      );
                                    }
                                  }
                                }
                              } else {
                                // Gérer le cas où la réponse est null ou invalide
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Erreur de vérification du numéro"),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                );
                              }
                            } catch (e) {
                              print("Erreur lors de la vérification mobile: $e");
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Erreur de connexion: ${e.toString()}"),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Veuillez entrer un numéro de téléphone"),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          }

                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: InkWell(
                          onTap: () async {
                            if (mobileController.text.isNotEmpty) {
                              try {
                                var value = await mobileCheck(mobileController.text, ccode);

                                if (value != null && value is Map<String, dynamic>) {
                                  if (value["Result"] == "true") {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Number is not register'.tr),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                    );
                                  } else {
                                    // ForGot API CALLING CODE
                                    _signInWithMobileNumber1();
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Erreur de vérification du numéro"),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  );
                                }
                              } catch (e) {
                                print("Erreur forgot password: $e");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Erreur de connexion: ${e.toString()}"),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Veuillez entrer un numéro de téléphone"),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            }
                          },
                          child: Text('Forgot Password ?'.tr, style: TextStyle(fontSize: 16, fontFamily: 'SofiaProBold', color: notifier.textColor)),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                const Divider(color: Colors.grey),
                InkWell(
                  onTap: () {
                    bottomSheet("USER", 'Create Account Or Sign in');
                  },
                  child: Text("Don't Have an account yet? Sign Up".tr, style: TextStyle(fontFamily: 'SofiaProBold', fontSize: 15, color: Colors.indigoAccent[700])),
                ),
                const SizedBox(height: 10),
                from12?.agentStatus == "1"
                    ? InkWell(
                  onTap: () {
                    bottomSheet("AGENT", 'Enlist as a kkc_reservation Partner now!');
                  },
                  child: Text("Join us as a kkc_reservation Partner today!".tr, style: const TextStyle(fontFamily: 'SofiaProBold', fontSize: 13, color: Colors.green)),
                )
                    : const SizedBox(),
                from12?.agentStatus == "1" ? const SizedBox(height: 10) : const SizedBox(),
              ],
            ),
          ),
        ),
        backgroundColor: notifier.background,
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          child: Stack(
            children: [
              SizedBox(
                height: Get.height,
                child: Column(
                  children: <Widget>[
                    const Spacer(flex: 1),
                    Column(
                      children: [
                        const Image(image: AssetImage('assets/logo.png'), height: 70, width: 70),
                        Text('kkc_reservation'.tr, style: TextStyle(color: notifier.theamcolorelight, fontSize: 20, fontFamily: 'SofiaProBold')),
                      ],
                    ),
                    const Spacer(flex: 1),
                    CarouselSlider(
                      items: [
                        for (int a = 0; a < lottie12.length; a++)
                          Column(
                            children: [
                              Lottie.asset(lottie12[a], height: 200),
                              const SizedBox(height: 30),
                              Text(title[a].toString().tr, style: TextStyle(color: notifier.textColor, fontFamily: 'SofiaProBold', fontSize: 18)),
                              const SizedBox(height: 5),
                              Container(
                                height: 2,
                                width: 70,
                                color: notifier.theamcolorelight,
                              ),
                              const SizedBox(height: 15),
                              Expanded(
                                child: SizedBox(
                                  width: 200,
                                  child: Text('${description[a]}', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center),
                                ),
                              ),
                            ],
                          ),
                      ],
                      options: CarouselOptions(
                        height: 345,
                        viewportFraction: 0.8,
                        initialPage: 0,
                        enableInfiniteScroll: true,
                        reverse: false,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 2),
                        autoPlayAnimationDuration: const Duration(milliseconds: 800),
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enlargeCenterPage: true,
                        enlargeFactor: 0.3,
                        scrollDirection: Axis.horizontal,
                      ),
                    ),
                    const Spacer(flex: 10),
                  ],
                ),
              ),
              isloding ? Center(child: Padding(padding: const EdgeInsets.only(top: 400), child: CircularProgressIndicator(color: notifier.theamcolorelight))) : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget referralcontain() {
    return Column(
      children: [
        CommonTextfiled2(txt: 'Enter referral code (optional)'.tr, context: context),
        const SizedBox(height: 20),
      ],
    );
  }

  Future getDataFromLocal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLogin = prefs.getBool("isLogin".tr) ?? true;
    });
    print(isLogin);
  }

  Future bottomSheet(String userType, String toptext) {
    return Get.bottomSheet(
      isScrollControlled: true,
      StatefulBuilder(builder: (context, setState) {
        return Container(
          decoration: BoxDecoration(
            color: notifier.containercoloreproper,
            borderRadius: const BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15)),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 10),
                Text(toptext.tr, style: TextStyle(color: notifier.textColor, fontSize: 20, fontFamily: 'SofiaProBold')),
                const SizedBox(height: 10),
                CommonTextfiled2(txt: 'Enter Your Name'.tr, controller: nameController, context: context),
                const SizedBox(height: 10),
                CommonTextfiled2(txt: 'Enter Your Email Id'.tr, controller: emailController, context: context),
                const SizedBox(height: 10),
                IntlPhoneField(
                  controller: mobileController1,
                  decoration: InputDecoration(
                    counterText: "",
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.4)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.only(top: 8),
                    hintText: 'Phone Number'.tr,
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: notifier.theamcolorelight),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  style: TextStyle(color: notifier.textColor),
                  flagsButtonPadding: EdgeInsets.zero,
                  showCountryFlag: false,
                  showDropdownIcon: false,
                  initialCountryCode: 'IN',
                  dropdownTextStyle: TextStyle(color: notifier.textColor, fontSize: 15),
                  onCountryChanged: (value) {
                    setState(() {
                      langth = value.maxLength;
                      mobileController1.clear();
                    });
                  },
                  onChanged: (number) {
                    setState(() {
                      ccode1 = number.countryCode;
                    });
                  },
                ),
                const SizedBox(height: 10),
                CommonTextfiled10(txt: 'Enter Your Password'.tr, controller: passwordController1, context: context),
                const SizedBox(height: 10),
                referralcode ? referralcontain() : const SizedBox(),
                CommonButton(
                  txt1: 'GENERATE OTP'.tr,
                  txt2: '(ONE TIME PASSWORD)'.tr,
                  containcolore: notifier.theamcolorelight,
                  context: context,
                  onPressed1: () async {
                    if (mobileController1.text.length == langth) {
                      try {
                        // CORRECTION ICI AUSSI
                        var value = await mobileCheck(mobileController1.text, ccode1);

                        if (mobileController1.text.isNotEmpty) {
                          if (value != null && value is Map<String, dynamic>) {
                            if (value["Result"] == "true") {
                              if (nameController.text.isNotEmpty &&
                                  emailController.text.isNotEmpty &&
                                  mobileController1.text.isNotEmpty &&
                                  passwordController1.text.isNotEmpty) {
                                print("ssssss");
                                Get.back();
                                _signInWithMobileNumber(userType);
                                setState(() {
                                  isloding = true;
                                });
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(value["ResponseMsg"] ?? "Numéro déjà enregistré"),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Erreur de vérification du numéro"),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Veuillez entrer un numéro de téléphone"),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        }
                      } catch (e) {
                        print("Erreur signup mobile check: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Erreur de connexion: ${e.toString()}"),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      }
                      Get.back();
                    }
                  },
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        referralcode = !referralcode;
                        print('${referralcode}');
                      });
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Divider(color: Colors.grey),
                        Text("HAVE A REFERRAL CODE?".tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.indigoAccent[700])),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
