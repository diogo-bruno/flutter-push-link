package com.pushlink.flutter_push_link.actions;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

import com.pushlink.android.PushLink;
import com.pushlink.flutter_push_link.FlutterPushLinkPlugin;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;

public class SetCurrentActivityAction implements PushLinkPluginAction {

    @Override
    public void execute(Activity activity, Context context, MethodCall arg, Result callbackContext, Result resultThread) {
        Log.i(FlutterPushLinkPlugin.TAG, "Setting PushLink currentActivity after resume");
        PushLink.setCurrentActivity(activity);
        callbackContext.success(true);
    }
}