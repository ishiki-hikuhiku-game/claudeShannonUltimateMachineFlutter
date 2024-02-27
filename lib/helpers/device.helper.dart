import 'package:flutter/foundation.dart';
import 'dart:io';

String deviceType() {
  if (kIsWeb) {
    return "browser";
  }
  if (Platform.isAndroid) {
    return "mobile";
  }
  if (Platform.isIOS) {
    return "mobile";
  }
  if (Platform.isFuchsia) {
    return "mobile";
  }
  return "desktop";
}
