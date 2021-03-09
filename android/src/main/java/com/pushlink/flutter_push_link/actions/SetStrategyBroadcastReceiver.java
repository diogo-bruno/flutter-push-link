package com.pushlink.flutter_push_link.actions;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.net.Uri;
import android.preference.PreferenceManager;
import android.util.Log;

import com.pushlink.flutter_push_link.FlutterPushLinkPlugin;

import org.json.JSONObject;

import io.flutter.plugin.common.MethodChannel.Result;

public class SetStrategyBroadcastReceiver {

    private final Context reactContext;
    private final Result callbackContext;
    private final Result resultThread;

    private TypeBroadcastReceiver typeBroadcastReceiver;

    public enum TypeBroadcastReceiver {
        APPLY,
        GIVEUP
    }

    private final BroadcastReceiver newVersionApkReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {

            try {

                Uri apkUri = (Uri) intent.getExtras().get("uri");
                int apkIcon = (int) intent.getExtras().get("icon");
                String apkHash = (String) intent.getExtras().get("hash");

                SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(reactContext);

                prefs.edit().putString("uri_apk", apkUri.toString()).apply();
                prefs.edit().putInt("icon_apk", apkIcon).apply();
                prefs.edit().putString("hash_apk", apkHash).apply();

                JSONObject params = new JSONObject();
                params.put("new_apk", apkUri.toString());
                params.put("iconId_apk", apkIcon);
                params.put("hash_apk", apkHash);

                FlutterPushLinkPlugin.eventsChannel.success(params);

            } catch (Exception e) {
                Log.e(FlutterPushLinkPlugin.TAG, "Exception: " + e.getMessage(), e);
                callbackContext.error("", e.getMessage(), "");
            }

        }
    };

    public SetStrategyBroadcastReceiver(Context reactContext, Result callbackContext, TypeBroadcastReceiver typeBroadcastReceiver, Result resultThread) {
        //super(reactContext);
        this.resultThread = resultThread;
        this.reactContext = reactContext;
        this.callbackContext = callbackContext;
        this.typeBroadcastReceiver = typeBroadcastReceiver;

        if (newVersionApkReceiver.isOrderedBroadcast())
            reactContext.unregisterReceiver(newVersionApkReceiver);

        registerBroadcastReceiver();
    }

    private void registerBroadcastReceiver() {
        if (typeBroadcastReceiver == null) typeBroadcastReceiver = TypeBroadcastReceiver.APPLY;

        String PUSHLINK_APPLY = "%s.pushlink.APPLY";
        String PUSHLINK_GIVEUP = "%s.pushlink.GIVEUP";

        String intent = typeBroadcastReceiver.equals(TypeBroadcastReceiver.GIVEUP) ? String.format(PUSHLINK_GIVEUP, reactContext.getPackageName()) : String.format(PUSHLINK_APPLY, reactContext.getPackageName());
        IntentFilter filter = new IntentFilter(intent);

        reactContext.registerReceiver(newVersionApkReceiver, filter);
    }

}
