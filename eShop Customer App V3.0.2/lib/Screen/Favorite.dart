import 'dart:async';
import 'dart:convert';


import 'package:eshop/Helper/SqliteData.dart';
import 'package:eshop/Provider/CartProvider.dart';
import 'package:eshop/Provider/FavoriteProvider.dart';
import 'package:eshop/Provider/UserProvider.dart';
import 'package:eshop/Screen/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../Helper/AppBtn.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';
import '../Helper/String.dart';
import '../Model/Section_Model.dart';
import 'Product_Detail.dart';

class Favorite extends StatefulWidget {
  const Favorite({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => StateFav();
}

class StateFav extends State<Favorite> with TickerProviderStateMixin {

  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool _isNetworkAvail = true;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
       GlobalKey<RefreshIndicatorState>();
  bool _isProgress = false, _isFavLoading = true;
  List<String>? proIds;
  var db =  DatabaseHelper();
  final List<TextEditingController> _controller = [];

  @override
  void initState() {
    super.initState();

    callApi();

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

  callApi() async {
    if (CUR_USERID != null) {
      _getFav();
    } else {
      proIds = (await db.getFav())!;
      _getOffFav();
    }
  }

  @override
  void dispose() {
    buttonController!.dispose();
    for (int i = 0; i < _controller.length; i++) {
      _controller[i].dispose();
    }
    super.dispose();
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
                _getFav();
              } else {
                await buttonController!.reverse();
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
        appBar: getAppBar(getTranslated(context, 'FAVORITE')!, context),
        body: _isNetworkAvail
            ? Stack(
                children: <Widget>[
                  _showContent(context),
                  showCircularProgress(_isProgress, colors.primary),
                ],
              )
            : noInternet(context));
  }

  Widget listItem(int index, List<Product> favList) {
    if (index < favList.length && favList.isNotEmpty) {

      return FutureBuilder(
          future: db.checkCartItemExists(favList[index].id!,
              favList[index].prVarientList![favList[index].selVarient!].id!),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              double price = double.parse(favList[index]
                  .prVarientList![favList[index].selVarient!]
                  .disPrice!);
              if (price == 0) {
                price = double.parse(favList[index]
                    .prVarientList![favList[index].selVarient!]
                    .price!);
              }

              double off = 0;
              if (favList[index]
                      .prVarientList![favList[index].selVarient!]
                      .disPrice! !=
                  "0") {
                off = (double.parse(favList[index]
                            .prVarientList![favList[index].selVarient!]
                            .price!) -
                        double.parse(favList[index]
                            .prVarientList![favList[index].selVarient!]
                            .disPrice!))
                    .toDouble();
                off = off *
                    100 /
                    double.parse(favList[index]
                        .prVarientList![favList[index].selVarient!]
                        .price!);
              }

              if (_controller.length < index + 1) {
                _controller.add(TextEditingController());
              }

              if (CUR_USERID == null) {
                favList[index]
                    .prVarientList![favList[index].selVarient!]
                    .cartCount = snapshot.data!;
                _controller[index].text = snapshot.data!.toString();
              } else {
                _controller[index].text = favList[index]
                    .prVarientList![favList[index].selVarient!]
                    .cartCount!;
              }

              return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Card(
                        elevation: 0.1,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Hero(
                                  tag: "$index${favList[index].id}",
                                  child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          bottomLeft: Radius.circular(10)),
                                      child: Stack(
                                        children: [
                                          FadeInImage(
                                            image: NetworkImage(
                                                favList[index].image!),
                                            height: 100.0,
                                            width: 100.0,
                                            fit: extendImg
                                                ? BoxFit.fill
                                                : BoxFit.contain,

                                            imageErrorBuilder:
                                                (context, error, stackTrace) =>
                                                    erroWidget(125),


                                            placeholder: placeHolder(125),
                                          ),
                                          Positioned.fill(
                                              child: favList[index]
                                                          .availability ==
                                                      "0"
                                                  ? Container(
                                                      height: 55,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .white70,

                                                      padding:
                                                          const EdgeInsets.all(2),
                                                      child: Center(
                                                        child: Text(
                                                          getTranslated(context,
                                                              'OUT_OF_STOCK_LBL')!,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .caption!
                                                                  .copyWith(
                                                                    color: Colors
                                                                        .red,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    )
                                                  : Container()),
                                          off != 0
                                              ? Container(
                                                  decoration: BoxDecoration(
                                                      color: colors.red,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    child: Text(
                                                      off.toStringAsFixed(2) +
                                                          "%",
                                                      style: const TextStyle(
                                                          color:
                                                              colors.whiteTemp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 9),
                                                    ),
                                                  ),
                                                  margin: const EdgeInsets.all(5),
                                                )
                                              : Container(),
                                        ],
                                      ))),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      padding:
                                          const EdgeInsets.only(right: 5, top: 5.0),
                                      alignment: Alignment.topRight,
                                      child: InkWell(
                                        child: Icon(
                                          Icons.close,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .lightBlack,
                                        ),
                                        onTap: () {
                                          if (CUR_USERID != null) {
                                            _removeFav(index, favList, context);
                                          } else {
                                            setState(() {
                                              db.addAndRemoveFav(
                                                  favList[index].id!, false);
                                              context
                                                  .read<FavoriteProvider>()
                                                  .removeFavItem(favList[index]
                                                      .prVarientList![0]
                                                      .id!);
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    Padding(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                                start: 8.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                favList[index].name!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle1!
                                                    .copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .lightBlack),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        )),
                                    Padding(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                                start: 8.0, top: 5.0),
                                        child: Row(
                                          children: <Widget>[
                                            Text(
                                        '${getPriceFormat(context,price)!} ',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .fontColor,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            Text(
                                              double.parse(favList[index]
                                                          .prVarientList![0]
                                                          .disPrice!) !=
                                                      0
                                                  ? getPriceFormat(context,double.parse(favList[index]
                                                  .prVarientList![0]
                                                  .price!))!

                                                  : "",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .overline!
                                                  .copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .fontColor
                                                          .withOpacity(0.6),
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                      letterSpacing: 0.7),
                                            ),
                                          ],
                                        )),
                                    _controller[index].text != "0"
                                        ? Row(
                                            children: [

                                              favList[index].availability == "0"
                                                  ? Container()
                                                  : cartBtnList
                                                      ? Row(
                                                          children: <Widget>[
                                                            Row(
                                                              children: <
                                                                  Widget>[
                                                                InkWell(
                                                                  child: Card(
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              50),
                                                                    ),
                                                                    child:
                                                                        const Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              8.0),
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .remove,
                                                                        size:
                                                                            15,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  onTap: () {
                                                                    if (_isProgress ==
                                                                            false &&
                                                                        (int.parse(_controller[index].text) >
                                                                            0)) {
                                                                      removeFromCart(
                                                                          index,
                                                                          favList,
                                                                          context);
                                                                    }
                                                                  },
                                                                ),
                                                                SizedBox(
                                                                  width: 26,
                                                                  height: 20,
                                                                  child: Stack(
                                                                    children: [
                                                                      Selector<
                                                                          CartProvider,
                                                                          Tuple2<
                                                                              List<String?>,
                                                                              String?>>(
                                                                        builder: (context,
                                                                            data,
                                                                            child) {
                                                                          return TextField(
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            readOnly:
                                                                                true,
                                                                            style:
                                                                                TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.fontColor),
                                                                            controller:
                                                                                _controller[index],
                                                                            decoration:
                                                                                const InputDecoration(
                                                                              border: InputBorder.none,
                                                                            ),
                                                                          );
                                                                        },
                                                                        selector: (_, provider) => Tuple2(
                                                                            provider
                                                                                .cartIdList,
                                                                            provider.qtyList(favList[index].id!,
                                                                                favList[index].prVarientList![favList[index].selVarient!].id!)),
                                                                      ),
                                                                      PopupMenuButton<
                                                                          String>(
                                                                        tooltip:
                                                                            '',
                                                                        icon:
                                                                            const Icon(
                                                                          Icons
                                                                              .arrow_drop_down,
                                                                          size:
                                                                              1,
                                                                        ),
                                                                        onSelected:
                                                                            (String
                                                                                value) {
                                                                          if (_isProgress ==
                                                                              false) {
                                                                            addToCart(
                                                                                index,
                                                                                favList,
                                                                                context,
                                                                                value,
                                                                                2);
                                                                          }
                                                                        },
                                                                        itemBuilder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return favList[index]
                                                                              .itemsCounter!
                                                                              .map<PopupMenuItem<String>>((String value) {
                                                                            return PopupMenuItem(
                                                                                child: Text(value, style: TextStyle(color: Theme.of(context).colorScheme.fontColor)),
                                                                                value: value);
                                                                          }).toList();
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),

                                                                InkWell(
                                                                  child: Card(
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              50),
                                                                    ),
                                                                    child:
                                                                        const Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              8.0),
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .add,
                                                                        size:
                                                                            15,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  onTap: () {
                                                                    if (_isProgress ==
                                                                        false) {
                                                                      addToCart(
                                                                          index,
                                                                          favList,
                                                                          context,
                                                                          (int.parse(favList[index].prVarientList![favList[index].selVarient!].cartCount!) + int.parse(favList[index].qtyStepSize!))
                                                                              .toString(),
                                                                          2);
                                                                    }
                                                                  },
                                                                )
                                                              ],
                                                            ),
                                                          ],
                                                        )
                                                      : Container(),
                                            ],
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          splashColor: colors.primary.withOpacity(0.2),
                          onTap: () {
                            Product model = favList[index];
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                  pageBuilder: (_, __, ___) => ProductDetail(
                                        model: model,

                                        secPos: 0,
                                        index: index,
                                        list: true,

                                      )),
                            );
                          },
                        ),
                      ),
                      Positioned.directional(
                          textDirection: Directionality.of(context),
                          bottom: -13,
                          end: 15,
                          child: InkWell(
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40.0),
                                  color: Theme.of(context).colorScheme.white,
                                  boxShadow: const [
                                    BoxShadow(
                                        offset: Offset(2, 2),
                                        blurRadius: 12,
                                        color: Color.fromRGBO(0, 0, 0, 0.13),
                                        spreadRadius: 0.4)
                                  ]),
                              child: const Icon(
                                Icons.shopping_cart,
                                size: 20,
                                color: colors.primary,
                              ),
                            ),
                            onTap: () async {
                              if (_isProgress == false) {
                                addToCart(
                                    index,
                                    favList,
                                    context,
                                    (int.parse(_controller[index].text) +
                                            int.parse(
                                                favList[index].qtyStepSize!))
                                        .toString(),
                                    1);
                              }
                            },
                          ))
                    ],
                  ));
            } else {
              return Container();
            }
          });
    } else {
      return Container();
    }
  }

  Future<void> _getOffFav() async {

    if (proIds!.isNotEmpty) {
      _isNetworkAvail = await isNetworkAvailable();

      if (_isNetworkAvail) {
        try {
          var parameter = {"product_ids": proIds!.join(',')};

          Response response =
              await post(getProductApi, body: parameter, headers: headers)
                  .timeout(const Duration(seconds: timeOut));

          var getdata = json.decode(response.body);
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];

            List<Product> tempList = (data as List)
                .map((data) => Product.fromJson(data))
                .toList();

            context.read<FavoriteProvider>().setFavlist(tempList);
          }
          if (mounted) {
            setState(() {
              context.read<FavoriteProvider>().setLoading(false);
            });
          }
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg')!, context);
          context.read<FavoriteProvider>().setLoading(false);
        }
      } else {
        if (mounted) {
          setState(() {
            _isNetworkAvail = false;
            context.read<FavoriteProvider>().setLoading(false);
          });
        }
      }
    } else {
      context.read<FavoriteProvider>().setFavlist([]);
      setState(() {
        context.read<FavoriteProvider>().setLoading(false);
      });
    }
  }

  Future _getFav() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (CUR_USERID != null) {
        Map parameter = {
          USER_ID: CUR_USERID,
        };
        apiBaseHelper.postAPICall(getFavApi, parameter).then((getdata) {

          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];

            List<Product> tempList = (data as List)
                .map((data) => Product.fromJson(data))
                .toList();

            context.read<FavoriteProvider>().setFavlist(tempList);
          } else {
            if (msg != 'No Favourite(s) Product Are Added') {
              setSnackbar(msg!, context);
            }
          }

          context.read<FavoriteProvider>().setLoading(false);
        }, onError: (error) {
          setSnackbar(error.toString(), context);
          context.read<FavoriteProvider>().setLoading(false);
        });
      } /*else {
        context.read<FavoriteProvider>().setLoading(false);
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => Login()),
        );
      }*/
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

  Future<void> addToCart(int index, List<Product> favList, BuildContext context,
      String qty, int from) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (CUR_USERID != null) {
        try {
          if (mounted) {
            setState(() {
              _isProgress = true;
            });
          }
          String qty = (int.parse(favList[index].prVarientList![0].cartCount!) +
                  int.parse(favList[index].qtyStepSize!))
              .toString();

          if (int.parse(qty) < favList[index].minOrderQuntity!) {
            qty = favList[index].minOrderQuntity.toString();
            setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty", context);
          }

          var parameter = {
            PRODUCT_VARIENT_ID:
                favList[index].prVarientList![favList[index].selVarient!].id,
            USER_ID: CUR_USERID,
            QTY: qty,
          };

          Response response =
              await post(manageCartApi, body: parameter, headers: headers)
                  .timeout(const Duration(seconds: timeOut));
          if (response.statusCode == 200) {
            var getdata = json.decode(response.body);

            bool error = getdata["error"];
            String? msg = getdata["message"];
            if (!error) {
              var data = getdata["data"];

              String? qty = data['total_quantity'];


              context.read<UserProvider>().setCartCount(data['cart_count']);
              favList[index].prVarientList![0].cartCount = qty.toString();
              var cart = getdata["cart"];
              List<SectionModel> cartList = (cart as List)
                  .map((cart) => SectionModel.fromCart(cart))
                  .toList();
              context.read<CartProvider>().setCartlist(cartList);
            } else {
              setSnackbar(msg!, context);
            }
            if (mounted) {
              setState(() {
                _isProgress = false;
              });
            }
          }
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg')!, context);
          if (mounted) {
            setState(() {
              _isProgress = false;
            });
          }
        }
      } else {
        setState(() {
          _isProgress = true;
        });

        if (from == 1) {
          db.insertCart(
              favList[index].id!,
              favList[index].prVarientList![favList[index].selVarient!].id!,
              qty,
              context);
        } else {
          if (int.parse(qty) > favList[index].itemsCounter!.length) {


            setSnackbar("Max Quantity is-${int.parse(qty) - 1}", context);
          } else {
            db.updateCart(
                favList[index].id!,
                favList[index].prVarientList![favList[index].selVarient!].id!,
                qty);
          }
        }
        setState(() {
          _isProgress = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

  removeFromCart(int index, List<Product> favList, BuildContext context) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (CUR_USERID != null) {
        if (mounted) {
          setState(() {
            _isProgress = true;
          });
        }

        int qty;

        qty = (int.parse(_controller[index].text) -
            int.parse(favList[index].qtyStepSize!));

        if (qty < favList[index].minOrderQuntity!) {
          qty = 0;
        }

        var parameter = {
          PRODUCT_VARIENT_ID:
              favList[index].prVarientList![favList[index].selVarient!].id,
          USER_ID: CUR_USERID,
          QTY: qty.toString()
        };

        apiBaseHelper.postAPICall(manageCartApi, parameter).then((getdata) {
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];

            String? qty = data['total_quantity'];

            context.read<UserProvider>().setCartCount(data['cart_count']);
            favList[index]
                .prVarientList![favList[index].selVarient!]
                .cartCount = qty.toString();

            var cart = getdata["cart"];
            List<SectionModel> cartList = (cart as List)
                .map((cart) => SectionModel.fromCart(cart))
                .toList();
            context.read<CartProvider>().setCartlist(cartList);
          } else {
            setSnackbar(msg!, context);
          }

          if (mounted) {
            setState(() {
              _isProgress = false;
            });
          }
        }, onError: (error) {
          setSnackbar(error.toString(), context);
          setState(() {
            _isProgress = false;
          });
        });
      } else {
        setState(() {
          _isProgress = true;
        });

        int qty;

        qty = (int.parse(_controller[index].text) -
            int.parse(favList[index].qtyStepSize!));

        if (qty < favList[index].minOrderQuntity!) {
          qty = 0;

          db.removeCart(
              favList[index].prVarientList![favList[index].selVarient!].id!,
              favList[index].id!,
              context);
        } else {
          db.updateCart(
              favList[index].id!,
              favList[index].prVarientList![favList[index].selVarient!].id!,
              qty.toString());
        }
        setState(() {
          _isProgress = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }


  _removeFav(
    int index,
    List<Product> favList,
    BuildContext context,
  ) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (mounted) {
        setState(() {
          _isProgress = true;
        });
      }
      try {
        var parameter = {
          USER_ID: CUR_USERID,
          PRODUCT_ID: favList[index].id,
        };
        Response response =
            await post(removeFavApi, body: parameter, headers: headers)
                .timeout(const Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          context
              .read<FavoriteProvider>()
              .removeFavItem(favList[index].prVarientList![0].id!);
        } else {
          setSnackbar(msg!, context);
        }

        if (mounted) {
          setState(() {
            _isProgress = false;
          });
        }
      } on TimeoutException catch (_) {
        _isProgress = false;
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

  Future _refresh() async {
    if (mounted) {
      setState(() {
        _isFavLoading = true;
      });
    }
    if (CUR_USERID != null) {
      offset = 0;
      total = 0;
      return _getFav();
    } else {
      proIds = (await db.getFav())!;
      return _getOffFav();
    }
  }

  _showContent(BuildContext context) {
    return Selector<FavoriteProvider, Tuple2<bool, List<Product>>>(
        builder: (context, data, child) {
          return data.item1
              ? shimmer(context)
              : data.item2.isEmpty
                  ? Center(child: Text(getTranslated(context, 'noFav')!))
                  : RefreshIndicator(
                      color: colors.primary,
                      key: _refreshIndicatorKey,
                      onRefresh: _refresh,
                      child: ListView.builder(
                        shrinkWrap: true,
                        // controller: controller,
                        itemCount: data.item2.length,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return listItem(index, data.item2);
                        },
                      ));
        },
        selector: (_, provider) =>
            Tuple2(provider.isLoading, provider.favList));
  }
}
