package com.pushlink.flutter_push_link.actions;

import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.util.Log;

import com.pushlink.android.PushLink;
import com.pushlink.flutter_push_link.FlutterPushLinkPlugin;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;

public class StartAction implements PushLinkPluginAction {
    private static final String API_KEY = "apiKey";
    private static final String DEVICE_ID = "deviceId";
    private static final String ICON = "icon";

    private static final String RESOURCE_DRAWABLE = "drawable";
    private static final String RESOURCE_MIPMAP = "mipmap";

    @Override
    public void execute(final Activity activity, final Context context, MethodCall arg, final Result callbackContext, final Result resultThread) {

        try {

            final String apiKey = arg.argument(API_KEY).toString();

            final String deviceId = arg.argument(DEVICE_ID).toString();

            final String packageName = activity.getApplicationContext().getPackageName();

            int iconId = activity.getResources().getIdentifier(ICON, RESOURCE_DRAWABLE, packageName);

            if (iconId == 0) {
                iconId = activity.getResources().getIdentifier(ICON, RESOURCE_MIPMAP, packageName);
            }

            if (iconId == 0) {
                iconId = context.getResources().getIdentifier(ICON, RESOURCE_MIPMAP, packageName);
            }

            if (iconId == 0) {
                iconId = context.getApplicationInfo().icon;
            }

            if (iconId == 0) {
                iconId = context.getPackageManager().getApplicationInfo(packageName, PackageManager.GET_META_DATA).icon;
            }

            final int appIconId = iconId;

            activity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    try {
                        PushLink.start(activity, appIconId, apiKey, deviceId);
                        Log.i(FlutterPushLinkPlugin.TAG, "PushLink started");
                        callbackContext.success(true);
                    } catch (Exception e) {
                        callbackContext.error(null, e.getMessage(), null);
                    }
                }
            });

        } catch (Exception e) {

            callbackContext.error(null, e.getMessage(), null);

        }

    }
}