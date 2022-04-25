import 'dart:async';
import 'dart:convert';
import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Helper/Slideanimation.dart';
import 'package:eshop/Helper/SqliteData.dart';
import 'package:eshop/Provider/CartProvider.dart';
import 'package:eshop/Provider/FavoriteProvider.dart';
import 'package:eshop/Provider/UserProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../Helper/AppBtn.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/SimBtn.dart';
import '../Helper/String.dart';
import '../Model/Section_Model.dart';
import 'HomePage.dart';
import 'Product_Detail.dart';

class SectionList extends StatefulWidget {
  final int? index;
  SectionModel? section_model;

  SectionList({
    Key? key,
    this.index,
    this.section_model,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => StateSection();
}

class StateSection extends State<SectionList> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoadingmore = true, _isLoading = true, _isNetworkAvail = true;
  ScrollController controller = ScrollController();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  RangeValues? _currentRangeValues;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  String sortBy = 'p.id', orderBy = "DESC";

  late List<String> attsubList;
  late List<String> attListId;
  String? filter = "", selId = "";
  bool listType = true, _isProgress = false;
  int? total = 0, offset;
  final List<TextEditingController> _controller = [];
  late UserProvider userProvidser;
  String minPrice = "0", maxPrice = "0";
  ChoiceChip? choiceChip;
  var db = DatabaseHelper();
  AnimationController? _animationController;
  AnimationController? _animationController1;

  @override
  void initState() {
    super.initState();
    widget.section_model!.productList!.clear();
    widget.section_model!.offset = widget.section_model!.productList!.length;

    widget.section_model!.selectedId = [];
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200));
    _animationController1 = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200));
    getSection("0");
    controller.addListener(_scrollListener);
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
    _animationController1!.dispose();
    _animationController!.dispose();
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

  void getAvailVarient(List<Product> productList) {
    for (int j = 0; j < productList.length; j++) {
      if (productList[j].stockType == "2") {
        for (int i = 0; i < productList[j].prVarientList!.length; i++) {
          if (productList[j].prVarientList![i].availability == "1") {
            productList[j].selVarient = i;

            break;
          }
        }
      }
    }
    widget.section_model!.productList!.addAll(productList);
    //sectionList[widget.index!].productList!.addAll(productList);
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

  Future<void> _refresh() {
    if (mounted) {
      setState(() {
        _isLoading = true;
        isLoadingmore = true;
        widget.section_model!.offset = 0;
        widget.section_model!.totalItem = 0;
        widget.section_model!.selectedId = [];
        selId = '';
      });
    }

    total = 0;
    offset = 0;
    widget.section_model!.productList!.clear();
    return getSection("0");
  }

  @override
  Widget build(BuildContext context) {
    userProvidser = Provider.of<UserProvider>(context);
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: scaffoldKey,
      appBar: getAppBar(sectionList[widget.index!].title!, context),
      body: _isNetworkAvail
          ? RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _refresh,
              child: _isLoading
                  ? shimmer(context)
                  : Column(
                      children: [
                        filterOptions(),
                        Expanded(
                          child: Stack(
                            children: <Widget>[
                              listType
                                  ? ListView.builder(
                                      controller: controller,
                                      itemCount: (widget
                                                  .section_model!.offset! <
                                              widget.section_model!.totalItem!)
                                          ? widget.section_model!.productList!
                                                  .length +
                                              1
                                          : widget.section_model!.productList!
                                              .length,
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        return (index ==
                                                    widget.section_model!
                                                        .productList!.length &&
                                                isLoadingmore)
                                            ? singleItemSimmer(context)
                                            : listItem(index);
                                      },
                                    )
                                  : GridView.count(
                                      padding: const EdgeInsetsDirectional.only(
                                        top: 5,
                                      ),
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.6,
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      controller: controller,
                                      children: List.generate(
                                        (widget.section_model!.offset! <
                                                widget
                                                    .section_model!.totalItem!)
                                            ? widget.section_model!.productList!
                                                    .length +
                                                1
                                            : widget.section_model!.productList!
                                                .length,
                                        (index) {
                                          return (index ==
                                                      widget
                                                          .section_model!
                                                          .productList!
                                                          .length &&
                                                  isLoadingmore)
                                              ? simmerSingleProduct(context)
                                              : productItem(index);
                                        },
                                      )),
                              showCircularProgress(_isProgress, colors.primary),
                            ],
                          ),
                        ),
                      ],
                    ))
          : noInternet(context),
    );
  }

  filterOptions() {
    return Container(
        color: Theme.of(context).colorScheme.white,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Container(
          color: Theme.of(context).colorScheme.gray,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                  onPressed: filterDialog,
                  icon: const Icon(
                    Icons.filter_list,
                    color: colors.primary,
                  ),
                  label: Text(
                    getTranslated(context, 'FILTER')!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.fontColor,
                    ),
                  )),
              TextButton.icon(
                  onPressed: sortDialog,
                  icon: const Icon(
                    Icons.swap_vert,
                    color: colors.primary,
                  ),
                  label: Text(
                    getTranslated(context, 'SORT_BY')!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.fontColor,
                    ),
                  )),
              InkWell(
                child: Icon(
                  listType ? Icons.grid_view : Icons.list,
                  color: colors.primary,
                ),
                onTap: () {
                  sectionList.isNotEmpty
                      ? setState(() {
                          _animationController!.reverse();
                          _animationController1!.reverse();
                          listType = !listType;
                        })
                      : null;
                },
              ),
            ],
          ),
        ));
  }

  Widget listItem(int index) {
    if (index < widget.section_model!.productList!.length) {
      Product model = widget.section_model!.productList![index];

      double price = double.parse(widget.section_model!.productList![index]
          .prVarientList![model.selVarient!].disPrice!);
      if (price == 0) {
        price = double.parse(widget.section_model!.productList![index]
            .prVarientList![model.selVarient!].price!);
      }

      double off = (double.parse(
                  model.prVarientList![model.selVarient!].price!) -
              double.parse(model.prVarientList![model.selVarient!].disPrice!))
          .toDouble();
      off = off *
          100 /
          double.parse(model.prVarientList![model.selVarient!].price!);

      List att = [], val = [];
      if (model.prVarientList![model.selVarient!].attr_name != null) {
        att = model.prVarientList![model.selVarient!].attr_name!.split(',');
        val = model.prVarientList![model.selVarient!].varient_value!.split(',');
      }
      if (_controller.length < index + 1) {
        _controller.add(TextEditingController());
      }

      /* if (CUR_USERID == null) {
                    model.prVarientList![model.selVarient!].cartCount =
                        snapshot.data;
                    _controller[index].text = snapshot.data;
                  } else {
                    _controller[index].text =
                        model.prVarientList![model.selVarient!].cartCount!;
                  }*/

      return SlideAnimation(
        position: index,
        itemCount: widget.section_model!.productList!.length,
        slideDirection: SlideDirection.fromBottom,
        animationController: _animationController,
        child: Selector<CartProvider, Tuple2<List<String?>, String?>>(
          builder: (context, data, child) {
            if (data.item1.contains(model.id)) {
              _controller[index].text = data.item2.toString();
            } else {
              _controller[index].text =
                  model.prVarientList![model.selVarient!].cartCount!;
            }
            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Card(
                    elevation: 0,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      child: Stack(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Hero(
                                tag:
                                    /*$index*/ "$index${widget.section_model!.productList![index].id}",
                                child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        bottomLeft: Radius.circular(10)),
                                    child: Stack(
                                      children: [
                                        FadeInImage(
                                          image: NetworkImage(
                                              widget.section_model!
                                                  .productList![index].image!),
                                          height: 125.0,
                                          width: 110.0,
                                          placeholder: placeHolder(125),
                                          fit: extendImg
                                              ? BoxFit.fill
                                              : BoxFit.contain,
                                          imageErrorBuilder:
                                              (context, error, stackTrace) =>
                                                  erroWidget(125),
                                        ),
                                        model.availability == "0"
                                            ? Container(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .white70,
                                                width: 110,
                                                padding:
                                                    const EdgeInsets.all(2),
                                                height: 125,
                                                child: Center(
                                                  child: Text(
                                                      getTranslated(context,
                                                          'OUT_OF_STOCK_LBL')!,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle2!
                                                          .copyWith(
                                                              color: Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                ),
                                              )
                                            : Container(),
                                        off != 0 &&
                                                model
                                                        .prVarientList![
                                                            model.selVarient!]
                                                        .disPrice! !=
                                                    "0"
                                            ? Container(
                                                decoration: BoxDecoration(
                                                  color: colors.red,
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: Text(
                                                    off.toStringAsFixed(2) +
                                                        "%",
                                                    style: const TextStyle(
                                                        color: colors.whiteTemp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 9),
                                                  ),
                                                ),
                                                margin: const EdgeInsets.all(5),
                                              )
                                            : Container(),
                                      ],
                                    )),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        model.name!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .lightBlack),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      model.prVarientList![model.selVarient!]
                                                      .attr_name !=
                                                  null &&
                                              model
                                                  .prVarientList![
                                                      model.selVarient!]
                                                  .attr_name!
                                                  .isNotEmpty
                                          ? ListView.builder(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount: att.length >= 2
                                                  ? 2
                                                  : att.length,
                                              itemBuilder: (context, index) {
                                                return Row(children: [
                                                  Flexible(
                                                    child: Text(
                                                      att[index].trim() + ":",
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle2!
                                                          .copyWith(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .lightBlack),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsetsDirectional
                                                            .only(start: 5.0),
                                                    child: Text(
                                                      val[index],
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle2!
                                                          .copyWith(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .lightBlack,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                  )
                                                ]);
                                              })
                                          : Container(),
                                      model.noOfRating! != "0"
                                          ? Row(
                                              children: [
                                                RatingBarIndicator(
                                                  rating: double.parse(
                                                      model.rating!),
                                                  itemBuilder:
                                                      (context, index) =>
                                                          const Icon(
                                                    Icons.star_rate_rounded,
                                                    color: Colors.amber,
                                                    //color: colors.primary,
                                                  ),
                                                  unratedColor: Colors.grey
                                                      .withOpacity(0.5),
                                                  itemCount: 5,
                                                  itemSize: 18.0,
                                                  direction: Axis.horizontal,
                                                ),
                                                Text(
                                                  " (" +
                                                      model.noOfRating! +
                                                      ")",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .overline,
                                                )
                                              ],
                                            )
                                          : Container(),
                                      Row(
                                        children: <Widget>[
                                          Text(
                                              '${getPriceFormat(context, price)!} ',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle2!
                                                  .copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .fontColor,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                          Text(
                                            double.parse(model
                                                        .prVarientList![
                                                            model.selVarient!]
                                                        .disPrice!) !=
                                                    0
                                                ? getPriceFormat(
                                                    context,
                                                    double.parse(model
                                                        .prVarientList![
                                                            model.selVarient!]
                                                        .price!))!
                                                : "",
                                            style: Theme.of(context)
                                                .textTheme
                                                .overline!
                                                .copyWith(
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                    letterSpacing: 0),
                                          ),
                                        ],
                                      ),
                                      _controller[index].text != "0"
                                          ? Row(
                                              children: [
                                                //Spacer(),
                                                model.availability == "0"
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
                                                                            BorderRadius.circular(50),
                                                                      ),
                                                                      child:
                                                                          const Padding(
                                                                        padding:
                                                                            EdgeInsets.all(8.0),
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
                                                                          (int.parse(_controller[index].text)) >
                                                                              0) {
                                                                        removeFromCart(
                                                                            index);
                                                                      }
                                                                    },
                                                                  ),
                                                                  SizedBox(
                                                                    width: 37,
                                                                    height: 20,
                                                                    child:
                                                                        Stack(
                                                                      children: [
                                                                        /* _controller[index].text = data.item1.contains(model.id) ? data.item2[data.item1.indexWhere((element) => element == model.id)].toString() : "0";*/
                                                                        TextField(
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          readOnly:
                                                                              true,
                                                                          style: TextStyle(
                                                                              fontSize: 12,
                                                                              color: Theme.of(context).colorScheme.fontColor),
                                                                          controller:
                                                                              _controller[index],
                                                                          // _controller[index],
                                                                          decoration:
                                                                              const InputDecoration(
                                                                            border:
                                                                                InputBorder.none,
                                                                          ),
                                                                        ),
                                                                        PopupMenuButton<
                                                                            String>(
                                                                          tooltip:
                                                                              '',
                                                                          icon:
                                                                              const Icon(
                                                                            Icons.arrow_drop_down,
                                                                            size:
                                                                                0,
                                                                          ),
                                                                          onSelected:
                                                                              (String value) {
                                                                            if (_isProgress ==
                                                                                false) {
                                                                              addToCart(index, value, 2);
                                                                            }
                                                                          },
                                                                          itemBuilder:
                                                                              (BuildContext context) {
                                                                            return model.itemsCounter!.map<PopupMenuItem<String>>((String
                                                                                value) {
                                                                              return PopupMenuItem(child: Text(value, style: TextStyle(color: Theme.of(context).colorScheme.fontColor)), value: value);
                                                                            }).toList();
                                                                          },
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  // ),

                                                                  InkWell(
                                                                    child: Card(
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(50),
                                                                      ),
                                                                      child:
                                                                          const Padding(
                                                                        padding:
                                                                            EdgeInsets.all(8.0),
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
                                                                            (int.parse(_controller[index].text) + int.parse(model.qtyStepSize!)).toString(),
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
                              )
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        Product model =
                            widget.section_model!.productList![index];
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                              // transitionDuration: Duration(seconds: 1),
                              pageBuilder: (_, __, ___) => ProductDetail(
                                    model: model,
                                    secPos: widget.index,
                                    index: index,
                                    list: true,
                                  )),
                        );
                      },
                    ),
                  ),
                  model.availability == "0" && !cartBtnList
                      ? Container()
                      : _controller[index].text == "0"
                          ? Positioned(
                              bottom: -15,
                              right: 45,
                              child: InkWell(
                                onTap: () {
                                  if (_isProgress == false) {
                                    addToCart(
                                        index,
                                        (int.parse(_controller[index].text) +
                                                int.parse(model.qtyStepSize!))
                                            .toString(),
                                        1);
                                  }
                                },
                                child: Card(
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.shopping_cart_outlined,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                  Positioned(
                      bottom: -15,
                      right: 0,
                      child: Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: model.isFavLoading!
                              ? const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: colors.primary,
                                        strokeWidth: 0.7,
                                      )),
                                )
                              : Selector<FavoriteProvider, List<String?>>(
                                  builder: (context, data, child) {
                                    return InkWell(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          !data.contains(model.id)
                                              ? Icons.favorite_border
                                              : Icons.favorite,
                                          size: 20,
                                        ),
                                      ),
                                      onTap: () {
                                        if (CUR_USERID != null) {
                                          !data.contains(model.id)
                                              ? _setFav(index)
                                              : _removeFav(index);
                                        } else {
                                          if (!data.contains(model.id)) {
                                            model.isFavLoading = true;
                                            model.isFav = "1";
                                            context
                                                .read<FavoriteProvider>()
                                                .addFavItem(model);
                                            db.addAndRemoveFav(model.id!, true);
                                            model.isFavLoading = false;
                                          } else {
                                            model.isFavLoading = true;
                                            model.isFav = "0";
                                            context
                                                .read<FavoriteProvider>()
                                                .removeFavItem(model
                                                    .prVarientList![0].id!);
                                            db.addAndRemoveFav(
                                                model.id!, false);
                                            model.isFavLoading = false;
                                          }
                                          setState(() {});
                                        }
                                      },
                                    );
                                  },
                                  selector: (_, provider) => provider.favIdList,
                                )))
                ],
              ),
            );
          },
          selector: (_, provider) => Tuple2(provider.cartIdList,
              provider.qtyList(model.id!, model.prVarientList![0].id!)),
        ),
      );
    } else {
      return Container();
    }
  }

  Future<void> addToCart(int index, String qty, int from) async {
    Product model = widget.section_model!.productList![index];
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (CUR_USERID != null) {
        try {
          if (mounted) {
            setState(() {
              _isProgress = true;
            });
          }

          if (int.parse(qty) < model.minOrderQuntity!) {
            qty = model.minOrderQuntity.toString();

            setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty");
          }

          var parameter = {
            USER_ID: CUR_USERID,
            PRODUCT_VARIENT_ID: model.prVarientList![model.selVarient!].id,
            QTY: qty
          };
          Response response =
              await post(manageCartApi, body: parameter, headers: headers)
                  .timeout(const Duration(seconds: timeOut));

          var getdata = json.decode(response.body);

          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];

            String? qty = data['total_quantity'];

            userProvidser.setCartCount(data['cart_count']);
            model.prVarientList![model.selVarient!].cartCount = qty.toString();

            var cart = getdata["cart"];

            List<SectionModel> cartList = (cart as List)
                .map((cart) => SectionModel.fromCart(cart))
                .toList();
            context.read<CartProvider>().setCartlist(cartList);
          } else {
            setSnackbar(msg!);
          }
          if (mounted) {
            setState(() {
              _isProgress = false;
            });
          }
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg')!);
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
          List<Product>? prList = [];
          prList.add(model);
          context.read<CartProvider>().addCartItem(SectionModel(
                qty: qty,
                productList: prList,
                varientId: model.prVarientList![model.selVarient!].id!,
                id: model.id,
              ));
          db.insertCart(model.id!, model.prVarientList![model.selVarient!].id!,
              qty, context);
        } else {
          if (int.parse(qty) > model.itemsCounter!.length) {
            // qty = productList[index].minOrderQuntity.toString();

            setSnackbar("Max Quantity is-${int.parse(qty) - 1}");
          } else {
            context.read<CartProvider>().updateCartItem(model.id!, qty,
                model.selVarient!, model.prVarientList![model.selVarient!].id!);
            db.updateCart(
                model.id!, model.prVarientList![model.selVarient!].id!, qty);
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

  removeFromCart(int index) async {
    Product model = widget.section_model!.productList![index];
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (CUR_USERID != null) {
        try {
          if (mounted) {
            setState(() {
              _isProgress = true;
            });
          }

          int qty;

          qty = (int.parse(_controller[index].text) -
              int.parse(model.qtyStepSize!));

          if (qty < model.minOrderQuntity!) {
            qty = 0;
          }

          var parameter = {
            PRODUCT_VARIENT_ID: model.prVarientList![model.selVarient!].id,
            USER_ID: CUR_USERID,
            QTY: qty.toString()
          };

          Response response =
              await post(manageCartApi, body: parameter, headers: headers)
                  .timeout(const Duration(seconds: timeOut));
          var getdata = json.decode(response.body);

          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];

            String? qty = data['total_quantity'];

            userProvidser.setCartCount(data['cart_count']);
            model.prVarientList![model.selVarient!].cartCount = qty.toString();

            var cart = getdata["cart"];
            List<SectionModel> cartList = (cart as List)
                .map((cart) => SectionModel.fromCart(cart))
                .toList();
            context.read<CartProvider>().setCartlist(cartList);
          } else {
            setSnackbar(msg!);
          }
          if (mounted) {
            setState(() {
              _isProgress = false;
            });
          }
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg')!);
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

        int qty;

        qty = (int.parse(_controller[index].text) -
            int.parse(model.qtyStepSize!));

        if (qty < model.minOrderQuntity!) {
          qty = 0;
          context
              .read<CartProvider>()
              .removeCartItem(model.prVarientList![model.selVarient!].id!);
          db.removeCart(
              model.prVarientList![model.selVarient!].id!, model.id!, context);
        } else {
          context.read<CartProvider>().updateCartItem(model.id!, qty.toString(),
              model.selVarient!, model.prVarientList![model.selVarient!].id!);
          db.updateCart(model.id!, model.prVarientList![model.selVarient!].id!,
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

  void sortDialog() {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.white,
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      builder: (builder) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Padding(
                        padding: const EdgeInsetsDirectional.only(
                            top: 19.0, bottom: 16.0),
                        child: Text(
                          getTranslated(context, 'SORT_BY')!,
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.fontColor),
                        )),
                  ),
                  InkWell(
                    onTap: () {
                      sortBy = '';
                      orderBy = 'DESC';

                      clearList("1");
                      Navigator.pop(context, 'option 1');
                    },
                    child: Container(
                      width: deviceWidth,
                      color: sortBy == ''
                          ? colors.primary
                          : Theme.of(context).colorScheme.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      child: Text(getTranslated(context, 'TOP_RATED')!,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(
                                  color: sortBy == ''
                                      ? Theme.of(context).colorScheme.white
                                      : Theme.of(context)
                                          .colorScheme
                                          .fontColor)),
                    ),
                  ),
                  InkWell(
                      child: Container(
                          width: deviceWidth,
                          color: sortBy == 'p.date_added' && orderBy == 'DESC'
                              ? colors.primary
                              : Theme.of(context).colorScheme.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          child: Text(getTranslated(context, 'F_NEWEST')!,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(
                                      color: sortBy == 'p.date_added' &&
                                              orderBy == 'DESC'
                                          ? Theme.of(context).colorScheme.white
                                          : Theme.of(context)
                                              .colorScheme
                                              .fontColor))),
                      onTap: () {
                        sortBy = 'p.date_added';
                        orderBy = 'DESC';

                        clearList("0");
                        Navigator.pop(context, 'option 1');
                      }),
                  InkWell(
                      child: Container(
                          width: deviceWidth,
                          color: sortBy == 'p.date_added' && orderBy == 'ASC'
                              ? colors.primary
                              : Theme.of(context).colorScheme.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          child: Text(
                            getTranslated(context, 'F_OLDEST')!,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1!
                                .copyWith(
                                    color: sortBy == 'p.date_added' &&
                                            orderBy == 'ASC'
                                        ? Theme.of(context).colorScheme.white
                                        : Theme.of(context)
                                            .colorScheme
                                            .fontColor),
                          )),
                      onTap: () {
                        sortBy = 'p.date_added';
                        orderBy = 'ASC';

                        clearList("0");
                        Navigator.pop(context, 'option 2');
                      }),
                  InkWell(
                      child: Container(
                          width: deviceWidth,
                          color: sortBy == 'pv.price' && orderBy == 'ASC'
                              ? colors.primary
                              : Theme.of(context).colorScheme.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          child: Text(
                            getTranslated(context, 'F_LOW')!,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1!
                                .copyWith(
                                    color: sortBy == 'pv.price' &&
                                            orderBy == 'ASC'
                                        ? Theme.of(context).colorScheme.white
                                        : Theme.of(context)
                                            .colorScheme
                                            .fontColor),
                          )),
                      onTap: () {
                        sortBy = 'pv.price';
                        orderBy = 'ASC';

                        clearList("0");
                        Navigator.pop(context, 'option 3');
                      }),
                  InkWell(
                      child: Container(
                          width: deviceWidth,
                          color: sortBy == 'pv.price' && orderBy == 'DESC'
                              ? colors.primary
                              : Theme.of(context).colorScheme.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          child: Text(
                            getTranslated(context, 'F_HIGH')!,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1!
                                .copyWith(
                                    color: sortBy == 'pv.price' &&
                                            orderBy == 'DESC'
                                        ? Theme.of(context).colorScheme.white
                                        : Theme.of(context)
                                            .colorScheme
                                            .fontColor),
                          )),
                      onTap: () {
                        sortBy = 'pv.price';
                        orderBy = 'DESC';

                        clearList("0");
                        Navigator.pop(context, 'option 4');
                      }),
                ]),
          );
        });
      },
    );
  }

  void filterDialog() {
    showModalBottomSheet(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (builder) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
                padding: const EdgeInsetsDirectional.only(top: 30.0),
                child: AppBar(
                  title: Text(
                    getTranslated(context, 'FILTER')!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.fontColor,
                    ),
                  ),
                  centerTitle: true,
                  elevation: 5,
                  backgroundColor: Theme.of(context).colorScheme.white,
                  leading: Builder(builder: (BuildContext context) {
                    return Container(
                      margin: const EdgeInsets.all(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: () => Navigator.of(context).pop(),
                        child: const Padding(
                          padding: EdgeInsetsDirectional.only(end: 4.0),
                          child: Icon(Icons.arrow_back_ios_rounded,
                              color: colors.primary),
                        ),
                      ),
                    );
                  }),
                )),
            Expanded(
                child: Container(
              color: Theme.of(context).colorScheme.lightWhite,
              padding: const EdgeInsetsDirectional.only(
                  start: 7.0, end: 7.0, top: 7.0),
              child: widget.section_model!.filterList != null
                  ? ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      padding: const EdgeInsetsDirectional.only(top: 10.0),
                      itemCount: widget.section_model!.filterList!.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Column(
                            children: [
                              SizedBox(
                                  width: deviceWidth,
                                  child: Card(
                                      elevation: 0,
                                      child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Price Range',
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle1!
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .lightBlack,
                                                    fontWeight:
                                                        FontWeight.normal),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          )))),
                              RangeSlider(
                                values: _currentRangeValues!,
                                min: double.parse(minPrice),
                                max: double.parse(maxPrice),
                                divisions: 10,
                                labels: RangeLabels(
                                  _currentRangeValues!.start.round().toString(),
                                  _currentRangeValues!.end.round().toString(),
                                ),
                                onChanged: (RangeValues values) {
                                  setState(() {
                                    _currentRangeValues = values;
                                  });
                                },
                              ),
                            ],
                          );
                        } else {
                          index = index - 1;

                          attsubList = widget.section_model!.filterList![index]
                              .attributeValues!
                              .split(',');

                          attListId = widget
                              .section_model!.filterList![index].attributeValId!
                              .split(',');

                          List<Widget?> chips = [];
                          List<String> att = widget.section_model!
                              .filterList![index].attributeValues!
                              .split(',');

                          List<String> attSType = widget
                              .section_model!.filterList![index].swatchType!
                              .split(',');

                          List<String> attSValue = widget
                              .section_model!.filterList![index].swatchValue!
                              .split(',');

                          for (int i = 0; i < att.length; i++) {
                            Widget itemLabel;
                            if (attSType[i] == "1") {
                              String clr = (attSValue[i].substring(1));

                              String color = "0xff" + clr;

                              itemLabel = Container(
                                width: 25,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(int.parse(color))),
                              );
                            } else if (attSType[i] == "2") {
                              itemLabel = ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.network(attSValue[i],
                                      width: 80,
                                      height: 80,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              erroWidget(80)));
                            } else {
                              itemLabel = Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(att[i],
                                    style: TextStyle(
                                        color: widget.section_model!.selectedId!
                                                .contains(attListId[i])
                                            ? Theme.of(context)
                                                .colorScheme
                                                .white
                                            : Theme.of(context)
                                                .colorScheme
                                                .fontColor)),
                              );
                            }

                            choiceChip = ChoiceChip(
                              selected: widget.section_model!.selectedId!
                                  .contains(attListId[i]),
                              label: itemLabel,
                              labelPadding: const EdgeInsets.all(0),
                              selectedColor: colors.primary,
                              backgroundColor:
                                  Theme.of(context).colorScheme.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    attSType[i] == "1" ? 100 : 10),
                                side: BorderSide(
                                    color: widget.section_model!.selectedId!
                                            .contains(attListId[i])
                                        ? colors.primary
                                        : colors.black12,
                                    width: 1.5),
                              ),
                              onSelected: (bool selected) {
                                attListId = widget.section_model!
                                    .filterList![index].attributeValId!
                                    .split(',');

                                if (mounted) {
                                  setState(() {
                                    if (selected == true) {
                                      widget.section_model!.selectedId!
                                          .add(attListId[i]);
                                    } else {
                                      widget.section_model!.selectedId!
                                          .remove(attListId[i]);
                                    }
                                  });
                                }
                              },
                            );

                            chips.add(choiceChip);
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: deviceWidth,
                                child: Card(
                                  elevation: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      widget.section_model!.filterList![index]
                                          .name!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .fontColor,
                                              fontWeight: FontWeight.normal),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ),
                              ),
                              chips.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Wrap(
                                        children:
                                            chips.map<Widget>((Widget? chip) {
                                          return Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: chip,
                                          );
                                        }).toList(),
                                      ),
                                    )
                                  : Container()
                            ],
                          );
                        }
                      })
                  : Container(),
            )),
            Container(
              color: Theme.of(context).colorScheme.white,
              child: Row(children: <Widget>[
                Container(
                  margin: const EdgeInsetsDirectional.only(start: 20),
                  width: deviceWidth! * 0.4,
                  child: OutlinedButton(
                    onPressed: () {
                      if (mounted) {
                        setState(() {
                          widget.section_model!.selectedId!.clear();
                        });
                      }
                    },
                    child: Text(getTranslated(context, 'DISCARD')!),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 20),
                  child: SimBtn(
                      width: 0.4,
                      height: 35,
                      title: getTranslated(context, 'APPLY'),
                      onBtnSelected: () {
                        if (widget.section_model!.selectedId != null) {
                          selId = widget.section_model!.selectedId!.join(',');
                          clearList("0");
                          Navigator.pop(context, 'Product Filter');
                        }
                      }),
                ),
              ]),
            )
          ]);
        });
      },
    );
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (mounted) {
        if (mounted) {
          setState(() {
            isLoadingmore = true;
            if (widget.section_model!.offset! <
                widget.section_model!.totalItem!) getSection("0");
          });
        }
      }
    }
  }

  clearList(String top) {
    if (mounted) {
      setState(() {
        _isLoading = true;
        total = 0;
        offset = 0;
        widget.section_model!.totalItem = 0;
        widget.section_model!.offset = 0;
        widget.section_model!.productList = [];

        getSection(top);
      });
    }
  }

  productItem(int index) {
    if (index < widget.section_model!.productList!.length) {
      Product model = widget.section_model!.productList![index];

      double width = deviceWidth! * 0.5 - 20;
      double price =
          double.parse(model.prVarientList![model.selVarient!].disPrice!);
      List att = [], val = [];
      if (model.prVarientList![model.selVarient!].attr_name != null) {
        att = model.prVarientList![model.selVarient!].attr_name!.split(',');
        val = model.prVarientList![model.selVarient!].varient_value!.split(',');
      }

      if (_controller.length < index + 1) {
        _controller.add(TextEditingController());
      }

      /*  if (CUR_USERID == null) {
                    model.prVarientList![model.selVarient!].cartCount =
                        snapshot.data;
                    _controller[index].text = snapshot.data;
                  } else {
                    _controller[index].text =
                        model.prVarientList![model.selVarient!].cartCount!;
                  }*/

      if (price == 0) {
        price = double.parse(model.prVarientList![model.selVarient!].price!);
      }

      double off = (double.parse(
                  model.prVarientList![model.selVarient!].price!) -
              double.parse(model.prVarientList![model.selVarient!].disPrice!))
          .toDouble();
      off = off *
          100 /
          double.parse(model.prVarientList![model.selVarient!].price!);
      return SlideAnimation(
          position: index,
          itemCount: widget.section_model!.productList!.length,
          slideDirection: SlideDirection.fromBottom,
          animationController: _animationController1,
          child: Selector<CartProvider, Tuple2<List<String?>, String?>>(
            builder: (context, data, child) {
              if (data.item1.contains(model.id)) {
                _controller[index].text = data.item2.toString();
              } else {
                _controller[index].text =
                    model.prVarientList![model.selVarient!].cartCount!;
              }

              return Card(
                elevation: 0,
                child: InkWell(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                          child: Stack(
                        alignment: Alignment.bottomRight,
                        clipBehavior: Clip.none,
                        children: [
                          Hero(
                            tag:
                                "$index${sectionList[widget.index!].productList![index].id}" /*${widget.index}$index*/,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  topRight: Radius.circular(5)),
                              child: FadeInImage(
                                image: NetworkImage(model.image!),
                                height: double.maxFinite,
                                width: double.maxFinite,
                                fadeInDuration:
                                    const Duration(milliseconds: 150),
                                fit: extendImg ? BoxFit.fill : BoxFit.contain,
                                imageErrorBuilder:
                                    (context, error, stackTrace) =>
                                        erroWidget(width),

                                //errorWidget:(context, url,e) => placeHolder(width) ,
                                placeholder: placeHolder(width),
                              ),
                            ),
                          ),
                          model.availability == "0"
                              ? Container(
                                  constraints: const BoxConstraints.expand(),
                                  color: Theme.of(context).colorScheme.white70,
                                  width: double.maxFinite,
                                  padding: const EdgeInsets.all(2),
                                  child: Center(
                                    child: Text(
                                      getTranslated(
                                          context, 'OUT_OF_STOCK_LBL')!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2!
                                          .copyWith(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              : Container(),
                          off != 0 &&
                                  model.prVarientList![model.selVarient!]
                                          .disPrice! !=
                                      "0"
                              ? Align(
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: colors.red,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text(
                                        off.toStringAsFixed(2) + "%",
                                        style: const TextStyle(
                                            color: colors.whiteTemp,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 9),
                                      ),
                                    ),
                                    margin: const EdgeInsets.all(5),
                                  ),
                                )
                              : Container(),
                          const Divider(
                            height: 1,
                          ),
                          Positioned(
                            right: 0,
                            // bottom: -18,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _controller[index].text == "0"
                                    ? InkWell(
                                        onTap: () {
                                          if (_isProgress == false) {
                                            addToCart(
                                                index,
                                                (int.parse(_controller[index]
                                                            .text) +
                                                        int.parse(
                                                            model.qtyStepSize!))
                                                    .toString(),
                                                1);
                                          }
                                        },
                                        child: Card(
                                          elevation: 1,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Icon(
                                              Icons.shopping_cart_outlined,
                                              size: 15,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Padding(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                                start: 3.0, bottom: 5, top: 3),
                                        child: model.availability == "0"
                                            ? Container()
                                            : cartBtnList
                                                ? Row(
                                                    children: <Widget>[
                                                      InkWell(
                                                        child: Card(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        50),
                                                          ),
                                                          child: const Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8.0),
                                                            child: Icon(
                                                              Icons.remove,
                                                              size: 15,
                                                            ),
                                                          ),
                                                        ),
                                                        onTap: () {
                                                          if (_isProgress ==
                                                                  false &&
                                                              (int.parse(_controller[
                                                                          index]
                                                                      .text)) >
                                                                  0) {
                                                            removeFromCart(
                                                                index);
                                                          }
                                                        },
                                                      ),
                                                      Container(
                                                        width: 37,
                                                        height: 20,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .white70,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                        child: Stack(
                                                          children: [
                                                            /*  _controller[
                                                                        index]
                                                                    .text = data
                                                                        .item1
                                                                        .contains(model
                                                                            .id)
                                                                    ? data
                                                                        .item2[data.item1.indexWhere((element) =>
                                                                            element ==
                                                                            model.id)]
                                                                        .toString()
                                                                    : "0";*/
                                                            TextField(
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              readOnly: true,
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .fontColor),
                                                              controller:
                                                                  _controller[
                                                                      index],
                                                              // _controller[index],
                                                              decoration:
                                                                  const InputDecoration(
                                                                border:
                                                                    InputBorder
                                                                        .none,
                                                              ),
                                                            ),
                                                            PopupMenuButton<
                                                                String>(
                                                              tooltip: '',
                                                              icon: const Icon(
                                                                Icons
                                                                    .arrow_drop_down,
                                                                size: 0,
                                                              ),
                                                              onSelected:
                                                                  (String
                                                                      value) {
                                                                if (_isProgress ==
                                                                    false) {
                                                                  addToCart(
                                                                      index,
                                                                      value,
                                                                      2);
                                                                }
                                                              },
                                                              itemBuilder:
                                                                  (BuildContext
                                                                      context) {
                                                                return model
                                                                    .itemsCounter!
                                                                    .map<
                                                                        PopupMenuItem<
                                                                            String>>((String
                                                                        value) {
                                                                  return PopupMenuItem(
                                                                      child: Text(
                                                                          value,
                                                                          style:
                                                                              TextStyle(color: Theme.of(context).colorScheme.fontColor)),
                                                                      value: value);
                                                                }).toList();
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ), // ),

                                                      InkWell(
                                                        child: Card(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        50),
                                                          ),
                                                          child: const Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8.0),
                                                            child: Icon(
                                                              Icons.add,
                                                              size: 15,
                                                            ),
                                                          ),
                                                        ),
                                                        onTap: () {
                                                          if (_isProgress ==
                                                              false) {
                                                            addToCart(
                                                                index,
                                                                (int.parse(_controller[index]
                                                                            .text) +
                                                                        int.parse(
                                                                            model.qtyStepSize!))
                                                                    .toString(),
                                                                2);
                                                          }
                                                        },
                                                      )
                                                    ],
                                                  )
                                                : Container(),
                                      ),
                                Card(
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: model.isFavLoading!
                                        ? const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: SizedBox(
                                                height: 15,
                                                width: 15,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: colors.primary,
                                                  strokeWidth: 0.7,
                                                )),
                                          )
                                        : Selector<FavoriteProvider,
                                            List<String?>>(
                                            builder: (context, data, child) {
                                              return InkWell(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Icon(
                                                    !data.contains(model.id)
                                                        ? Icons.favorite_border
                                                        : Icons.favorite,
                                                    size: 15,
                                                  ),
                                                ),
                                                onTap: () {
                                                  if (CUR_USERID != null) {
                                                    !data.contains(model.id)
                                                        ? _setFav(index)
                                                        : _removeFav(index);
                                                  } else {
                                                    if (!data
                                                        .contains(model.id)) {
                                                      model.isFavLoading = true;
                                                      model.isFav = "1";
                                                      context
                                                          .read<
                                                              FavoriteProvider>()
                                                          .addFavItem(model);
                                                      db.addAndRemoveFav(
                                                          model.id!, true);
                                                      model.isFavLoading =
                                                          false;
                                                    } else {
                                                      model.isFavLoading = true;
                                                      model.isFav = "0";
                                                      context
                                                          .read<
                                                              FavoriteProvider>()
                                                          .removeFavItem(model
                                                              .prVarientList![0]
                                                              .id!);
                                                      db.addAndRemoveFav(
                                                          model.id!, false);
                                                      model.isFavLoading =
                                                          false;
                                                    }
                                                    setState(() {});
                                                  }
                                                },
                                              );
                                            },
                                            selector: (_, provider) =>
                                                provider.favIdList,
                                          )),
                              ],
                            ),
                          ),
                        ],
                      )),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            RatingBarIndicator(
                              rating: double.parse(model.rating!),
                              itemBuilder: (context, index) => const Icon(
                                Icons.star_rate_rounded,
                                color: Colors.amber,
                                //color: colors.primary,
                              ),
                              unratedColor: Colors.grey.withOpacity(0.5),
                              itemCount: 5,
                              itemSize: 12.0,
                              direction: Axis.horizontal,
                              itemPadding: const EdgeInsets.all(0),
                            ),
                            Text(
                              " (" + model.noOfRating! + ")",
                              style: Theme.of(context).textTheme.overline,
                            )
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Text('${getPriceFormat(context, price)!} ',
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.fontColor,
                                  fontWeight: FontWeight.bold)),
                          double.parse(model.prVarientList![model.selVarient!]
                                      .disPrice!) !=
                                  0
                              ? Flexible(
                                  child: Row(
                                    children: <Widget>[
                                      Flexible(
                                        child: Text(
                                          double.parse(model
                                                      .prVarientList![
                                                          model.selVarient!]
                                                      .disPrice!) !=
                                                  0
                                              ? getPriceFormat(
                                                  context,
                                                  double.parse(model
                                                      .prVarientList![
                                                          model.selVarient!]
                                                      .price!))!
                                              : "",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .overline!
                                              .copyWith(
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                  letterSpacing: 0),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container()
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: model.prVarientList![model.selVarient!]
                                              .attr_name !=
                                          null &&
                                      model.prVarientList![model.selVarient!]
                                          .attr_name!.isNotEmpty
                                  ? ListView.builder(
                                      padding:
                                          const EdgeInsets.only(bottom: 5.0),
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount:
                                          att.length >= 2 ? 2 : att.length,
                                      itemBuilder: (context, index) {
                                        return Row(children: [
                                          Flexible(
                                            child: Text(
                                              att[index].trim() + ":",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption!
                                                  .copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .lightBlack),
                                            ),
                                          ),
                                          Flexible(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsetsDirectional
                                                      .only(start: 5.0),
                                              child: Text(
                                                val[index],
                                                maxLines: 1,
                                                overflow: TextOverflow.visible,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .caption!
                                                    .copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .lightBlack,
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                            ),
                                          )
                                        ]);
                                      })
                                  : Container(),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                            start: 5.0, bottom: 5),
                        child: Text(
                          model.name!,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.lightBlack),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Product model = widget.section_model!.productList![index];
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                          // transitionDuration: Duration(seconds: 1),
                          pageBuilder: (_, __, ___) => ProductDetail(
                                model: model,
                                secPos: widget.index,
                                index: index,
                                list: false,
                              )),
                    );
                  },
                ),
              );
            },
            selector: (_, provider) => Tuple2(provider.cartIdList,
                provider.qtyList(model.id!, model.prVarientList![0].id!)),
          ));
    } else {
      return Container();
    }
  }

  updateSectionList() {
    if (mounted) setState(() {});
  }

  Future<void> getSection(String top) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          PRODUCT_LIMIT: perPage.toString(),
          PRODUCT_OFFSET: widget.section_model!.productList!.length.toString(),
          SEC_ID: widget.section_model!.id,
          TOP_RETAED: top,
          PSORT: sortBy,
          PORDER: orderBy,
        };
        if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID;
        if (selId != null && selId != "") {
          parameter[ATTRIBUTE_VALUE_ID] = selId;
        }
        if (_currentRangeValues != null &&
            _currentRangeValues!.start.round().toString() != "0") {
          parameter[MINPRICE] = _currentRangeValues!.start.round().toString();
        }

        if (_currentRangeValues != null &&
            _currentRangeValues!.end.round().toString() != "0") {
          parameter[MAXPRICE] = _currentRangeValues!.end.round().toString();
        }

        print("parameter****getSection****$parameter");

        Response response =
            await post(getSectionApi, body: parameter, headers: headers)
                .timeout(const Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];

          minPrice = getdata[MINPRICE];
          maxPrice = getdata[MAXPRICE];
          _currentRangeValues =
              RangeValues(double.parse(minPrice), double.parse(maxPrice));

          offset = widget.section_model!.productList!.length;

          total = int.parse(data[0]["total"]);

          print("total sec******$total******$offset");

          if (offset! < total!) {
            List<SectionModel> temp = (data as List)
                .map((data) => SectionModel.fromJson(data))
                .toList();
            print("tempLIst *****${temp.length}");
            getAvailVarient(temp[0].productList!);

            offset = widget.section_model!.offset! + perPage;

            widget.section_model!.offset = offset;
            widget.section_model!.totalItem = total;
          }
        } else {
          isLoadingmore = false;
          if (msg != 'Sections not found') setSnackbar(msg!);
        }

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!);
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }

    return;
  }

  /* _setFav(int index) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (mounted)
          setState(() {
            index == -1
                ? model.isFavLoading = true
                : widget.section_model!.productList![index].isFavLoading = true;
          });

        var parameter = {USER_ID: CUR_USERID, PRODUCT_ID: model.id};
        Response response =
        await post(setFavoriteApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          index == -1 ? model.isFav = "1" : widget.section_model!.productList![index].isFav = "1";

          context.read<FavoriteProvider>().addFavItem(model);
        } else {
          setSnackbar(msg!);
        }

        if (mounted)
          setState(() {
            index == -1
                ? model.isFavLoading = false
                : widget.section_model!.productList![index].isFavLoading = false;
          });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!);
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  _removeFav(int index, Product model) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (mounted)
          setState(() {
            index == -1
                ? model.isFavLoading = true
                : widget.section_model!.productList![index].isFavLoading = true;
          });

        var parameter = {USER_ID: CUR_USERID, PRODUCT_ID: model.id};
        Response response =
        await post(removeFavApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          index == -1 ? model.isFav = "0" : widget.section_model!.productList![index].isFav = "0";
          context
              .read<FavoriteProvider>()
              .removeFavItem(model.prVarientList![0].id!);
        } else {
          setSnackbar(msg!);
        }

        if (mounted)
          setState(() {
            index == -1
                ? model.isFavLoading = false
                : widget.section_model!.productList![index].isFavLoading = false;
          });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!);
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }*/

  _setFav(int index) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (mounted) {
          setState(() {
            widget.section_model!.productList![index].isFavLoading = true;
          });
        }

        var parameter = {
          USER_ID: CUR_USERID,
          PRODUCT_ID: widget.section_model!.productList![index].id
        };
        Response response =
            await post(setFavoriteApi, body: parameter, headers: headers)
                .timeout(const Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          widget.section_model!.productList![index].isFav = "1";
          context
              .read<FavoriteProvider>()
              .addFavItem(widget.section_model!.productList![index]);
        } else {
          setSnackbar(msg!);
        }

        if (mounted) {
          setState(() {
            widget.section_model!.productList![index].isFavLoading = false;
          });
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!);
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
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

  _removeFav(int index) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (mounted) {
          setState(() {
            widget.section_model!.productList![index].isFavLoading = true;
          });
        }

        var parameter = {
          USER_ID: CUR_USERID,
          PRODUCT_ID: widget.section_model!.productList![index].id
        };
        Response response =
            await post(removeFavApi, body: parameter, headers: headers)
                .timeout(const Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          widget.section_model!.productList![index].isFav = "0";

          context.read<FavoriteProvider>().removeFavItem(
              widget.section_model!.productList![index].prVarientList![0].id!);
        } else {
          setSnackbar(msg!);
        }

        if (mounted) {
          setState(() {
            widget.section_model!.productList![index].isFavLoading = false;
          });
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!);
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }
}
