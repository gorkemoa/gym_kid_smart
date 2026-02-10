import 'package:flutter/widgets.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static double screenWidth = refWidth;
  static double screenHeight = refHeight;
  static double _blockSizeHorizontal = refWidth / 100;
  static double _blockSizeVertical = refHeight / 100;

  static double _safeAreaHorizontal = 0;
  static double _safeAreaVertical = 0;
  static double safeBlockHorizontal = refWidth / 100;
  static double safeBlockVertical = refHeight / 100;

  // Reference design size (iPhone 13)
  static const double refWidth = 390.0;
  static const double refHeight = 844.0;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);

    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;

    double cappedWidth = screenWidth > refWidth ? refWidth : screenWidth;
    double cappedHeight = screenHeight > refHeight ? refHeight : screenHeight;

    _blockSizeHorizontal = cappedWidth / 100;
    _blockSizeVertical = cappedHeight / 100;

    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;

    safeBlockHorizontal = (cappedWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (cappedHeight - _safeAreaVertical) / 100;
  }

  static double get h => _blockSizeHorizontal;
  static double get v => _blockSizeVertical;
}

extension SizeExtension on num {
  double get w => this * SizeConfig.h;
  double get h => this * SizeConfig.v;
  double get sp => this * SizeConfig.h;
  double get r => this * SizeConfig.h;
}
