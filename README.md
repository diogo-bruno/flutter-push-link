<p align="center">
  <img src="https://pushlink.com/javax.faces.resource/images/site/logo-verde.png.xhtml?ln=pushlink" height='130' />
  </br>
  </br>
</p>

# `Flutter PushLink SDK`

[![pub package](https://img.shields.io/pub/v/flutter_push_link.svg)](https://pub.dartlang.org/packages/flutter_push_link) [![CircleCI Status](https://img.shields.io/circleci/build/github/diogo-bruno/flutter-push-link/master.svg)](https://circleci.com/gh/diogo-bruno/workflows/flutter-push-link/tree/master) ![Supports Android](https://img.shields.io/badge/platforms-android-lightgrey.svg)

## `Docs`

<https://docs.pushlink.com/>

---

## `Installation`

- Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  flutter_push_link: ^0.0.1
```

and

- Download dependencies

```sh
flutter pub get
```

and

- Create or Edit file .env api Key

```
PUSH_LINK_API_KEY=your-api-key
```

---

## `Running Project`

```sh
cd ./example && flutter run -d 'DeviceName or Id' -t lib/main.dart
```

## `Prepare Project Android Native`

```sh
flutter pub run flutter_push_link:prepare
```

## `Publish APK PushLink`

- Required .env [PUSH_LINK_API_KEY=your-api-key] in project root

```sh
flutter pub run flutter_push_link:publish.apk
```

## `Download APK PushLink`

- Required .env [PUSH_LINK_API_KEY=your-api-key] in project root

```sh
flutter pub run flutter_push_link:download.apk
```

---

## `Example project`

[Example Project Flutter - PushLink](https://github.com/diogo-bruno/flutter-push-link-example)

## `Usage`

```dart
import 'package:flutter_push_link/flutter_push_link.dart';

...

String deviceId = await FlutterPushLink.deviceId().catchError(onError);

bool started = await FlutterPushLink.startPushLink(DotEnv.env['PUSH_LINK_API_KEY'], deviceId).catchError(onError);

```

<a target="_blank" href="https://github.com/diogo-bruno/flutter-push-link/blob/master/example/lib/main.dart">Open file Application: <b>main.dart</b></a>

---

## Troubleshooting

- Use `adb logcat | grep PUSHLINK` to check what's going on. If you can't solve the problem by yourself, please contact the support.

---

## Help & Support

Always feel free to drop a line to support at pushlink dot com or visit our [support](https://www.pushlink.com/support.xhtml).

Users are always welcome to contribute with [issues](https://github.com/diogo-bruno/flutter-push-link/issues) and [pull requests](https://github.com/diogo-bruno/flutter-push-link/pulls)
