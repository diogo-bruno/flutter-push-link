package com.pushlink.flutter_push_link.actions;

import android.app.Activity;
import android.content.Context;

import com.pushlink.android.PushLink;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;

public class HasPendingUpdateAction implements PushLinkPluginAction {
    @Override
    public void execute(Activity activity, Context context, MethodCall arg, Result callbackContext, Result resultThread) {
        Boolean hasPendingUpdate = PushLink.hasPengingUpdate();
        callbackContext.success(hasPendingUpdate);
    }
}