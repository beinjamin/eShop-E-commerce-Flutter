import 'package:eshop/Model/Section_Model.dart';
import 'package:flutter/cupertino.dart';

class ProductDetailProvider extends ChangeNotifier {
  bool _reviewLoading = true;
  bool _moreProductLoading = true;
  int _offset = 0;
  int _total = 0;
  bool _moreProNotiLoading = true;
  bool _notificationisgettingdata1 = false;
  bool _notificationisnodata1 = false;

  List<Product> _compareList = [];
  List<Product> _productList = [];

  get compareList => _compareList;

  get productList => _productList;

  get moreProNotiLoading => _moreProNotiLoading;

  get offset => _offset;

  get total => _total;

  get moreProductLoading => _moreProductLoading;

  get reviewLoading => _reviewLoading;

  get notificationisgettingdata1 => _notificationisgettingdata1;

  get notificationisnodata1 => _notificationisnodata1;

  setReviewLoading(bool loading) {
    _moreProductLoading = loading;
    notifyListeners();
  }

  setProductLoading(bool loading) {
    _moreProductLoading = loading;
    notifyListeners();
  }

  setProNotiLoading(bool loading) {
    _moreProNotiLoading = loading;
    notifyListeners();
  }

  setProGetData(bool loading) {
    _moreProductLoading = loading;
    notifyListeners();
  }

  setProOffset(int offset) {
    _offset = offset;
    notifyListeners();
  }

  setProTotal(int total) {
    _total = total;
    notifyListeners();
  }

  addComFirstIndex(Product compareList) {
    _compareList.insert(0, compareList);
    notifyListeners();
  }

  addCompareList(Product compareList) {
    _compareList.add(compareList);
    notifyListeners();
  }

  removeCompareList() {
    _compareList.clear();
    _productList.clear();
    print("_compare len*****${_compareList.length}");
    notifyListeners();
  }

  setProductList(List<Product>? productList) {
    _productList = productList!;
    notifyListeners();
  }
}
