
import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Model/Order_Model.dart';
import 'package:eshop/Model/Section_Model.dart';

import 'package:eshop/Screen/Review_Preview.dart';
import 'package:flutter/material.dart';

import 'Product_Detail.dart';

class ReviewGallary extends StatefulWidget {
  final Product? productModel;
  final OrderModel? orderModel;
  final List<dynamic>? imageList;

  const ReviewGallary(
      {Key? key, this.productModel, this.orderModel, this.imageList})
      : super(key: key);

  @override
  _ReviewImageState createState() => _ReviewImageState();
}

class _ReviewImageState extends State<ReviewGallary> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(getTranslated(context, 'REVIEW_BY_CUST')!, context),
      body: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          childAspectRatio: 1,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          padding: const EdgeInsets.all(20),
          children: List.generate(
            widget.productModel != null
                ? revImgList.length
                : widget.imageList!.length,
            (index) {
              return InkWell(
                child: FadeInImage(
                  image: NetworkImage(widget.productModel != null
                      ? revImgList[index].img!
                      : widget.imageList![index]),
                  imageErrorBuilder: (context, error, stackTrace) =>
                      erroWidget(double.maxFinite),
                  placeholder: const AssetImage(
                    "assets/images/sliderph.png",
                  ),
                  fit: BoxFit.cover,
                ),
                onTap: () {
                  if (widget.productModel != null) {
                    Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder: (_, __, ___) => ReviewPreview(
                                  index: index,
                                  productModel: widget.productModel,
                                )));
                  }else{
                    Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder: (_, __, ___) => ReviewPreview(
                              index: index,
                              imageList: widget.imageList,
                            )));
                  }
                },
              );
            },
          )),
    );
  }
}
