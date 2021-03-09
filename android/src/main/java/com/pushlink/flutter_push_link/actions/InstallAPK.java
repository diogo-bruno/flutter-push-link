package com.pushlink.flutter_push_link.actions;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.net.Uri;
import android.preference.PreferenceManager;
import android.util.Log;
import android.widget.Toast;

import com.pushlink.flutter_push_link.FlutterPushLinkPlugin;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;


public class InstallAPK implements PushLinkPluginAction {

    @Override
    public void execute(Activity activity, Context context, MethodCall arg, Result callbackContext, Result resultThread) {

        Utils utils = new Utils();

        if (!utils.isDeviceOwner(context)) {

            callbackContext.error("", "Device Owner not enabled. Install APK required Device Owner!", "");

        } else {

            SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(context);

            Uri uriApk = Uri.parse(prefs.getString("uri_apk", ""));

            Log.e(FlutterPushLinkPlugin.TAG, "URI Apk Install: " + uriApk.toString());

            if (uriApk == null || uriApk.toString().equals("")) {

                callbackContext.error("", "No apk file for installation!", "");

            } else {
                Toast.makeText(context, "Installation APK started...", Toast.LENGTH_SHORT).show();

                Boolean success = utils.installAPK(context, uriApk, callbackContext, resultThread);

                if (success) {
                    Utils.resetCacheLastUriDownloadApk(context);
                    callbackContext.success(true);
                }

            }

        }


    }
}