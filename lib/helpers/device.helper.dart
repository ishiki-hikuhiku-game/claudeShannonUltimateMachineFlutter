// dart:htmlをブラウザ以外でimportすることは推奨されないので、代わりのライブラリを使う。
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart';
// ブラウザでdart:ioの機能を呼び出すとエラーが発生するので、必ずその前にkIsWebで検査する。
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
  // Fuchsiaについてはよくわからない。
  return "desktop";
}

/// モバイルOSではアプリが自分を閉じるのは推奨されない。
void closeIfNotMobile() {
  if (kIsWeb) {
    // これで閉じない場合もある。
    html.window.close();
    return;
  }
  if (!Platform.isAndroid && !Platform.isIOS) {
    exit(0);
  }
}
