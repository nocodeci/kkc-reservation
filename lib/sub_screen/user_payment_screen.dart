// ignore_for_file: camel_case_types, file_names, non_constant_identifier_names, avoid_print, depend_on_referenced_packages, prefer_typing_uninitialized_variables, deprecated_member_use

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../API_MODEL/couponlist_api_model.dart';
import '../API_MODEL/referdata_api_model.dart';
import 'package:http/http.dart' as http;
import '../All_Screen/bottom_navigation_bar_screen.dart';
import '../Common_Code/homecontroller.dart';
import '../config/config.dart';
import '../config/light_and_dark.dart';

class BookingSummaryScreen extends StatefulWidget {
  final String busTitle;
  final String busImg;
  final String ticketPrice;
  final String boardingCity;
  final String dropCity;
  final String busPicktime;
  final String busDroptime;
  final String mobileController;
  final String FullnameController;
  final String EmailController;
  final String uid;
  final List DataStore;
  final String selectIndex;
  final String selectIndex1;
  final List selectset;
  final List selectset1;
  final num bottom;
  final String wallet;
  final List ma_fe;
  final List data;
  final List data1;
  final String busAc;
  final String isSleeper;
  final String totlSeat;
  final String differencePickDrop;
  final String currency;
  final String bus_id;
  final String pick_id;
  final String dropId;
  final String trip_date;
  final List listDynamic;
  final List listDynamicage;
  final List siteNumber;
  final List manadf;
  final String boarding_id;
  final String drop_id;
  final String Difference_pick_drop;
  final String pick_time;
  final String pickTime;
  final String pick_place;
  final String pick_address;
  final String pick_mobile;
  final String dropTime;
  final String drop_time;
  final String drop_place;
  final String drop_address;
  final String pickMobile;
  final String agentCommission;
  final String com_per;
  final String is_verify;
  final String operator_id;

  const BookingSummaryScreen({
    super.key,
    required this.busTitle,
    required this.busImg,
    required this.ticketPrice,
    required this.boardingCity,
    required this.dropCity,
    required this.busPicktime,
    required this.busDroptime,
    required this.mobileController,
    required this.FullnameController,
    required this.EmailController,
    required this.uid,
    required this.DataStore,
    required this.selectIndex,
    required this.selectIndex1,
    required this.selectset,
    required this.selectset1,
    required this.bottom,
    required this.wallet,
    required this.ma_fe,
    required this.data,
    required this.data1,
    required this.busAc,
    required this.isSleeper,
    required this.totlSeat,
    required this.differencePickDrop,
    required this.currency,
    required this.bus_id,
    required this.pick_id,
    required this.dropId,
    required this.trip_date,
    required this.listDynamic,
    required this.listDynamicage,
    required this.siteNumber,
    required this.manadf,
    required this.boarding_id,
    required this.drop_id,
    required this.Difference_pick_drop,
    required this.pickTime,
    required this.pick_place,
    required this.pick_address,
    required this.pick_mobile,
    required this.dropTime,
    required this.drop_place,
    required this.drop_address,
    required this.pick_time,
    required this.drop_time,
    required this.pickMobile,
    required this.agentCommission,
    required this.com_per,
    required this.is_verify,
    required this.operator_id,
  });

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  bool isloading = true;
  Referdata? data;
  Couponlist? data1;

  List siteNumber = [];
  double totalAmount = 0.0;
  double totallist = 0.0;
  double finaltotal = 0.0;
  double totalamount2 = 0.0;
  double walet = 0.0;
  bool light = false;
  int coupon = 0;

  var result;
  var userData;
  var searchbus1;
  var taxamount;

  List PessengerData = [];
  bool off = false;
  List isReademore = [];

  double walletMain = 0;
  double totalPayment = 0;
  double walletValue = 0;

  HomeController homeController = Get.put(HomeController());
  ColorNotifier notifier = ColorNotifier();

  @override
  void initState() {
    super.initState();
    getlocledata();
    fun12();
    walletMain = double.parse(widget.wallet);

    Referdata_Api(widget.uid).then((value) {
      setState(() {
        siteNumber = widget.selectset + widget.selectset1;
        totalamount2 = totalAmount;
      });
    });
    CouponList_Api(widget.uid);

    setState(() {
      siteNumber = widget.selectset;
    });
  }

  @override
  void dispose() {
    widget.DataStore.clear();
    super.dispose();
  }

  // Referdata Api Calling
  Future Referdata_Api(String uid) async {
    Map body = {
      'uid': uid,
    };

    try {
      var response = await http.post(
        Uri.parse('${config().baseUrl}/api/referdata.php'),
        body: jsonEncode(body),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          data = referdataFromJson(response.body);
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // CouponList Api Calling
  Future CouponList_Api(String uid) async {
    Map body = {
      'uid': uid,
      'operator_id': widget.operator_id,
    };

    try {
      var response = await http.post(
        Uri.parse('${config().baseUrl}/api/u_couponlist.php'),
        body: jsonEncode(body),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          data1 = couponlistFromJson(response.body);
          isloading = false;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  fun12() {
    setState(() {
      for (int a = 0; a < widget.listDynamic.length; a++) {
        PessengerData.add({
          "name": "${widget.data[a]}",
          "age": "${widget.data1[a]}",
          "gender": widget.manadf[a].toString().split("-").first
        });
      }
    });
  }

  getlocledata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userData = jsonDecode(prefs.getString("loginData")!);
      searchbus1 = jsonDecode(prefs.getString("bussearch")!);
      taxamount = jsonDecode(prefs.getString("tax")!);
    });
  }

  void _showBookingConfirmation() {
    showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (!didPop) {
            homeController.setselectpage(0);
            Get.offAll(const Bottom_Navigation());
          }
        },
        child: AlertDialog(
          backgroundColor: notifier.containercoloreproper,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              SizedBox(
                height: 150,
                width: 150,
                child: Lottie.asset(
                  'assets/lottie/ticket-confirm.json',
                  fit: BoxFit.cover,
                ),
              ),
              Text(
                'Booking Summary Saved!'.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xff7D2AFF),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your booking details have been saved. Payment functionality will be available soon.'.tr,
                style: TextStyle(
                  color: notifier.textColor,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Bottom_Navigation(),
                    ),
                  );
                  homeController.setselectpage(1);
                },
                style: ButtonStyle(
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  backgroundColor: const WidgetStatePropertyAll(Color(0xff7D2AFF)),
                ),
                child: Text(
                  'View Bookings'.tr,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Bottom_Navigation(),
                    ),
                  );
                },
                style: ButtonStyle(
                  elevation: const WidgetStatePropertyAll(0),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  backgroundColor: const WidgetStatePropertyAll(Colors.white),
                ),
                child: Text(
                  'Back to Home'.tr,
                  style: const TextStyle(color: Color(0xff7D2AFF)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);

    // Calculer le total
    totalPayment = widget.bottom + (widget.bottom * int.parse(taxamount ?? "0") / 100);
    totallist = widget.bottom * int.parse(taxamount ?? "0") / 100;

    return Scaffold(
      bottomNavigationBar: Container(
        height: 60,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: notifier.containercoloreproper,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(10),
            topLeft: Radius.circular(10),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Amount'.tr,
                    style: TextStyle(color: notifier.textColor, fontSize: 14),
                  ),
                  Text(
                    '${widget.currency} ${totalPayment.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: notifier.textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                height: 35,
                width: 120,
                decoration: BoxDecoration(
                  color: notifier.theamcolorelight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(notifier.theamcolorelight),
                    shape: const WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                  onPressed: () {
                    if (widget.is_verify == "0") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            widget.is_verify == "2"
                                ? "Your profile has been declined, resulting in the loss of regular user access to our application"
                                : 'Once your profile is verified, you will be able to book bus tickets and earn commissions.',
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    } else {
                      // Afficher le résumé au lieu de procéder au paiement
                      _showBookingConfirmation();
                    }
                  },
                  child: Center(
                    child: Text(
                      'SAVE BOOKING'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: notifier.backgroundgray,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        backgroundColor: notifier.appbarcolore,
        title: Transform.translate(
          offset: const Offset(-15, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.boardingCity} to ${widget.dropCity}',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
              const SizedBox(height: 5),
              Text(
                widget.trip_date.toString().split(" ").first,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
      body: isloading
          ? Center(
        child: CircularProgressIndicator(color: notifier.theamcolorelight),
      )
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 10),
          child: Column(
            children: [
              const SizedBox(height: 5),

              // Bus Details Section
              _buildBusDetailsSection(),

              const SizedBox(height: 15),

              // Contact Details Section
              _buildContactDetailsSection(),

              const SizedBox(height: 15),

              // Passengers Section
              _buildPassengersSection(),

              const SizedBox(height: 15),

              // Price Details Section
              _buildPriceDetailsSection(),

              const SizedBox(height: 15),

              // Payment Coming Soon Notice
              _buildPaymentNoticeSection(),

              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBusDetailsSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: notifier.containercoloreproper,
        borderRadius: BorderRadius.circular(0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                const Image(image: AssetImage('assets/Rectangle_2.png'), height: 40),
                const SizedBox(width: 15),
                Container(
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                    color: notifier.theamcolorelight,
                    borderRadius: BorderRadius.circular(65),
                    image: DecorationImage(
                      image: NetworkImage('${config().baseUrl}/${widget.busImg}'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.busTitle,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: notifier.textColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          if (widget.busAc == '1')
                            Text(
                              'AC Seater'.tr,
                              style: TextStyle(fontSize: 12, color: notifier.textColor),
                            ),
                          if (widget.isSleeper == '1')
                            Text(
                              'Non Ac / Sleeper'.tr,
                              style: TextStyle(fontSize: 12, color: notifier.textColor),
                            ),
                          const SizedBox(width: 5),
                          Container(
                            height: 22,
                            width: 65,
                            decoration: BoxDecoration(
                              color: notifier.seatcontainere,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Text(
                                  '${widget.totlSeat} Seats',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: notifier.seattextcolore,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  '${widget.currency} ${widget.ticketPrice}',
                  style: TextStyle(
                    color: notifier.theamcolorelight,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: SizedBox(
                    width: 120,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.boardingCity,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: notifier.textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          convertTimeTo12HourFormat(widget.busPicktime),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: notifier.theamcolorelight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    Image(
                      image: const AssetImage('assets/Auto Layout Horizontal.png'),
                      height: 50,
                      width: 120,
                      color: notifier.theamcolorelight,
                    ),
                    Text(
                      widget.differencePickDrop,
                      style: TextStyle(fontSize: 12, color: notifier.textColor),
                    ),
                  ],
                ),
                Flexible(
                  child: SizedBox(
                    width: 120,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          widget.dropCity,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: notifier.textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          convertTimeTo12HourFormat(widget.busDroptime),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: notifier.theamcolorelight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactDetailsSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(color: notifier.containercoloreproper),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Image(image: AssetImage('assets/Rectangle_2.png'), height: 40),
                const SizedBox(width: 15),
                Text(
                  'Contact Details'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: notifier.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Full Name'.tr, widget.FullnameController),
            const SizedBox(height: 15),
            _buildDetailRow('Email'.tr, widget.EmailController),
            const SizedBox(height: 15),
            _buildDetailRow('Phone Number'.tr, widget.mobileController),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: notifier.textColor),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: notifier.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPassengersSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(color: notifier.containercoloreproper),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Image(image: AssetImage('assets/Rectangle_2.png'), height: 40),
                const SizedBox(width: 15),
                Text(
                  'Passenger(S)'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: notifier.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Table(
              columnWidths: const <int, TableColumnWidth>{
                0: FixedColumnWidth(200),
                1: FixedColumnWidth(40),
                2: FixedColumnWidth(40),
              },
              children: <TableRow>[
                TableRow(
                  children: <Widget>[
                    Text(
                      'Name'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: notifier.textColor,
                      ),
                    ),
                    Center(
                      child: Text(
                        'Age'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: notifier.textColor,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        'Seat'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: notifier.textColor,
                        ),
                      ),
                    ),
                  ],
                ),
                for (int a = 0; a < widget.data.length; a++)
                  TableRow(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Text(
                          '${widget.data[a]} (${widget.ma_fe[a].toString().split("-").first})',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: notifier.textColor,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Center(
                          child: Text(
                            '${widget.data1[a]}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: notifier.textColor,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Center(
                          child: Text(
                            '${siteNumber.isNotEmpty && a < siteNumber.length ? siteNumber[a] : 'N/A'}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: notifier.textColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceDetailsSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(color: notifier.containercoloreproper),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Image(image: AssetImage('assets/Rectangle_2.png'), height: 40),
                const SizedBox(width: 15),
                Text(
                  'Price Details'.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: notifier.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildPriceRow('Price'.tr, '${widget.currency} ${widget.bottom.toStringAsFixed(2)}'),
            const SizedBox(height: 15),
            _buildPriceRow('Tax(${taxamount ?? 0}%)', '${widget.currency} ${totallist.toStringAsFixed(2)}'),
            const SizedBox(height: 15),
            _buildPriceRow('Discount'.tr, '${widget.currency} ${coupon.toStringAsFixed(2)}', isDiscount: true),
            const SizedBox(height: 8),
            Divider(color: Colors.grey.withOpacity(0.4)),
            const SizedBox(height: 8),
            _buildPriceRow('Total Price'.tr, '${widget.currency} ${totalPayment.toStringAsFixed(2)}', isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isDiscount = false, bool isBold = false}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: notifier.textColor,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: isDiscount ? Colors.green : notifier.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentNoticeSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: notifier.containercoloreproper,
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.orange,
              size: 30,
            ),
            const SizedBox(height: 10),
            Text(
              'Payment Feature Coming Soon'.tr,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: notifier.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Payment functionality is currently under development. You can save your booking details for now.'.tr,
              style: TextStyle(
                fontSize: 12,
                color: notifier.textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Fonction utilitaire pour convertir l'heure
String convertTimeTo12HourFormat(String time24) {
  try {
    final parts = time24.split(':');
    if (parts.length >= 2) {
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      String period = hour >= 12 ? 'PM' : 'AM';
      hour = hour % 12;
      if (hour == 0) hour = 12;

      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    }
  } catch (e) {
    print('Error converting time: $e');
  }
  return time24;
}
