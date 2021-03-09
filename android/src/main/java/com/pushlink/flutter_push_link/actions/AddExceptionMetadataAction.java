package com.pushlink.flutter_push_link.actions;

import android.app.Activity;
import android.content.Context;

import com.pushlink.android.PushLink;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;

public class AddExceptionMetadataAction implements PushLinkPluginAction {
    private static final String KEY = "key";
    private static final String VALUE = "value";

    @Override
    public void execute(Activity activity, Context context, MethodCall arg, Result callbackContext, Result resultThread) {
        PushLink.addExceptionMetadata(arg.argument(KEY).toString(), arg.argument(VALUE).toString());
        callbackContext.success(true);
    }
}