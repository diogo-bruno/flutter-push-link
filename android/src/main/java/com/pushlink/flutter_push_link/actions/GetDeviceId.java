package com.pushlink.flutter_push_link.actions;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.provider.Settings;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;


import static android.provider.Settings.Secure.getString;

public class GetDeviceId implements PushLinkPluginAction {

    @Override
    public void execute(Activity activity, Context context, MethodCall arg, Result callbackContext, Result resultThread) {
        @SuppressLint("HardwareIds") String yourDeviceID = getString(context.getContentResolver(), Settings.Secure.ANDROID_ID);
        callbackContext.success(yourDeviceID);
    }
}