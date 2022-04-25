import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import 'Color.dart';
import 'Constant.dart';
import 'String.dart';

setPrefrence(String key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

Future<String?> getPrefrence(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

setPrefrenceBool(String key, bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool(key, value);
}

Future<bool> getPrefrenceBool(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool(key) ?? false;
}

Future<bool> isNetworkAvailable() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    return true;
  } else if (connectivityResult == ConnectivityResult.wifi) {
    return true;
  }
  return false;
}

back() {
  return const BoxDecoration(
    color: primary,
  );
}

shadow() {
  return const BoxDecoration(
    boxShadow: [
      BoxShadow(color: Color(0x1a0400ff), offset: Offset(0, 0), blurRadius: 30)
    ],
  );
}

placeHolder(double height) {
  return const AssetImage(
    'assets/images/placeholder.png',
  );
}

errorWidget(double size) {
  return Icon(
    Icons.account_circle,
    color: Colors.grey,
    size: size,
  );
}

getAppBar(String title, BuildContext context) {
  return AppBar(
    leading: Builder(builder: (BuildContext context) {
      return Container(
        margin: const EdgeInsets.all(10),
        decoration: shadow(),
        child: Card(
          elevation: 0,
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () => Navigator.of(context).pop(),
            child: const Center(
              child: Icon(
                Icons.keyboard_arrow_left,
                color: primary,
              ),
            ),
          ),
        ),
      );
    }),
    title: Text(
      title,
      style: const TextStyle(
        color: fontColor,
      ),
    ),
    backgroundColor: white,
  );
}

noIntImage() {
  return Image.asset(
    'assets/images/no_internet.png',
    fit: BoxFit.contain,
  );
}

noIntText(BuildContext context) {
  return Text(NO_INTERNET,
      style: Theme.of(context)
          .textTheme
          .headline5!
          .copyWith(color: primary, fontWeight: FontWeight.normal));
}

noIntDec(BuildContext context) {
  return Container(
    padding: const EdgeInsets.only(top: 30.0, left: 30.0, right: 30.0),
    child: Text(NO_INTERNET_DISC,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headline6!.copyWith(
              color: lightfontColor2,
              fontWeight: FontWeight.normal,
            )),
  );
}

Widget showCircularProgress(bool _isProgress, Color color) {
  if (_isProgress) {
    return Center(
        child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(color),
    ));
  }
  return const SizedBox(
    height: 0.0,
    width: 0.0,
  );
}

imagePlaceHolder(double size) {
  return SizedBox(
    height: size,
    width: size,
    child: Icon(
      Icons.account_circle,
      color: white,
      size: size,
    ),
  );
}

Future<void> clearUserSession() async {
  final waitList = <Future<void>>[];

  SharedPreferences prefs = await SharedPreferences.getInstance();

  waitList.add(prefs.remove(ID));
  waitList.add(prefs.remove(MOBILE));
  waitList.add(prefs.remove(EMAIL));
  CUR_USERID = '';
  CUR_USERNAME = "";
  CUR_BALANCE = '';

  await prefs.clear();
}

Future<void> saveUserDetail(
    String userId, String name, String email, String mobile) async {
  final waitList = <Future<void>>[];
  SharedPreferences prefs = await SharedPreferences.getInstance();
  waitList.add(prefs.setString(ID, userId));
  waitList.add(prefs.setString(USERNAME, name));
  waitList.add(prefs.setString(EMAIL, email));
  waitList.add(prefs.setString(MOBILE, mobile));
  await Future.wait(waitList);
}

String? validateField(String? value) {
  if (value!.isEmpty) {
    return FIELD_REQUIRED;
  } else {
    return null;
  }
}

String? validateUserName(String? value) {
  if (value!.isEmpty) {
    return USER_REQUIRED;
  }
  if (value.length <= 1) {
    return USER_LENGTH;
  }
  return null;
}

String? validateMob(String? value) {
  if (value!.isEmpty) {
    return MOB_REQUIRED;
  }
  if (value.length < 9) {
    return VALID_MOB;
  }
  return null;
}

String? validatePass(String? value) {
  if (value!.isEmpty) {
    return PWD_REQUIRED;
  } else if (value.length <= 5) {
    return PWD_LENGTH;
  } else {
    return null;
  }
}

String? validateAltMob(String value) {
  if (value.isNotEmpty) if (value.length < 9) {
    return VALID_MOB;
  }
  return null;
}

Widget getProgress() {
  return const Center(child: CircularProgressIndicator());
}

Widget getNoItem() {
  return const Center(child: Text(noItem));
}

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

Widget shimmer() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
    child: Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Column(
          children: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
              .map((_) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80.0,
                          height: 80.0,
                          color: white,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 18.0,
                                color: white,
                              ),
                              const Padding(
                                padding:
                                    EdgeInsets.symmetric(vertical: 5.0),
                              ),
                              Container(
                                width: double.infinity,
                                height: 8.0,
                                color: white,
                              ),
                              const Padding(
                                padding:
                                    EdgeInsets.symmetric(vertical: 5.0),
                              ),
                              Container(
                                width: 100.0,
                                height: 8.0,
                                color: white,
                              ),
                              const Padding(
                                padding:
                                    EdgeInsets.symmetric(vertical: 5.0),
                              ),
                              Container(
                                width: 20.0,
                                height: 8.0,
                                color: white,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
    ),
  );
}

String getToken() {
  final claimSet =
      JwtClaim(issuer: 'eshop', maxAge: const Duration(minutes: 50));

  String token = issueJwtHS256(claimSet, jwtKey);
  print("token*****$token");
  return token;
}

String? getPriceFormat(BuildContext context, double price) {
  return NumberFormat.currency(
      locale: Platform.localeName,
      name: SUPPORTED_LOCALES,
      symbol: CUR_CURRENCY)
      .format(price)
      .toString();
}



Map<String, String> get headers => {
      "Authorization": 'Bearer ' + getToken(),
    };


