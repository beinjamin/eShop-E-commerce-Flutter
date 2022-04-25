import 'dart:async';
import 'dart:convert';

import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Helper/Constant.dart';
import 'package:eshop/Helper/PushNotificationService.dart';
import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Helper/SqliteData.dart';
import 'package:eshop/Helper/String.dart';
import 'package:eshop/Model/Section_Model.dart';
import 'package:eshop/Provider/HomeProvider.dart';
import 'package:eshop/Provider/UserProvider.dart';
import 'package:eshop/Screen/Cart.dart';
import 'package:eshop/Screen/Favorite.dart';
import 'package:eshop/Screen/Login.dart';
import 'package:eshop/Screen/MyProfile.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:bottom_bar/bottom_bar.dart';

import '../Model/User.dart';
import 'All_Category.dart';

//import 'Cart.dart';
import 'HomePage.dart';
import 'NotificationLIst.dart';
import 'Product_Detail.dart';
import 'Sale.dart';
import 'Search.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  int _selBottom = 0;

  PageController _pageController = PageController();
  bool _isNetworkAvail = true;
  var db = new DatabaseHelper();
  late AnimationController navigationContainerAnimationController =
      AnimationController(
    vsync: this, // the SingleTickerProviderStateMixin
    duration: Duration(milliseconds: 500),
  );
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  @override
  void initState() {
    super.initState();
    initDynamicLinks();
    db.getTotalCartCount(context);
    final pushNotificationService = PushNotificationService(
        context: context, pageController: _pageController);
    pushNotificationService.initialise();

    Future.delayed(Duration.zero, () {
      context
          .read<HomeProvider>()
          .setAnimationController(navigationContainerAnimationController);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selBottom != 0) {
          _pageController.animateToPage(0,
              duration: Duration(milliseconds: 1000), curve: Curves.easeInOut);
          return false;
        }
        return true;
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor: Theme.of(context).colorScheme.lightWhite,
        appBar: _getAppBar(),
        body: PageView(
          controller: _pageController,
          children: [
            HomePage(),
            AllCategory(),
            Sale(),
            Cart(
              fromBottom: true,
            ),
            MyProfile()
          ],
          onPageChanged: (index) {
            setState(() {
              if (!context
                  .read<HomeProvider>()
                  .animationController
                  .isAnimating) {
                context.read<HomeProvider>().animationController.reverse();
                context.read<HomeProvider>().showBars(true);
              }
              _selBottom = index;
              if(index==3)
                {
                  cartTotalClear();
                }
            });
          },
        ),
        bottomNavigationBar: _getBottomBar(),
      ),
    );
  }

  void initDynamicLinks() async {
    dynamicLinks.onLink.listen((dynamicLinkData) {
      final Uri? deepLink = dynamicLinkData.link;

      if (deepLink != null) {
        if (deepLink.queryParameters.length > 0) {
          int index = int.parse(deepLink.queryParameters['index']!);

          int secPos = int.parse(deepLink.queryParameters['secPos']!);

          String? id = deepLink.queryParameters['id'];

          String? list = deepLink.queryParameters['list'];

          getProduct(id!, index, secPos, list == "true" ? true : false);
        }
      }
    }).onError((e) {
      print(e.message);
    });

    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;
    if (deepLink != null) {
      if (deepLink.queryParameters.length > 0) {
        int index = int.parse(deepLink.queryParameters['index']!);

        int secPos = int.parse(deepLink.queryParameters['secPos']!);

        String? id = deepLink.queryParameters['id'];

        // String list = deepLink.queryParameters['list'];

        getProduct(id!, index, secPos, true);
      }
    }
  }

  Future<void> getProduct(String id, int index, int secPos, bool list) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          ID: id,
        };

        // if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID;
        Response response =
            await post(getProductApi, headers: headers, body: parameter)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];

          List<Product> items = [];

          items =
              (data as List).map((data) => new Product.fromJson(data)).toList();

          Navigator.of(context).push(CupertinoPageRoute(
              builder: (context) => ProductDetail(
                    index: list ? int.parse(id) : index,
                    model: list
                        ? items[0]
                        : sectionList[secPos].productList![index],
                    secPos: secPos,
                    list: list,
                  )));
        } else {
          if (msg != "Products Not Found !") setSnackbar(msg, context);
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      {
        if (mounted)
          setState(() {
            setSnackbar(getTranslated(context, 'NO_INTERNET_DISC')!, context);
          });
      }
    }
  }

  AppBar _getAppBar() {
    String? title;
    if (_selBottom == 1)
      title = getTranslated(context, 'CATEGORY');
    else if (_selBottom == 2)
      title = getTranslated(context, 'OFFER');
    else if (_selBottom == 3)
      title = getTranslated(context, 'MYBAG');
    else if (_selBottom == 4) title = getTranslated(context, 'PROFILE');

    return AppBar(
      elevation: 0,
      centerTitle: false,
      //centerTitle: _selBottom == 0 ? true : false,
      title: _selBottom == 0
          ? SvgPicture.asset(
              'assets/images/titleicon.svg',
              height: 35,
        color: colors.primary,
            )
          : Text(
              title!,
              style: TextStyle(
                  color: colors.primary, fontWeight: FontWeight.normal),
            ),


      actions: <Widget>[


        IconButton(
          icon: SvgPicture.asset(
            imagePath + "desel_notification.svg",
            color: colors.primary,
          ),
          onPressed: () {
            CUR_USERID != null
                ? Navigator.push<bool>(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => NotificationList(),
                    )).then((value) {
                    if (value != null && value) {
                      _pageController.jumpToPage(1);
                    }
                  })
                : Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => Login(),
                    ));
          },
        ),
        IconButton(
          padding: EdgeInsets.all(0),
          icon: SvgPicture.asset(
            imagePath + "desel_fav.svg",
            color: colors.primary,
          ),
          onPressed: () {

            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => Favorite(),
                ));

          },
        ),
      ],
      backgroundColor: Theme.of(context).colorScheme.lightWhite,
    );
  }

  Widget _getBottomBar() {
    return
        FadeTransition(
            opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
                CurvedAnimation(
                    parent: navigationContainerAnimationController,
                    curve: Curves.easeInOut)),
            child: SlideTransition(
              position: Tween<Offset>(begin: Offset.zero, end: Offset(0.0, 1.0))
                  .animate(CurvedAnimation(
                      parent: navigationContainerAnimationController,
                      curve: Curves.easeInOut)),
              child: Container(
                height: kBottomNavigationBarHeight,
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                child: BottomBar(
                  duration: Duration(milliseconds: 1000),
                  curve: Curves.easeInOut,
                  selectedIndex: _selBottom,
                  onTap: (int index) {

                    _pageController.jumpToPage(index);
                    setState(() => _selBottom = index);

                  },
                  items: <BottomBarItem>[
                    BottomBarItem(
                      icon: _selBottom == 0
                          ? SvgPicture.asset(
                              imagePath + "sel_home.svg",
                              color: colors.primary,
                            )
                          : SvgPicture.asset(
                              imagePath + "desel_home.svg",
                              color: colors.primary,
                            ),
                      title: Text(getTranslated(context, 'HOME_LBL')!),
                      activeColor: colors.primary,
                    ),
                    BottomBarItem(
                        icon: _selBottom == 1
                            ? SvgPicture.asset(
                                imagePath + "category01.svg",
                                color: colors.primary,
                              )
                            : SvgPicture.asset(
                                imagePath + "category.svg",
                                color: colors.primary,
                              ),
                        title: Text(getTranslated(context, 'category')!),
                        activeColor: colors.primary),
                    BottomBarItem(
                      icon: _selBottom == 2
                          ? SvgPicture.asset(
                              imagePath + "sale02.svg",
                              color: colors.primary,
                            )
                          : SvgPicture.asset(
                              imagePath + "sale.svg",
                              color: colors.primary,
                            ),
                      title: Text(getTranslated(context, 'SALE')!),
                      activeColor: colors.primary,
                    ),
                    BottomBarItem(
                      icon: Selector<UserProvider, String>(
                        builder: (context, data, child) {
                          return Stack(
                            children: [
                              _selBottom == 3
                                  ? SvgPicture.asset(
                                      imagePath + "cart01.svg",
                                      color: colors.primary,
                                    )
                                  : SvgPicture.asset(
                                      imagePath + "cart.svg",
                                      color: colors.primary,
                                    ),
                              (data != null && data.isNotEmpty && data != "0")
                                  ? new Positioned.directional(
                                      end: 0,
                                      textDirection: Directionality.of(context),
                                      top: 0,
                                      child: Container(
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: colors.primary),
                                          child: new Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(3),
                                              child: new Text(
                                                data,
                                                style: TextStyle(
                                                    fontSize: 7,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .white),
                                              ),
                                            ),
                                          )),
                                    )
                                  : Container()
                            ],
                          );
                        },
                        selector: (_, homeProvider) =>
                            homeProvider.curCartCount,
                      ),
                      title: Text(getTranslated(context, 'CART')!),
                      activeColor: colors.primary,
                    ),
                    BottomBarItem(
                      icon: _selBottom == 4
                          ? SvgPicture.asset(
                              imagePath + "profile01.svg",
                              color: colors.primary,
                            )
                          : SvgPicture.asset(
                              imagePath + "profile.svg",
                              color: colors.primary,
                            ),
                      title: Text('Profile'),
                      activeColor: colors.primary,
                    ),
                  ],
                ),
              ),
            ));

  }

  @override
  void dispose() {
    super.dispose();
  }
}
