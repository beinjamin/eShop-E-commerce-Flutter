import 'package:flutter/material.dart';

class HomeProvider extends ChangeNotifier {
  int _curSlider = 0;
  bool _catLoading = true;
  bool _secLoading = true;
  bool _sliderLoading = true;
  bool _offerLoading = true;
  //bool _isScrollingDown = false;
  bool _showBars = true;
  late AnimationController _animationController;



 // get checkIsScrollingDown => _isScrollingDown;
  get getBars => _showBars;
  get catLoading => _catLoading;

  get curSlider => _curSlider;

  get secLoading => _secLoading;

  get sliderLoading => _sliderLoading;

  get offerLoading => _offerLoading;

  AnimationController get animationController => _animationController;


  showBars(bool value){
    _showBars = value;
    notifyListeners();
  }

 /* isScrollingDown (bool value){
    _isScrollingDown = value;
    notifyListeners();
  }*/

  void setAnimationController(AnimationController animationController) {
    _animationController = animationController;
    notifyListeners();
  }

  setCurSlider(int pos) {

    _curSlider = pos;
    notifyListeners();
  }


  setOfferLoading(bool loading) {
    _offerLoading = loading;
    notifyListeners();
  }

  setSliderLoading(bool loading) {
    _sliderLoading = loading;
    notifyListeners();
  }

  setSecLoading(bool loaidng) {
    _secLoading = loaidng;
    notifyListeners();
  }


  setCatLoading(bool loading) {
    _catLoading = loading;
    notifyListeners();
  }
}
