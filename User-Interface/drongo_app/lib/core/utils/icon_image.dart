import 'package:flutter/widgets.dart';

abstract final class IconImages {
  IconImages._();
  static const String iconPath = 'assets/images';

  static const _kFontFam = 'MyFlutterApp.ttf';
  static const String? _kFontPkg = null;

  static const IconData iconBirdHouseUnselected =
      IconData(0xe800, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData iconBirdHouseSelected =
      IconData(0xe801, fontFamily: _kFontFam, fontPackage: _kFontPkg);

  static String iconDrongosLogo = '$iconPath/img-full-drongos-logo.svg';
  static String iconZeroScale = '$iconPath/img-zero-scale.svg';
  static String iconTrackUnselected = '$iconPath/img-track-unselected.svg';
  static String iconTrackSelected = '$iconPath/img-track-selected.svg';
  static String iconTempUnselected = '$iconPath/img-temperature-unselected.svg';
  static String iconTempSelected = '$iconPath/img-temperature-selected.svg';
  static String iconScaleUnselected = '$iconPath/img-scale-unselected.svg';
  static String iconScaleSelected = '$iconPath/img-scale-selected.svg';
  static String iconRFID = '$iconPath/img-rfid.svg';
  static String iconHomeUnselected = '$iconPath/img-home-unselected.svg';
  static String iconHomeSelected = '$iconPath/img-home-selected.svg';
  static String iconESP32 = '$iconPath/img-esp32-connected.svg';
  static String iconDataUnselected = '$iconPath/img-data-unselected.svg';
  static String iconDataSelected = '$iconPath/img-data-selected.svg';
  static String iconAboutApp = '$iconPath/img-about.svg';
}
