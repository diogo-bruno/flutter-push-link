import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

enum TypesBroadcastReceiver { APPLY, GIVEUP }

abstract class AnnoyingPopupProperties {
  String popUpMessage;
  String updateButton;
}

abstract class FriendlyePopupProperties {
  int reminderTimeInSeconds;
  String popUpMessage;
  String updateButton;
  String notNowButton;
}

abstract class StatusBarProperties {
  String statusBarTitle;
  String statusBarDescription;
}

class FlutterPushLink {
  static const MethodChannel _channel = const MethodChannel('flutter_push_link');

  static const streamStrategyCustom = const EventChannel('com.pushlink.eventchannel/strategyCustom');

  static StreamSubscription _newApkInstallEventSubscription;

  static bool pushLinkStarted = false;

  static String msgNotStarted = "PushLink not started...";

  static void enableEventListenerCustom(Function _updateTimer) {
    if (_newApkInstallEventSubscription == null) {
      _newApkInstallEventSubscription = streamStrategyCustom.receiveBroadcastStream().listen(_updateTimer);
    }
  }

  static void disableEventListenerCustom() {
    if (_newApkInstallEventSubscription != null) {
      _newApkInstallEventSubscription.cancel();
      _newApkInstallEventSubscription = null;
    }
  }

  static Future<String> get platformVersion async {
    try {
      return await _channel.invokeMethod('getPlatformVersion');
    } on PlatformException catch (error) {
      throw error.message;
    }
  }

  static Future<String> deviceId() async {
    try {
      final String deviceId = await _channel.invokeMethod('getDeviceId');
      return deviceId;
    } on PlatformException catch (error) {
      throw error.message;
    }
  }

  static Future<bool> startPushLink(String apiKey, String deviceId) async {
    try {
      final bool started = await _channel.invokeMethod('start', {"apiKey": apiKey, "deviceId": deviceId});
      pushLinkStarted = started;
      return started;
    } on PlatformException catch (error) {
      throw error.message;
    }
  }

//addMetadata (key, value)
  static Future<bool> addMetadata(String key, String value) async {
    if (!pushLinkStarted) throw msgNotStarted;
    try {
      final bool ok = await _channel.invokeMethod('addMetadata', {"key": key, "value": value});
      return ok;
    } on PlatformException catch (error) {
      throw error.message;
    }
  }

//addExceptionMetadata (key, value)
  static Future<bool> addExceptionMetadata(String key, String value) async {
    if (!pushLinkStarted) throw msgNotStarted;
    try {
      final bool ok = await _channel.invokeMethod('addExceptionMetadata', {"key": key, "value": value});
      return ok;
    } on PlatformException catch (error) {
      throw error.message;
    }
  }

//sendExceptionFlutter  (error)
  static Future<bool> sendExceptionFlutter(String error) async {
    if (!pushLinkStarted) throw msgNotStarted;
    try {
      final bool ok = await _channel.invokeMethod('sendExceptionFlutter', {"error": error});
      return ok;
    } on PlatformException catch (error) {
      throw error.message;
    }
  }

//enableExceptionNotification
  static Future<bool> enableExceptionNotification() async {
    if (!pushLinkStarted) throw msgNotStarted;
    try {
      final bool ok = await _channel.invokeMethod('enableExceptionNotification');
      return ok;
    } on PlatformException catch (error) {
      throw error.message;
    }
  }

//disableExceptionNotification
  static Future<bool> disableExceptionNotification() async {
    if (!pushLinkStarted) throw msgNotStarted;
    try {
      final bool ok = await _channel.invokeMethod('disableExceptionNotification');
      return ok;
    } on PlatformException catch (error) {
      throw error.message;
    }
  }

//setStrategyAnnoyingPoup
  static Future<bool> setStrategyAnnoyingPoup(AnnoyingPopupProperties properties) async {
    if (!pushLinkStarted) throw msgNotStarted;
    try {
      final bool ok = await _channel.invokeMethod('setCurrentStrategy', {
        'strategy': 'ANNOYING_POPUP',
        'properties': properties,
      });
      return ok;
    } on PlatformException catch (error) {
      throw error.message;
    }
  }

//setStrategyFriendlyPopup
  static Future<bool> setStrategyFriendlyPopup(FriendlyePopupProperties properties) async {
    if (!pushLinkStarted) throw msgNotStarted;
    try {
      final bool ok = await _channel.invokeMethod('setCurrentStrategy', {
        'strategy': 'FRIENDLY_POPUP',
        'properties': properties,
      });
      return ok;
    } on PlatformException catch (error) {
      throw error.message;
    }
  }

//setStrategyCustom
  static Future<bool> setStrategyCustom(TypesBroadcastReceiver typeBroadcastReceiver, Function eventListener) async {
    if (!pushLinkStarted) throw msgNotStarted;
    try {
      final bool ok = await _channel.invokeMethod('setCurrentStrategy', {
        'strategy': 'CUSTOM',
        'properties': {'TypeBroadcastReceiver': typeBroadcastReceiver},
      });
      enableEventListenerCustom(eventListener);
      return ok;
    } on PlatformException catch (error) {
      throw error.message;
    }
  }

//setStrategyStatusBar
  static Future<bool> setStrategyStatusBar(StatusBarProperties properties) async {
    if (!pushLinkStarted) throw msgNotStarted;
    try {
      final bool ok = await _channel.invokeMethod('setCurrentStrategy', {
        'strategy': 'STATUS_BAR',
        'properties': properties,
      });
      return ok;
    } on PlatformException catch (error) {
      throw error.message;
    }
  }

//setStrategyNinja
  static Future<bool> setStrategyNinja() async {
    if (!pushLinkStarted) throw msgNotStarted;
    try {
      final bool ok = await _channel.invokeMethod('setCurrentStrategy', {
        'strategy': 'NINJA',
        'properties': null,
      });
      return ok;
    } on PlatformException catch (error) {
      throw error.message;
    }
  }

//getCurrentStrategy
  static Future<Map> getCurrentStrategy() async {
    try {
      final String strategy = await _channel.invokeMethod('getCurrentStrategy');
      return jsonDecode(strategy);
    } on PlatformException catch (error) {
      throw error.message;
    }
  }

//hasPendingUpdate
  static Future<bool> hasPendingUpdate() async {
    if (!pushLinkStarted) throw msgNotStarted;
    try {
      final bool ok = await _channel.invokeMethod('hasPendingUpdate');
      return ok;
    } on PlatformException catch (error) {
      throw error.message;
    }
  }

//idle
  static Future<bool> idle(bool isIdle) async {
    if (!pushLinkStarted) throw msgNotStarted;
    try {
      final bool ok = await _channel.invokeMethod('idle', {'idle': isIdle});
      return ok;
    } on PlatformException catch (error) {
      throw error.message;
    }
  }

//getVersion
  static Future<String> getVersionPlugin() async {
    try {
      final String version = await _channel.invokeMethod('version');
      return version;
    } on PlatformException catch (error) {
      throw error.message;
    }
  }

//installApk
  static Future<bool> installApk() async {
    if (!pushLinkStarted) throw msgNotStarted;
    try {
      final bool ok = await _channel.invokeMethod('installApk');
      return ok;
    } on PlatformException catch (error) {
      throw error.message;
    }
  }

//setMsgUpdateApk
  static Future<bool> setMsgUpdateApk(String message) async {
    try {
      final bool ok = await _channel.invokeMethod('set_msg_update_apk', {'message': message});
      return ok;
    } on PlatformException catch (error) {
      throw error.message;
    }
  }

  //setMsgUpdateApk
  static void toastMessage(String message) async {
    try {
      _channel.invokeMethod('toast', {'message': message});
    } on PlatformException catch (error) {
      throw error.message;
    }
  }
}
