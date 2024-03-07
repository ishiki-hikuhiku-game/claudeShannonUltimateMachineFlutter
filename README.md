# shannons_ultimate_machine

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

### ブラウザ起動コマンド

CORS対応のためportを指定する必要あり

    flutter run -d chrome --web-port 55555

### ビルドコマンド


#### web

    flutter build web --web-renderer html

#### windows

    flutter build windows

#### android
`apk` ではなく `aab` を生成する。

    flutter build appbundle

`pubspec.yaml`の`version: 1.0.0+1`の`+1`の部分はビルドするたびにあげる必要がある。