package com.pushlink.flutter_push_link.actions;

import android.app.Activity;
import android.content.Context;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;

public interface PushLinkPluginAction {
    void execute(Activity activity, Context context, MethodCall arg, Result callbackContext, Result resultThread) throws Exception;
}