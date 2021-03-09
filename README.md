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

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  flutter_push_link: ^0.0.1
```

and

```sh
flutter pub get
```

---

## Running Project

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

<details>
  <summary>Click to expand! (main.dart)</summary>
  
  ## Example code application

```dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;

import 'package:flutter_push_link/flutter_push_link.dart';

void main() async {
  await DotEnv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

void onError(dynamic error) {
  debugPrint("onError Print: " + error);
  FlutterPushLink.toastMessage(error);
}

class _MyAppState extends State<MyApp> {
  String _deviceId = '';
  Map currentStrategy;
  bool pushLinkStaterd = false;
  String currentStrategySelected = 'CUSTOM';
  List<String> strategys = ['ANNOYING_POPUP', 'FRIENDLY_POPUP', 'STATUS_BAR', 'CUSTOM', 'NINJA'];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String deviceId = await FlutterPushLink.deviceId().catchError(onError);
    if (!mounted) return;
    getCurrentStrategy();
    setState(() => _deviceId = deviceId);
  }

  void getCurrentStrategy() async {
    currentStrategy = await FlutterPushLink.getCurrentStrategy().catchError(onError);
    setState(() => currentStrategy = currentStrategy);
  }

  void startPushLink() async {
    bool started = await FlutterPushLink.startPushLink(DotEnv.env['PUSH_LINK_API_KEY'], _deviceId).catchError(onError);
    setState(() => pushLinkStaterd = started);
  }

  void _reciverEventListenerCustom(data) {
    debugPrint("_reciverEventListener CUSTOM $data");
  }

  void selectStrategy() async {
    switch (currentStrategySelected) {
      case 'ANNOYING_POPUP':
        AnnoyingPopupProperties annoyingPopupProperties;
        annoyingPopupProperties.popUpMessage = 'Update PushLink Example';
        annoyingPopupProperties.updateButton = 'Update';
        await FlutterPushLink.setStrategyAnnoyingPoup(annoyingPopupProperties).catchError(onError);
        break;
      case 'FRIENDLY_POPUP':
        FriendlyePopupProperties friendlyePopupProperties;
        friendlyePopupProperties.notNowButton = 'Now';
        friendlyePopupProperties.popUpMessage = 'Update PushLink Example';
        friendlyePopupProperties.reminderTimeInSeconds = 60;
        friendlyePopupProperties.updateButton = 'Update';
        await FlutterPushLink.setStrategyFriendlyPopup(friendlyePopupProperties).catchError(onError);
        break;
      case 'STATUS_BAR':
        StatusBarProperties statusBarProperties;
        statusBarProperties.statusBarDescription = 'Click to Update, PushLink Example Flutter';
        statusBarProperties.statusBarTitle = 'New version Application Example Flutter';
        await FlutterPushLink.setStrategyStatusBar(statusBarProperties).catchError(onError);
        break;
      case 'CUSTOM':
        FlutterPushLink.toastMessage("CUSTOM requires the app to be DEVICE OWNER");
        await FlutterPushLink.setStrategyCustom(TypesBroadcastReceiver.APPLY, _reciverEventListenerCustom).catchError(onError);
        break;
      case 'NINJA':
        FlutterPushLink.toastMessage("NINJA only for ROOTED devices (DEPRECATED)");
        await FlutterPushLink.setStrategyNinja();
        break;
      default:
    }
    getCurrentStrategy();
  }

  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
    FlutterStatusbarcolor.setNavigationBarWhiteForeground(true);
    FlutterStatusbarcolor.setNavigationBarColor(HexColor('#3d9874'), animate: true);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: HexColor('#3d9874'),
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('PushLink Example'),
        ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            Container(
                margin: EdgeInsets.only(top: 30.0, bottom: 30),
                child: Image.network('https://pushlink.com/javax.faces.resource/images/site/logo-verde.png.xhtml?ln=pushlink',
                    width: 250, fit: BoxFit.contain)),
            Container(
              margin: EdgeInsets.only(bottom: 20),
              child: Center(
                child: Text(
                  'DeviceId: $_deviceId',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => {startPushLink()},
              child: Text('Start PushLink'),
              style: ElevatedButton.styleFrom(
                primary: Colors.red, // background
                onPrimary: Colors.white, // foreground
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 30),
              child: Text(
                'Current Strategy:',
                style: TextStyle(color: Colors.black.withOpacity(0.6), fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              child: Text(
                currentStrategy.toString(),
                style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 30),
              child: Text(
                'Select Strategy:',
                style: TextStyle(color: Colors.black.withOpacity(0.6), fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              child: DropdownButton<String>(
                value: currentStrategySelected,
                onChanged: (String newValue) {
                  setState(() {
                    currentStrategySelected = newValue;
                  });
                },
                items: strategys.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: () => {selectStrategy()},
              child: Text('Set Strategy'),
              style: ElevatedButton.styleFrom(
                primary: HexColor("#1fa6cb"), // background
                onPrimary: Colors.white, // foreground
              ),
            ),
          ],
        )),
      ),
    );
  }
}
```

</details>

---

## Troubleshooting

- Use `adb logcat | grep PUSHLINK` to check what's going on. If you can't solve the problem by yourself, please contact the support.

---

## Help & Support

Always feel free to drop a line to support at pushlink dot com or visit our [support](https://www.pushlink.com/support.xhtml).

Users are always welcome to contribute with [issues](https://github.com/diogo-bruno/flutter-push-link/issues) and [pull requests](https://github.com/diogo-bruno/flutter-push-link/pulls)
