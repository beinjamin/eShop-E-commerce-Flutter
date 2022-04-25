import 'dart:async';
import 'dart:convert';


import 'package:eshop/Model/Order_Model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';

import '../Helper/AppBtn.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';
import '../Helper/String.dart';

import 'Login.dart';
import 'OrderDetail.dart';

class MyOrder extends StatefulWidget {
  const MyOrder({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateMyOrder();
  }
}

List<OrderModel> searchList = [];
int offset = 0;
int total = 0;

int pos = 0;

class StateMyOrder extends State<MyOrder> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? searchText;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool _isNetworkAvail = true;
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = true;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  ScrollController scrollController = ScrollController();
  String _searchText = "", _lastsearch = "";
  bool isLoadingmore = true, isGettingdata = false, isNodata = false;
  String? activeStatus;

  List<String> statusList = [
    ALL,
    PLACED,
    PROCESSED,
    SHIPED,
    DELIVERD,
    CANCLED,
    RETURNED,
    awaitingPayment
  ];

  @override
  void initState() {
    scrollController.addListener(_scrollListener);

    searchList.clear();
    offset = 0;
    total = 0;
    getOrder();
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
    _controller.addListener(() {
      if (_controller.text.isEmpty) {
        if (mounted) {
          setState(() {
            _searchText = "";
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _searchText = _controller.text;
          });
        }
      }

      if (_lastsearch != _searchText &&
          ((_searchText.length > 2) || (_searchText == ""))) {
        _lastsearch = _searchText;
        isLoadingmore = true;
        offset = 0;
        getOrder();
      }
    });

    super.initState();
  }

  _scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      if (mounted) {
        setState(() {
          getOrder();
        });
      }
    }
  }

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  // Future<void> searchOperation(String searchText) async {
  //   orderList.addAll(searchList);
  //   searchList.clear();

  //   for (int i = 0; i < orderList.length; i++) {
  //     for (int j = 0; j < orderList[i].itemList.length; j++) {
  //       OrderModel map = orderList[i];

  //       if (map.id.toLowerCase().contains(searchText) ||
  //           map.itemList[j].name.toLowerCase().contains(searchText)) {
  //         searchList.add(map);
  //       }
  //     }
  //   }

  //   if (mounted) setState(() {});
  // }

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
                getOrder();
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
      backgroundColor: Theme.of(context).colorScheme.lightWhite,
      appBar: getAppBar(getTranslated(context, "MY_ORDERS_LBL")!, context),
      body: _isNetworkAvail
          ? _isLoading
              ? shimmer(context)
              : Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          padding:
                              const EdgeInsetsDirectional.only(start: 5.0, end: 5.0),
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              filled: true,
                              isDense: true,
                              fillColor: Theme.of(context).colorScheme.white,
                              prefixIconConstraints: const BoxConstraints(
                                  minWidth: 40, maxHeight: 20),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              prefixIcon: SvgPicture.asset(
                                'assets/images/search.svg',
                                color: colors.primary,
                              ),
                              hintText: getTranslated(
                                  context, 'FIND_ORDER_ITEMS_LBL'),
                              hintStyle: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .fontColor
                                      .withOpacity(0.3),
                                  fontWeight: FontWeight.normal),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                ),
                              ),
                            ),
                          )),
                      Expanded(
                        child: searchList.isEmpty
                            ? Center(
                                child: Text(getTranslated(context, 'noItem')!))
                            : RefreshIndicator(
                                color: colors.primary,
                                key: _refreshIndicatorKey,
                                onRefresh: _refresh,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  controller: scrollController,
                                  padding: const EdgeInsetsDirectional.only(top: 5.0),
                                  itemCount: searchList.length,
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    OrderItem? orderItem;
                                    try {
                                      if (searchList[index].itemList!.isNotEmpty) {
                                        orderItem =
                                            searchList[index].itemList![0];
                                      }
                                      if (isLoadingmore &&
                                          index == (searchList.length - 1) &&
                                          scrollController.position.pixels <=
                                              0) {
                                        getOrder();
                                      }
                                    } on Exception catch (_) {}

                                    return orderItem == null
                                        ? Container()
                                        : productItem(index, orderItem);
                                  },
                                )),
                      ),
                      isGettingdata
                          ? const Padding(
                              padding:
                                  EdgeInsetsDirectional.only(top: 5, bottom: 5),
                              child: CircularProgressIndicator(
                                color: colors.primary,
                              ),
                            )
                          : Container(),
                    ],
                  ),
                )
          //))
          : noInternet(context),
    );
  }

  Future<void> _refresh() {
    if (mounted) {
      setState(() {
        offset = 0;
        total = 0;
        isLoadingmore = true;
        _isLoading = true;
      });
    }

    return getOrder();
  }

  Future<void> getOrder() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (isLoadingmore) {
          if (mounted) {
            setState(() {
              isLoadingmore = false;
              isGettingdata = true;
              if (offset == 0) {
                searchList = [];
              }
            });
          }

          if (CUR_USERID != null) {
            var parameter = {
              USER_ID: CUR_USERID,
              OFFSET: offset.toString(),
              LIMIT: perPage.toString(),
              SEARCH: _searchText.trim(),
            };
            if (activeStatus != null) {
              if (activeStatus == awaitingPayment) activeStatus = "awaiting";
              parameter[ACTIVE_STATUS] = activeStatus;
            }



            Response response =
                await post(getOrderApi, body: parameter, headers: headers)
                    .timeout(const Duration(seconds: timeOut));

            var getdata = json.decode(response.body);
            print("API $getOrderApi \n parameter $parameter \n response ${response.body}");


            bool error = getdata["error"];
            //print("here is this ${getdata["data"]["order_attachments"]}");

            isGettingdata = false;
            if (offset == 0) isNodata = error;

            if (!error) {
              var data = getdata["data"];
              if (data.length != 0) {
                List<OrderModel> items = [];
                List<OrderModel> allitems = [];

                items.addAll((data as List)
                    .map((data) => OrderModel.fromJson(data))
                    .toList());

                allitems.addAll(items);

                for (OrderModel item in items) {
                  searchList.where((i) => i.id == item.id).map((obj) {
                    allitems.remove(item);
                    return obj;
                  }).toList();
                }
                searchList.addAll(allitems);

                isLoadingmore = true;
                offset = offset + perPage;
              } else {
                isLoadingmore = false;
              }
            } else {
              isLoadingmore = false;
            }

            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          } else {
            if (mounted) {
              setState(() {
                isLoadingmore = false;
                //msg = goToLogin;
              });
            }

            Future.delayed(const Duration(seconds: 1)).then((_) {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => const Login()),
              );
            });
          }
        }
      } on TimeoutException catch (_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            isLoadingmore = false;
          });
        }
        setSnackbar(getTranslated(context, 'somethingMSg')!);
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
          _isLoading = false;
        });
      }
    }

    return;
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

  productItem(int index, OrderItem orderItem) {
    if (orderItem != null) {
      String? sDate = orderItem.listDate!.last;
      String? proStatus = orderItem.listStatus!.last;
      if (proStatus == 'received') {
        proStatus = 'order placed';
      }
      String name = orderItem.name ?? "";
      name = name +
          " ${searchList[index].itemList!.length > 1 ? " and more items" : ""} ";

      return Card(
        elevation: 0,
        //margin: EdgeInsets.all(5.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(7),
          child: Column(children: <Widget>[
            Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Hero(
                  tag: "$index${orderItem.id}",
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(7.0),
                        topLeft: Radius.circular(7.0)),
                    child: FadeInImage(
                      fadeInDuration: const Duration(milliseconds: 150),
                      image: NetworkImage(orderItem.image!),
                      height: 100.0,
                      width: 100.0,
                      fit: BoxFit.cover,
                      imageErrorBuilder: (context, error, stackTrace) =>
                          erroWidget(90),

                      // errorWidget:(context, url,e) => placeHolder(90) ,
                      placeholder: placeHolder(90),
                    ),
                  )),
              Expanded(
                  flex: 9,
                  child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                          start: 10.0, end: 5.0, bottom: 8.0, top: 8.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              "$proStatus on $sDate",
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .fontColor),
                            ),
                            Padding(
                                padding:
                                    const EdgeInsetsDirectional.only(top: 10.0),
                                child: Text(
                                  name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .lightBlack2,
                                          fontWeight: FontWeight.normal,fontSize: 12),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )),
                          ]))),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.only(right: 3.0),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: colors.primary,
                  size: 15,
                ),
              )
            ]),
          ]),
          onTap: () async {
            FocusScope.of(context).unfocus();
            final result = await Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => OrderDetail(model: searchList[index])),
            );
            if (mounted && result == "update") {
              setState(() {
                _isLoading = true;
                isLoadingmore = true;
                offset = 0;
                total = 0;
                searchList.clear();
                getOrder();
              });
            }
          },
        ),
      );
    } else {
      return null;
    }
  }

  // getAppbar() {
  //   return AppBar(
  //     titleSpacing: 0,
  //     leading: Builder(builder: (BuildContext context) {
  //       return Container(
  //         margin: EdgeInsets.all(10),
  //         decoration: shadow(),
  //         child: Card(
  //           elevation: 0,
  //           child: InkWell(
  //             borderRadius: BorderRadius.circular(4),
  //             onTap: () => Navigator.of(context).pop(),
  //             child: Center(
  //               child: Icon(
  //                 Icons.keyboard_arrow_left,
  //                 color: colors.primary,
  //               ),
  //             ),
  //           ),
  //         ),
  //       );
  //     }),
  //     title: Text(
  //       getTranslated(context, 'MY_ORDERS_LBL')!,
  //       style: TextStyle(
  //         color: Theme.of(context).colorScheme.fontColor,
  //       ),
  //     ),
  //     actions: [
  //       Container(
  //         margin: EdgeInsets.all(10),
  //         decoration: shadow(),
  //         child: Card(
  //           elevation: 0,
  //           child: InkWell(
  //             borderRadius: BorderRadius.circular(4),
  //             onTap: filterDialog,
  //             child: Padding(
  //               padding: const EdgeInsets.all(4.0),
  //               child: Icon(
  //                 Icons.tune,
  //                 color: colors.primary,
  //                 size: 22,
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  void filterDialog() {
    dialogAnimate(
        context,
        ButtonBarTheme(
          data: const ButtonBarThemeData(
            alignment: MainAxisAlignment.center,
          ),
          child: AlertDialog(
              elevation: 2.0,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0))),
              contentPadding: const EdgeInsets.all(0.0),
              content: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Padding(
                      padding:
                          const EdgeInsetsDirectional.only(top: 19.0, bottom: 16.0),
                      child: Text(
                        getTranslated(context, 'FILTER')!,
                        style: Theme.of(context).textTheme.subtitle1!.copyWith(
                            color: Theme.of(context).colorScheme.fontColor),
                      )),
                  Divider(color: Theme.of(context).colorScheme.lightBlack),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: getStatusList()),
                    ),
                  ),
                ]),
              )),
        ));
  }

  List<Widget> getStatusList() {
    return statusList
        .asMap()
        .map(
          (index, element) => MapEntry(
            index,
            Column(
              children: [
                SizedBox(
                  width: double.maxFinite,
                  child: TextButton(
                      child: Text(capitalize(statusList[index]),
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2!
                              .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .lightBlack)),
                      onPressed: () {
                        setState(() {
                          activeStatus = index == 0 ? null : statusList[index];
                          isLoadingmore = true;
                          offset = 0;
                        });

                        getOrder();

                        Navigator.pop(context, 'option $index');
                      }),
                ),
                Divider(
                  color: Theme.of(context).colorScheme.lightBlack,
                  height: 1,
                ),
              ],
            ),
          ),
        )
        .values
        .toList();
  }
}
