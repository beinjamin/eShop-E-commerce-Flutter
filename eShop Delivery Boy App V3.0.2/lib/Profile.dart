import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => StateProfile();
}

String? lat, long;

class StateProfile extends State<Profile> with TickerProviderStateMixin {
  String name = "",
      email = "",
      mobile = "",
      address = "",
      image = "",
      curPass = "",
      newPass = "",
      confPass = "",
      loaction = "";

  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController? nameC,
      emailC,
      mobileC,
      addressC,
      curPassC,
      newPassC,
      confPassC;
  bool isSelected = false, isArea = true;
  bool _isNetworkAvail = true;
  bool _showCurPassword = false, _showPassword = false, _showCmPassword = false;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;

  @override
  void initState() {
    super.initState();

    mobileC = TextEditingController();
    nameC = TextEditingController();
    emailC = TextEditingController();

    addressC = TextEditingController();
    getUserDetails();

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

  @override
  void dispose() {
    buttonController!.dispose();
    mobileC?.dispose();
    nameC?.dispose();
    addressC!.dispose();
    super.dispose();
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  getUserDetails() async {
    CUR_USERID = await getPrefrence(ID)?? "";
    mobile = await getPrefrence(MOBILE)?? "";
    name = await getPrefrence(USERNAME)?? "";
    email = await getPrefrence(EMAIL)?? "";

    address = await getPrefrence(ADDRESS) ?? "";
    image = await getPrefrence(IMAGE)?? "";
    mobileC!.text = mobile;
    nameC!.text = name;
    emailC!.text = email;

    addressC!.text = address;

    setState(() {});
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
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

  void validateAndSubmit() async {
    if (validateAndSave()) {
      checkNetwork();
    }
  }

  Future<void> checkNetwork() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      setUpdateUser();
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }
  }

  bool validateAndSave() {
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> setProfilePic(File _image) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      setState(() {
        _isLoading = true;
      });
      try {
        var request = http.MultipartRequest("POST", getUpdateUserApi);
        request.headers.addAll(headers);
        request.fields[USER_ID] = CUR_USERID!;
        var pic = await http.MultipartFile.fromPath(IMAGE, _image.path);
        request.files.add(pic);

        var response = await request.send();
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);

        var getdata = json.decode(responseString);
        bool error = getdata["error"];
        String? msg = getdata['message'];
        if (!error) {
          List data = getdata["data"];
          for (var i in data) {
            image = i[IMAGE];
          }
          setPrefrence(IMAGE, image);
        } else {
          setSnackbar(msg!);
        }
        setState(() {
          _isLoading = false;
        });
      } on TimeoutException catch (_) {
        setSnackbar(somethingMSg);
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }
  }

  Future<void> setUpdateUser() async {
    var data = {USER_ID: CUR_USERID, USERNAME: name, EMAIL: email};
    if (newPass != "" && newPass != "") {
      data[NEWPASS] = newPass;
    }
    if (curPass != "" && curPass != "") {
      data[OLDPASS] = curPass;
    }

    if (address != "" && address != "") {
      data[ADDRESS] = address;
    }

    http.Response response = await http
        .post(getUpdateUserApi, body: data, headers: headers)
        .timeout(const Duration(seconds: timeOut));

    if (response.statusCode == 200) {
      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      String? msg = getdata["message"];
      await buttonController!.reverse();
      if (!error) {
        CUR_USERNAME = name;
        saveUserDetail(CUR_USERID!, name, email, mobile);
      } else {
        setSnackbar(msg!);
      }
    }
  }



  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar( SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: const TextStyle(color: primary),
      ),
      backgroundColor: white,
      elevation: 1.0,
    ));
  }

  setUser() {
    return Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: <Widget>[
            Image.asset('assets/images/username.png', fit: BoxFit.fill,color: primary,),
            Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      NAME_LBL,
                      style: Theme.of(context).textTheme.caption!.copyWith(
                          color: lightfontColor2, fontWeight: FontWeight.normal),
                    ),
                    name != ""
                        ? Text(
                            name,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2!
                                .copyWith(
                                    color: lightfontColor,
                                    fontWeight: FontWeight.bold),
                          )
                        : Container()
                  ],
                )),
            const Spacer(),
            IconButton(
              icon: const Icon(
                Icons.edit,
                size: 20,
                color: lightfontColor,
              ),
              onPressed: () {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        contentPadding: const EdgeInsets.all(0),
                        elevation: 2.0,
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0))),
                        content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
                                  child: Text(
                                    ADD_NAME_LBL,
                                    style: Theme.of(this.context)
                                        .textTheme
                                        .subtitle1!
                                        .copyWith(color: fontColor),
                                  )),
                              const Divider(color: lightfontColor),
                              Form(
                                  key: _formKey,
                                  child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                                      child: TextFormField(
                                        keyboardType: TextInputType.text,
                                        style: Theme.of(this.context)
                                            .textTheme
                                            .subtitle1!
                                            .copyWith(
                                                color: lightfontColor,
                                                fontWeight: FontWeight.normal),
                                        validator: validateUserName,
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        controller: nameC,
                                        onChanged: (v) => setState(() {
                                          name = v;
                                        }),
                                      )))
                            ]),
                        actions: <Widget>[
                          TextButton(
                              child: const Text(CANCEL,
                                  style: TextStyle(
                                      color: lightfontColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                              onPressed: () {
                                setState(() {
                                  Navigator.pop(context);
                                });
                              }),
                          TextButton(
                              child: const Text(SAVE_LBL,
                                  style: TextStyle(
                                      color: fontColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                              onPressed: () {
                                final form = _formKey.currentState!;
                                if (form.validate()) {
                                  form.save();
                                  setState(() {
                                    name = nameC!.text;
                                    Navigator.pop(context);
                                  });
                                  checkNetwork();
                                }
                              })
                        ],
                      );
                    });
              },
            )
          ],
        ));
  }


  setMobileNo() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
        child: Row(
          children: <Widget>[
            Image.asset('assets/images/mobilenumber.png', fit: BoxFit.fill,color: primary,),
            Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      MOBILEHINT_LBL,
                      style: Theme.of(context).textTheme.caption!.copyWith(
                          color: lightfontColor2, fontWeight: FontWeight.normal),
                    ),
                    mobile != "" && mobile != ""
                        ? Text(
                            mobile,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2!
                                .copyWith(
                                    color: lightfontColor,
                                    fontWeight: FontWeight.bold),
                          )
                        : Container()
                  ],
                )),
          ],
        ));
  }

  changePass() {
    return SizedBox(
        height: 60,
        width: deviceWidth,
        child: Card(
            elevation: 0,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            child: InkWell(
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 15.0, bottom: 15.0),
                child: Text(
                  CHANGE_PASS_LBL,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2!
                      .copyWith(color: fontColor, fontWeight: FontWeight.bold),
                ),
              ),
              onTap: () {
                _showDialog();
              },
            )));
  }

  _showDialog() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStater) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(0.0),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0))),
              content: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
                            child: Text(
                              CHANGE_PASS_LBL,
                              style: Theme.of(this.context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(color: fontColor),
                            )),
                        const Divider(color: lightfontColor),
                        Form(
                            key: _formKey,
                            child: Column(
                              children: <Widget>[
                                Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                                    child: TextFormField(
                                      keyboardType: TextInputType.text,
                                      validator: validatePass,
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      decoration: InputDecoration(
                                          hintText: CUR_PASS_LBL,
                                          hintStyle: Theme.of(this.context)
                                              .textTheme
                                              .subtitle1!
                                              .copyWith(
                                                  color: lightfontColor,
                                                  fontWeight:
                                                      FontWeight.normal),
                                          suffixIcon: IconButton(
                                            icon: Icon(_showCurPassword
                                                ? Icons.visibility
                                                : Icons.visibility_off),
                                            iconSize: 20,
                                            color: lightfontColor,
                                            onPressed: () {
                                              setStater(() {
                                                _showCurPassword =
                                                    !_showCurPassword;
                                              });
                                            },
                                          )),
                                      obscureText: !_showCurPassword,
                                      controller: curPassC,
                                      onChanged: (v) => setState(() {
                                        curPass = v;
                                      }),
                                    )),
                                Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                                    child: TextFormField(
                                      keyboardType: TextInputType.text,
                                      validator: validatePass,
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      decoration: InputDecoration(
                                          hintText: NEW_PASS_LBL,
                                          hintStyle: Theme.of(this.context)
                                              .textTheme
                                              .subtitle1!
                                              .copyWith(
                                                  color: lightfontColor,
                                                  fontWeight:
                                                      FontWeight.normal),
                                          suffixIcon: IconButton(
                                            icon: Icon(_showPassword
                                                ? Icons.visibility
                                                : Icons.visibility_off),
                                            iconSize: 20,
                                            color: lightfontColor,
                                            onPressed: () {
                                              setStater(() {
                                                _showPassword = !_showPassword;
                                              });
                                            },
                                          )),
                                      obscureText: !_showPassword,
                                      controller: newPassC,
                                      onChanged: (v) => setState(() {
                                        newPass = v;
                                      }),
                                    )),
                                Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                                    child: TextFormField(
                                      keyboardType: TextInputType.text,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return CON_PASS_REQUIRED_MSG;
                                        }
                                        if (value != newPass) {
                                          return CON_PASS_NOT_MATCH_MSG;
                                        } else {
                                          return null;
                                        }
                                      },
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      decoration: InputDecoration(
                                          hintText: CONFIRMPASSHINT_LBL,
                                          hintStyle: Theme.of(this.context)
                                              .textTheme
                                              .subtitle1!
                                              .copyWith(
                                                  color: lightfontColor,
                                                  fontWeight:
                                                      FontWeight.normal),
                                          suffixIcon: IconButton(
                                            icon: Icon(_showCmPassword
                                                ? Icons.visibility
                                                : Icons.visibility_off),
                                            iconSize: 20,
                                            color: lightfontColor,
                                            onPressed: () {
                                              setStater(() {
                                                _showCmPassword =
                                                    !_showCmPassword;
                                              });
                                            },
                                          )),
                                      obscureText: !_showCmPassword,
                                      controller: confPassC,
                                      onChanged: (v) => setState(() {
                                        confPass = v;
                                      }),
                                    )),
                              ],
                            ))
                      ])),
              actions: <Widget>[
                TextButton(
                    child: Text(
                      CANCEL,
                      style: Theme.of(this.context)
                          .textTheme
                          .subtitle2!
                          .copyWith(
                              color: lightfontColor, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                TextButton(
                    child: Text(
                      SAVE_LBL,
                      style: Theme.of(this.context)
                          .textTheme
                          .subtitle2!
                          .copyWith(
                              color: fontColor, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      final form = _formKey.currentState!;
                      if (form.validate()) {
                        form.save();
                        setState(() {
                          Navigator.pop(context);
                        });
                        checkNetwork();
                      }
                    })
              ],
            );
          });
        });
  }

  profileImage() {
    return Container(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 30.0),
      child: CircleAvatar(
        radius: 50,
        backgroundColor: primary,
        child: Container(
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: primary)),
            child: const Icon(Icons.account_circle, size: 100)),
      ),
    );
  }

  _getDivider() {
    return const Divider(
      height: 1,
      color: lightfontColor,
    );
  }

  _showContent1() {
    return SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: _isNetworkAvail
                ? Column(children: <Widget>[
                    profileImage(),
                    Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 5.0),
                        child: Card(
                            elevation: 0,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(10.0))),
                            child: Column(
                              children: <Widget>[
                                setUser(),
                                _getDivider(),
                                //setEmail(),
                                //_getDivider(),
                                setMobileNo(),
                              ],
                            ))),
                    changePass()
                  ])
                : noInternet(context)));
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: lightWhite,
      appBar: getAppBar(EDIT_PROFILE_LBL, context),
      body: Stack(
        children: <Widget>[
          _showContent1(),
          showCircularProgress(_isLoading, primary)
        ],
      ),
    );
  }
}
