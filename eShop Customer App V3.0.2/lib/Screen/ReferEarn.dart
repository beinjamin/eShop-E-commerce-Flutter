import 'package:eshop/Helper/Session.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:share_plus/share_plus.dart';


import '../Helper/Color.dart';
import '../Helper/SimBtn.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';

class ReferEarn extends StatefulWidget {
  const ReferEarn({Key? key}) : super(key: key);

  @override
  _ReferEarnState createState() => _ReferEarnState();
}

class _ReferEarnState extends State<ReferEarn> {

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: getSimpleAppBar(getTranslated(context, 'REFEREARN')!, context),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/images/refer.svg",
                  color: colors.primary,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 28.0),
                  child: Text(
                    getTranslated(context, 'REFEREARN')!,
                    style: Theme.of(context)
                        .textTheme
                        .headline5!
                        .copyWith(color: Theme.of(context).colorScheme.fontColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    getTranslated(context, 'REFER_TEXT')!,
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 28.0),
                  child: Text(
                    getTranslated(context, 'YOUR_CODE')!,
                    style: Theme.of(context)
                        .textTheme
                        .headline5!
                        .copyWith(color: Theme.of(context).colorScheme.fontColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 1, style: BorderStyle.solid,
                            color: colors.secondary,),
                        borderRadius: BorderRadius.circular(4),

                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          REFER_CODE!,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(color: Theme.of(context).colorScheme.fontColor),
                        ),
                      )),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.lightWhite,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(4.0))),
                      child: Text(getTranslated(context, 'TAP_TO_COPY')!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.button!.copyWith(
                                color: Theme.of(context).colorScheme.fontColor,
                              ))),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: REFER_CODE));
                    setSnackbar('Refercode Copied to clipboard');
                  },
                ),
                SimBtn(
                  width: 0.8,
                  height: 35,
                  title: getTranslated(context, "SHARE_APP"),
                  onBtnSelected: () {

                    var str =
                        "$appName\nRefer Code:$REFER_CODE\n${getTranslated(context, 'APPFIND')}$androidLink$packageName\n\n${getTranslated(context, 'IOSLBL')}\n$iosLink";
                   Share.share(str);

                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
}
