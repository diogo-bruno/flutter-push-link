package com.pushlink.flutter_push_link.actions;

import android.app.Activity;
import android.content.Context;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;

import com.pushlink.android.PushLink;

public class SendAsyncExceptionFlutter implements PushLinkPluginAction {

    public static class FlutterException extends Exception {
        public FlutterException(String message) {
            super(message);
        }
    }

    @Override
    public void execute(Activity activity, Context context, MethodCall arg, Result callbackContext, Result resultThread) {
        String error = arg.argument("error").toString();
        FlutterException t = new FlutterException(error);
        PushLink.sendAsyncException(t);
        callbackContext.success(true);
    }
}