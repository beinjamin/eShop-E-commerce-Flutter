import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/String.dart';
import 'package:eshop/Provider/CartProvider.dart';
import 'package:eshop/Provider/SettingProvider.dart';
import 'package:eshop/Provider/UserProvider.dart';
import 'package:eshop/Screen/Cart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

//import 'Cart.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';
import '../Model/Section_Model.dart';
import 'Order_Success.dart';

class PaypalWebview extends StatefulWidget {
  final String? url, from, msg, amt, orderId;

  const PaypalWebview(
      {Key? key, this.url, this.from, this.msg, this.amt, this.orderId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StatePayPalWebview();
  }
}

class StatePayPalWebview extends State<PaypalWebview> {
  String message = "";
  bool isloading = true;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  DateTime? currentBackPressTime;
  late UserProvider userProvider;
  @override
  Widget build(BuildContext context) {

    userProvider=Provider.of<UserProvider>(context);

    return Scaffold(
      key: scaffoldKey,
        appBar:  AppBar(
          backgroundColor: Colors.transparent,
          titleSpacing: 0,
          leading: Builder(builder: (BuildContext context) {
            return Container(
              margin: const EdgeInsets.all(10),

              child: Card(
                elevation: 0,
                child: InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () {
                    DateTime now = DateTime.now();
                    if (currentBackPressTime == null ||
                        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
                      currentBackPressTime = now;
                      setSnackbar("Don't press back while doing payment!\n "+getTranslated(context, 'EXIT_WR')!);

                      //return Future.value(false);
                    }
                    if (widget.from == "order" &&
                        widget.orderId != null) deleteOrdesr();
                    Navigator.pop(context);
                  },
                  child: const Center(
                    child: Icon(
                      Icons.keyboard_arrow_left,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
            );
          }),
          title: Text(
            appName,
            style: TextStyle(
              color: Theme.of(context).colorScheme.fontColor,
            ),
          ),
        ),
        body: WillPopScope(
            onWillPop: onWillPop,
            child:
                Stack(
                  children: <Widget>[
                    WebView(
                      initialUrl: widget.url,
                      javascriptMode: JavascriptMode.unrestricted,
                      onWebViewCreated: (WebViewController webViewController) {
                        _controller.complete(webViewController);
                      },
                      javascriptChannels: <JavascriptChannel>[
                        _toasterJavascriptChannel(context),
                      ].toSet(),
                      navigationDelegate: (NavigationRequest request) async {

                        if (request.url.startsWith(PAYPAL_RESPONSE_URL) ||
                            request.url.startsWith(FLUTTERWAVE_RES_URL)) {
                          if (mounted) {
                            setState(() {
                              isloading = true;
                            });
                          }

                          String responseurl = request.url;

                          if (responseurl.contains("Failed") ||
                              responseurl.contains("failed")) {
                            if (mounted) {
                              setState(() {
                                isloading = false;
                                message = "Transaction Failed";
                              });
                            }
                            Timer(const Duration(seconds: 1), () {
                              Navigator.pop(context);
                            });
                          } else if (responseurl.contains("Completed") ||
                              responseurl.contains("completed") ||
                              responseurl.toLowerCase().contains("success")) {
                            if (mounted) {
                              setState(() {
                                if (mounted) {
                                  setState(() {
                                    message = "Transaction Successfull";
                                  });
                                }
                              });
                            }
                            List<String> testdata = responseurl.split("&");
                            for (String data in testdata) {
                              if (data.split("=")[0].toLowerCase() == "tx" ||
                                  data.split("=")[0].toLowerCase() ==
                                      "transaction_id") {
                                // String txid = data.split("=")[1];



                                userProvider.setCartCount("0");

                               // CUR_CART_COUNT = "0";

                                if (widget.from == "order") {
                                  if (request.url.startsWith(PAYPAL_RESPONSE_URL)) {
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        CupertinoPageRoute(
                                            builder: (BuildContext context) =>
                                                const OrderSuccess()),
                                        ModalRoute.withName('/home'));
                                  } else {
                                    String txid = data.split("=")[1];

                                    placeOrder(txid);
                                  }
                                } else if (widget.from == "wallet") {
                                  if (request.url.startsWith(FLUTTERWAVE_RES_URL)) {
                                    String txid = data.split("=")[1];
                                    sendRequest(txid, "flutterwave");
                                  } else {
                                    Navigator.of(context).pop();
                                  }
                                }

                                break;
                              }
                            }
                          }

                          if (request.url.startsWith(PAYPAL_RESPONSE_URL) &&
                              widget.orderId != null &&
                              (responseurl.contains('Canceled-Reversal') ||
                                  responseurl.contains('Denied') ||
                                  responseurl.contains('Failed'))) deleteOrdesr();
                          return NavigationDecision.prevent;
                        }


                        return NavigationDecision.navigate;
                      },
                      onPageFinished: (String url) {
                        setState(() {
                          isloading = false;
                        });

                      },
                    ),
                    isloading
                        ? const Center(
                            child: CircularProgressIndicator(color: colors.primary,),
                          )
                        : const SizedBox(width: 0,height: 0,),
                    message.trim().isEmpty
                        ? Container()
                        : Center(
                            child: Container(
                                color: colors.primary,
                                padding: const EdgeInsets.all(5),
                                margin: const EdgeInsets.all(5),
                                child: Text(
                                  message,
                                  style: TextStyle(color: Theme.of(context).colorScheme.white),
                                )))
                  ],

            )));
  }



  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      setSnackbar("Don't press back while doing payment!\n "+getTranslated(context, 'EXIT_WR')!);

      return Future.value(false);
    }
    if (widget.from == "order" &&
        widget.orderId != null) deleteOrdesr();
    return Future.value(true);
  }

  Future<void> sendRequest(String txnId, String payMethod) async {
    String orderId =
        "wallet-refill-user-$CUR_USERID-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(900) + 100}";
    try {
      var parameter = {
        USER_ID: CUR_USERID,
        AMOUNT: widget.amt,
        TRANS_TYPE: WALLET,
        TYPE: CREDIT,
        MSG: (widget.msg == '' || widget.msg!.isEmpty)
            ? "Added through wallet"
            : widget.msg,
        TXNID: txnId,
        ORDER_ID: orderId,
        STATUS: "Success",
        PAYMENT_METHOD: payMethod.toLowerCase()
      };

      Response response =
          await post(addTransactionApi, body: parameter, headers: headers)
              .timeout(const Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      bool error = getdata["error"];
     // String msg = getdata["message"];

      if (!error) {
       // CUR_BALANCE = double.parse(getdata["new_balance"]).toStringAsFixed(2);

        UserProvider userProvider=Provider.of<UserProvider>(context);
        userProvider.setBalance(double.parse(getdata["new_balance"]).toStringAsFixed(2));


      }
      if (mounted) {
        setState(() {
          isloading = false;
        });
      }
      //setSnackbar(msg);
      Navigator.of(context).pop();
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!);

      setState(() {
        isloading = false;
      });
    }
  }

  Future<void> deleteOrdesr() async {
    try {
      var parameter = {
        ORDER_ID: widget.orderId,
      };

      Response response =
          await post(deleteOrderApi, body: parameter, headers: headers)
              .timeout(const Duration(seconds: timeOut));

    //  var getdata = json.decode(response.body);
    // bool error = getdata["error"];
      //  String msg = getdata["message"];

      if (mounted) {
        setState(() {
          isloading = false;
        });
      }

      Navigator.of(context).pop();
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!);

      setState(() {
        isloading = false;
      });
    }
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }

  setSnackbar(String msg) {
   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.black),
      ),
      backgroundColor: Theme.of(context).colorScheme.white,
      elevation: 1.0,
    ));
  }



  Future<void> placeOrder(String tranId) async {
    setState(() {
      isloading = true;
    });
    SettingProvider settingsProvider =
    Provider.of<SettingProvider>(context, listen: false);

    String? mob = await settingsProvider.getPrefrence(MOBILE);
    String? varientId, quantity;
    List<SectionModel>cartList=context.read<CartProvider>().cartList;

    for (SectionModel sec in cartList) {
      varientId =
          varientId != null ? varientId + "," + sec.varientId! : sec.varientId;
      quantity = quantity != null ? quantity + "," + sec.qty! : sec.qty;
    }
    String payVia;

    payVia = "Flutterwave";

    try {
      var parameter = {
        USER_ID: CUR_USERID,
        MOBILE: mob,
        PRODUCT_VARIENT_ID: varientId,
        QUANTITY: quantity,
        TOTAL: oriPrice.toString(),
        DEL_CHARGE: delCharge.toString(),

        TAX_PER: taxPer.toString(),
        FINAL_TOTAL: totalPrice.toString(),
        PAYMENT_METHOD: payVia,
        ADD_ID: selAddress,
        ISWALLETBALUSED: isUseWallet! ? "1" : "0",
        WALLET_BAL_USED: usedBal.toString(),
      };

      if (isTimeSlot!) {
        parameter[DELIVERY_TIME] = selTime ?? 'Anytime';
        parameter[DELIVERY_DATE] = selDate ?? '';
      }
      if (isPromoValid!) {
        parameter[PROMOCODE] = promocode;
        parameter[PROMO_DIS] = promoAmt.toString();
      }

      Response response =
          await post(placeOrderApi, body: parameter, headers: headers)
              .timeout(const Duration(seconds: timeOut));

      if (response.statusCode == 200) {
        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          String orderId = getdata["order_id"].toString();

          AddTransaction(tranId, orderId, SUCCESS, msg, true);
        } else {
          setSnackbar(msg!);
        }
        if (mounted) {
          setState(() {
            isloading = false;
          });
        }
      }
    } on TimeoutException catch (_) {
      if (mounted) {
        setState(() {
          isloading = false;
        });
      }
    }
  }

  Future<void> AddTransaction(String tranId, String orderID, String status,
      String? msg, bool redirect) async {
    try {
      var parameter = {
        USER_ID: CUR_USERID,
        ORDER_ID: orderID,
        TYPE: payMethod,
        TXNID: tranId,
        AMOUNT: totalPrice.toString(),
        STATUS: status,
        MSG: msg
      };

      Response response =
          await post(addTransactionApi, body: parameter, headers: headers)
              .timeout(const Duration(seconds: timeOut));

      DateTime now = DateTime.now();
      currentBackPressTime = now;
      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      String? msg1 = getdata["message"];
      if (!error) {
        if (redirect) {
          userProvider.setCartCount("0");
          //CUR_CART_COUNT = "0";
          promoAmt = 0;
          remWalBal = 0;
          usedBal = 0;
          payMethod = '';
          isPromoValid = false;
          isUseWallet = false;
          isPayLayShow = true;
          selectedMethod = null;
          totalPrice = 0;
          oriPrice = 0;

          taxPer = 0;
          delCharge = 0;

          Navigator.pushAndRemoveUntil(
              context,
              CupertinoPageRoute(
                  builder: (BuildContext context) => const OrderSuccess()),
              ModalRoute.withName('/home'));
        }
      } else {
        setSnackbar(msg1!);
      }
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!);
    }
  }
}
