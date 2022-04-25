import 'dart:async';
import 'dart:convert';
import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Model/Faqs_Model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../Helper/AppBtn.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';

class Faqs extends StatefulWidget {
  final String? title;

  const Faqs({Key? key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateFaqs();
  }
}

class StateFaqs extends State<Faqs> with TickerProviderStateMixin {
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey =  GlobalKey<ScaffoldState>();
  String? privacy;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool _isNetworkAvail = true;
  List<FaqsModel> faqsList = [];
  int selectedIndex = -1;
  bool flag = true;
  bool isLoadingmore = true;
  ScrollController controller =  ScrollController();


  @override
  void initState() {
    super.initState();
    controller.addListener(_scrollListener);
    getFaqs();
    buttonController =  AnimationController(
        duration:  const Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation =  Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate( CurvedAnimation(
      parent: buttonController!,
      curve:  const Interval(
        0.0,
        0.150,
      ),
    ));
  }

  @override
  void dispose() {
    buttonController!.dispose();
    controller.removeListener(() {});
    super.dispose();
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (mounted) {
         if (mounted) {
           setState(() {
          isLoadingmore = true;
          getFaqs();
        });
         }
      }
    }
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  Widget noInternet(BuildContext context) {
    return SingleChildScrollView(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        noIntImage(),
        noIntText(context),
        noIntDec(context),
        AppBtn(
          title: getTranslated(context, 'TRY_AGAIN_INT_LBL'),
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
                 if (mounted) setState(() {});
              }
            });
          },
        )
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        key: _scaffoldKey,
        appBar: getSimpleAppBar(widget.title!, context),
        body: _isNetworkAvail ? _showForm(context) : noInternet(context));
  }

  _showForm(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: _isLoading
            ? shimmer(context)
            : ListView.builder(
          controller: controller,
          itemCount: faqsList.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return (index == faqsList.length && isLoadingmore)
                ? const Center(child: CircularProgressIndicator(color: colors.primary,))
                : listItem(index);
          },
        ));
  }

  listItem(int index) {
    return Card(
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () {
             if (mounted) {
               setState(() {
              selectedIndex = index;
              flag = !flag;
            });
             }
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        faqsList[index].question!,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1!
                            .copyWith(color: Theme.of(context).colorScheme.lightBlack),
                      )),
                  selectedIndex != index || flag
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0),
                              child: Text(
                                faqsList[index].answer!,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2!
                                    .copyWith(
                                    color: Theme.of(context).colorScheme.black.withOpacity(0.7)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ))),
                      const Icon(Icons.keyboard_arrow_down)
                    ],
                  )
                      : Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0),
                                child: Text(
                                  faqsList[index].answer!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2!
                                      .copyWith(
                                      color: Theme.of(context).colorScheme.black.withOpacity(0.7)),
                                ))),
                        const Icon(Icons.keyboard_arrow_up)
                      ]),
                ]),
          ),
        ));
  }

  Future<void> getFaqs() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        Response response = await post(getFaqsApi, headers: headers)
            .timeout(const Duration(seconds: timeOut));
        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);

          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];
            faqsList = (data as List)
                .map((data) =>  FaqsModel.fromJson(data))
                .toList();
          } else {
            setSnackbar(msg!);
          }
        }
         if (mounted) {
           setState(() {
          _isLoading = false;
        });
         }
      } on TimeoutException catch (_) {
        setSnackbar( getTranslated(context,'somethingMSg')!);
      }
    } else {
       if (mounted) {
         setState(() {
        _isLoading = false;
        _isNetworkAvail = false;
      });
       }
    }
  }

  setSnackbar(String msg) {
  ScaffoldMessenger.of(context).showSnackBar( SnackBar(
      content:  Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.black),
      ),
      backgroundColor: Theme.of(context).colorScheme.white,
      elevation: 1.0,
    ));
  }
}
