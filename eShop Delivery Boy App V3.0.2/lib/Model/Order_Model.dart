import 'package:deliveryboy/Helper/String.dart';
import 'package:intl/intl.dart';

class Order_Model {
  String? id,
      name,
      mobile,
      latitude,
      longitude,
      delCharge,
      walBal,
      promo,
      promoDis,
      payMethod,
      total,
      subTotal,
      payable,
      address,
      taxAmt,
      taxPer,
      orderDate,
      dateTime,
      isCancleable,
      isReturnable,
      isAlrCancelled,
      isAlrReturned,
      rtnReqSubmitted,
      activeStatus,
      otp,
      deliveryBoyId,
      invoice,
      delDate,
      delTime,
      cname,
      type,
      cdate,
      amount,
      cashReceived,
      message;

  List<OrderItem>? itemList = [];
  List<String?>? listStatus = [];
  List<String?>? listDate = [];


  Order_Model(
      {this.id,
      this.name,
      this.mobile,
      this.delCharge,
      this.walBal,
      this.promo,
      this.promoDis,
      this.payMethod,
      this.total,
      this.subTotal,
      this.payable,
      this.address,
      this.taxPer,
      this.taxAmt,
      this.orderDate,
      this.dateTime,
      this.itemList,
      this.listStatus,
      this.listDate,
      this.isReturnable,
      this.isCancleable,
      this.isAlrCancelled,
      this.isAlrReturned,
      this.rtnReqSubmitted,
      this.activeStatus,
      this.otp,
      this.invoice,
      this.latitude,
      this.longitude,
      this.delDate,
      this.delTime,
      this.deliveryBoyId,
      this.cname,
      this.type,
      this.cdate,
      this.amount,
      this.cashReceived,
      this.message,
      });

  factory Order_Model.fromJson(Map<String, dynamic> parsedJson) {
    List<OrderItem> itemList = [];
     var order = parsedJson[ORDER_ITEMS] == null ?
    [] : parsedJson[ORDER_ITEMS] as List;
    if (order.isEmpty ) {
      order = [];
    } else {
      itemList = order.map((data) => OrderItem.fromJson(data)).toList();
    }
    String date = parsedJson[DATE_ADDED] ?? "";

    date = date.isNotEmpty ?  DateFormat('dd-MM-yyyy').format(DateTime.parse(date)) : date;
    List<String?> lStatus = [];
    List<String?> lDate = [];

    var allSttus = parsedJson[STATUS] ?? [];
    for (var curStatus in allSttus) {
      lStatus.add(curStatus[0]);
      lDate.add(curStatus[1]);
    }


    return Order_Model(
        id: parsedJson[ID] ?? "",
        name: parsedJson[USERNAME] ?? "",
        mobile: parsedJson[MOBILE] ?? "",
        delCharge: parsedJson[DEL_CHARGE] ?? "",
        walBal: parsedJson[WAL_BAL]?? "",
        promo: parsedJson[PROMOCODE]?? "",
        promoDis: parsedJson[PROMO_DIS]?? "",
        payMethod: parsedJson[PAYMENT_METHOD]?? "",
        total: parsedJson[FINAL_TOTAL]?? "",
        subTotal: parsedJson[TOTAL]?? "",
        payable: parsedJson[TOTAL_PAYABLE]?? "",
        address: parsedJson[ADDRESS]?? "",
        taxAmt: parsedJson[TOTAL_TAX_AMT]?? "",
        taxPer: parsedJson[TOTAL_TAX_PER]?? "",
        dateTime: parsedJson[DATE_ADDED]?? "",
        isCancleable: parsedJson[ISCANCLEABLE]?? "",
        isReturnable: parsedJson[ISRETURNABLE]?? "",
        isAlrCancelled: parsedJson[ISALRCANCLE]?? "",
        isAlrReturned: parsedJson[ISALRRETURN]?? "",
        rtnReqSubmitted: parsedJson[ISRTNREQSUBMITTED]?? "",
        orderDate: date,
        itemList: itemList ,
        listStatus: lStatus,
        listDate: lDate,
        activeStatus: parsedJson[ACTIVE_STATUS] ?? "",
        otp: parsedJson[OTP]?? "",
        latitude: parsedJson[LATITUDE]?? "",
        longitude: parsedJson[LONGITUDE]?? "",
        delDate: parsedJson[DEL_DATE] ??"",
        delTime: parsedJson[DEL_TIME] != "" ? parsedJson[DEL_TIME] : '',
        deliveryBoyId: parsedJson[DELIVERY_BOY_ID]?? "",
        cname: parsedJson[NAME]?? "",
        type: parsedJson[TYPE]?? "",
        cdate: parsedJson[DATE_DEL]?? "",
        amount: parsedJson[AMOUNT]?? "",
        cashReceived: parsedJson[CASH_RECEIVED]?? "",
        message: parsedJson[MESSAGE]?? "",
        );
  }
}

class OrderItem {
  String? id,
      name,
      qty,
      price,
      subTotal,
      status,
      image,
      varientId,
      isCancle,
      isReturn,
      isAlrCancelled,
      isAlrReturned,
      rtnReqSubmitted,
      varient_values,
      attr_name,
      productId,
      curSelected;

  List<String?>? listStatus = [];
  List<String?>? listDate = [];

  OrderItem(
      {this.qty,
      this.id,
      this.name,
      this.price,
      this.subTotal,
      this.status,
      this.image,
      this.varientId,
      this.listDate,
      this.listStatus,
      this.isCancle,
      this.isReturn,
      this.isAlrReturned,
      this.isAlrCancelled,
      this.rtnReqSubmitted,
      this.attr_name,
      this.productId,
      this.varient_values,
      this.curSelected});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    List<String?> lStatus = [];
    List<String?> lDate = [];

    var allSttus = json[STATUS];
    for (var curStatus in allSttus) {
      lStatus.add(curStatus[0]);
      lDate.add(curStatus[1]);
    }
    return OrderItem(
      id: json[ID] ?? "",
      qty: json[QUANTITY]?? "",
      name: json[NAME]?? "",
      image: json[IMAGE]?? "",
      price: json[PRICE]?? "",
      subTotal: json[SUB_TOTAL]?? "",
      varientId: json[PRODUCT_VARIENT_ID]?? "",
      listStatus: lStatus,
      status: json[ACTIVE_STATUS],
      curSelected: json[ACTIVE_STATUS],
      listDate: lDate,
      isCancle: json[ISCANCLEABLE]?? "",
      isReturn: json[ISRETURNABLE]?? "",
      isAlrCancelled: json[ISALRCANCLE]?? "",
      isAlrReturned: json[ISALRRETURN]?? "",
      rtnReqSubmitted: json[ISRTNREQSUBMITTED]?? "",
      attr_name: json[ATTR_NAME]?? "",
      productId: json[PRODUCT_ID]?? "",
      varient_values: json[VARIENT_VALUE]?? "",
    );
  }
}


