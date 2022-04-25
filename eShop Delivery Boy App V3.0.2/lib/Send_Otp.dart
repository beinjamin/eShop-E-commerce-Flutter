import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';

import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'Privacy_Policy.dart';
import 'Verify_Otp.dart';

class SendOtp extends StatefulWidget {
  String? title;

  SendOtp({Key? key, this.title}) : super(key: key);

  @override
  _SendOtpState createState() => _SendOtpState();
}

class _SendOtpState extends State<SendOtp> with TickerProviderStateMixin {
  bool visible = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final mobileController = TextEditingController();
  final ccodeController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String? mobile, id, countrycode, countryName, mobileno;
  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  Future<void> checkNetwork() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      getVerifyUser();
    } else {
      Future.delayed(const Duration(seconds: 2)).then((_) async {
        setState(() {
          _isNetworkAvail = false;
        });
        await buttonController!.reverse();
      });
    }
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;
    form.save();
    if (form.validate()) {
      return true;
    }

    return false;
  }

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar( SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: const TextStyle(color: fontColor),
      ),
      backgroundColor: lightWhite,
      elevation: 1.0,
    ));
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: kToolbarHeight),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          noIntImage(),
          noIntText(context),
          noIntDec(context),
          AppBtn(
            title: TRY_AGAIN_INT_LBL,
            btnAnim: buttonSqueezeanimation,
            btnCntrl: buttonController,
            onBtnSelected: () async {
              _playAnimation();

              Future.delayed(const Duration(seconds: 2)).then((_) async {
                _isNetworkAvail = await isNetworkAvailable();
                if (_isNetworkAvail) {
                  Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                          builder: (BuildContext context) => super.widget));
                } else {
                  await buttonController!.reverse();
                  setState(() {});
                }
              });
            },
          )
        ]),
      ),
    );
  }

  Future<void> getVerifyUser() async {
    try {
      var data = {MOBILE: mobile};
      Response response =
          await post(getVerifyUserApi, body: data, headers: headers)
              .timeout(const Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      bool? error = getdata["error"];
      String? msg = getdata["message"];
      await buttonController!.reverse();

      if (widget.title == SEND_OTP_TITLE) {
        if (!error!) {
          setSnackbar(msg!);

          setPrefrence(MOBILE, mobile!);
          setPrefrence(COUNTRY_CODE, countrycode!);
          Future.delayed(const Duration(seconds: 1)).then((_) {
            Navigator.pushReplacement(
                context,
                CupertinoPageRoute(
                    builder: (context) => VerifyOtp(
                          mobileNumber: mobile!,
                          countryCode: countrycode,
                          title: SEND_OTP_TITLE,
                        )));
          });
        } else {
          setSnackbar(msg!);
        }
      }
      if (widget.title == FORGOT_PASS_TITLE) {
        if (!error!) {
          setPrefrence(MOBILE, mobile!);
          setPrefrence(COUNTRY_CODE, countrycode!);

          Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                  builder: (context) => VerifyOtp(
                        mobileNumber: mobile!,
                        countryCode: countrycode,
                        title: FORGOT_PASS_TITLE,
                      )));
        } else {
          setSnackbar(msg!);
        }
      }
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
      await buttonController!.reverse();
    }
  }

  subLogo() {
    return Expanded(
      flex: widget.title == SEND_OTP_TITLE ? 4 : 5,
      child: Center(
        child: Image.asset('assets/images/homelogo.png'),
      ),
    );
  }

  createAccTxt() {
    return Padding(
        padding: const EdgeInsets.only(
          top: 30.0,
        ),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            widget.title == SEND_OTP_TITLE
                ? CREATE_ACC_LBL
                : FORGOT_PASSWORDTITILE,
            style: Theme.of(context)
                .textTheme
                .subtitle1!
                .copyWith(color: fontColor, fontWeight: FontWeight.bold),
          ),
        ));
  }

  verifyCodeTxt() {
    return Padding(
        padding:
            const EdgeInsets.only(top: 40.0, left: 40.0, right: 40.0, bottom: 20.0),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            SEND_VERIFY_CODE_LBL,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  color: fontColor,
                  fontWeight: FontWeight.normal,
                ),
          ),
        ));
  }

  setCodeWithMono() {
    return SizedBox(
        width: deviceWidth! * 0.75,
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7.0),
              color: lightWhite,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: setCountryCode(),
                ),
                Expanded(
                  flex: 4,
                  child: setMono(),
                )
              ],
            )));
  }

  setCountryCode() {
    double width = deviceWidth!;
    double height = deviceHeight * 0.9;
    return CountryCodePicker(

        showCountryOnly: false,
        searchDecoration: const InputDecoration(
          hintText: COUNTRY_CODE_LBL,
          fillColor: fontColor,
        ),
        showOnlyCountryWhenClosed: false,
        initialSelection: 'IN',
        dialogSize: Size(width, height),
        alignLeft: true,
        textStyle: const TextStyle(color: fontColor, fontWeight: FontWeight.bold),
        onChanged: (CountryCode countryCode) {
          countrycode = countryCode.toString().replaceFirst("+", "");
          countryName = countryCode.name;
        },
        onInit: (code) {
          countrycode = code.toString().replaceFirst("+", "");
        });
  }

  setMono() {
    return TextFormField(
        keyboardType: TextInputType.number,
        controller: mobileController,
        style: Theme.of(context)
            .textTheme
            .subtitle2!
            .copyWith(color: fontColor, fontWeight: FontWeight.normal),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: validateMob,
        onSaved: (String? value) {
          mobile = value;
        },
        decoration: InputDecoration(
          hintText: MOBILEHINT_LBL,
          hintStyle: Theme.of(context)
              .textTheme
              .subtitle2!
              .copyWith(color: fontColor, fontWeight: FontWeight.normal),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: lightWhite),
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: lightWhite),
          ),
        ));
  }

  verifyBtn() {
    return AppBtn(
        title: widget.title == SEND_OTP_TITLE ? SEND_OTP : GET_PASSWORD,
        btnAnim: buttonSqueezeanimation,
        btnCntrl: buttonController,
        onBtnSelected: () async {
          validateAndSubmit();
        });
  }

  termAndPolicyTxt() {
    return widget.title == SEND_OTP_TITLE
        ? Padding(
            padding: const EdgeInsets.only(
                bottom: 30.0, left: 25.0, right: 25.0, top: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(CONTINUE_AGREE_LBL,
                    style: Theme.of(context).textTheme.caption!.copyWith(
                        color: fontColor, fontWeight: FontWeight.normal)),
                const SizedBox(
                  height: 3.0,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => const PrivacyPolicy(
                                      title: TERM,
                                    )));
                      },
                      child: Text(
                        TERMS_SERVICE_LBL,
                        style: Theme.of(context).textTheme.caption!.copyWith(
                            color: fontColor,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.normal),
                      )),
                  const SizedBox(
                    width: 5.0,
                  ),
                  Text(AND_LBL,
                      style: Theme.of(context).textTheme.caption!.copyWith(
                          color: fontColor, fontWeight: FontWeight.normal)),
                  const SizedBox(
                    width: 5.0,
                  ),
                  InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => const PrivacyPolicy(
                                      title: PRIVACY,
                                    )));
                      },
                      child: Text(
                        PRIVACY_POLICY_LBL,
                        style: Theme.of(context).textTheme.caption!.copyWith(
                            color: fontColor,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.normal),
                      )),
                ]),
              ],
            ),
          )
        : Container();
  }

  backBtn() {
    return Platform.isIOS
        ? Container(
            padding: const EdgeInsets.only(top: 20.0, left: 10.0),
            alignment: Alignment.topLeft,
            child: Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: InkWell(
                  child: const Icon(Icons.keyboard_arrow_left, color: primary),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ))
        : Container();
  }

  @override
  void initState() {
    super.initState();
    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: buttonController!,
      curve: const Interval(
        0.0,
        0.150,
      ),
    ));
  }

  expandedBottomView() {
    return Expanded(
      flex: widget.title == SEND_OTP_TITLE ? 6 : 5,
      child: Container(
        alignment: Alignment.bottomCenter,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formkey,
            child: Card(
              elevation: 0.5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  createAccTxt(),
                  verifyCodeTxt(),
                  setCodeWithMono(),
                  verifyBtn(),
                  termAndPolicyTxt(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        key: _scaffoldKey,
        body: _isNetworkAvail
            ? Container(
                color: lightWhite,
                padding: const EdgeInsets.only(
                  bottom: 20.0,
                ),
                child: Column(
                  children: <Widget>[
                    backBtn(),
                    subLogo(),
                    expandedBottomView(),
                  ],
                ))
            : noInternet(context));
  }
}
