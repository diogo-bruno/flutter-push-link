package com.pushlink.flutter_push_link.actions;

import android.app.PendingIntent;
import android.app.admin.DevicePolicyManager;
import android.content.Context;
import android.content.Intent;
import android.content.IntentSender;
import android.content.SharedPreferences;
import android.content.pm.PackageInstaller;
import android.net.Uri;
import android.os.Build;
import android.preference.PreferenceManager;
import android.util.Log;

import com.pushlink.flutter_push_link.FlutterPushLinkPlugin;

import io.flutter.plugin.common.MethodChannel.Result;

import org.json.JSONObject;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.OutputStream;

public class Utils {

    public Boolean installAPK(Context context, Uri apkUri, Result callbackContext, Result resultThread) {

        boolean success = true;

        try {

            if (Build.VERSION.SDK_INT >= 21) {

                InputStream in = new FileInputStream(new File(context.getFilesDir(), apkUri.getPath()));

                PackageInstaller packageInstaller = context.getPackageManager().getPackageInstaller();

                PackageInstaller.SessionParams params = new PackageInstaller.SessionParams(
                        PackageInstaller.SessionParams.MODE_FULL_INSTALL);

                params.setAppPackageName(context.getPackageName());

                // set params
                int sessionId = packageInstaller.createSession(params);

                PackageInstaller.Session session = packageInstaller.openSession(sessionId);

                OutputStream out = session.openWrite("COSU", 0, -1);

                byte[] buffer = new byte[65536];

                int c;

                while ((c = in.read(buffer)) != -1) {
                    out.write(buffer, 0, c);
                }

                session.fsync(out);
                in.close();
                out.close();

                //PendingIntent pendingIntent = PendingIntent.getBroadcast(context, sessionId, new Intent("dummy.intent.not.used"), 0);
                //session.commit(pendingIntent.getIntentSender());

                session.commit(createIntentSender(context, sessionId));

            } else {
                success = false;
                callbackContext.error("", "Device Owner not enabled. Strategy CUSTOM required Device Owner!", "");
            }

        } catch (Exception e) {
            success = false;
            Log.e(FlutterPushLinkPlugin.TAG, "Exception InstallAPK: " + e.getMessage());
            callbackContext.error("", "Error installAPK: " + e.getMessage(), "");
        }

        return success;

    }

    private static IntentSender createIntentSender(Context context, int sessionId) {
        PendingIntent pendingIntent = PendingIntent.getBroadcast(
                context,
                sessionId,
                new Intent(context.getPackageName() + ".INSTALL_COMPLETE"),
                0);
        return pendingIntent.getIntentSender();
    }

    public Boolean isDeviceOwner(Context context) {
        boolean result = false;
        if (Build.VERSION.SDK_INT >= 18) {

            try {
                DevicePolicyManager mDPM = (DevicePolicyManager) context.getSystemService(Context.DEVICE_POLICY_SERVICE);
                if (mDPM != null) {
                    result = mDPM.isDeviceOwnerApp(context.getPackageName());
                }
            } catch (Throwable t) {
                Log.e(FlutterPushLinkPlugin.TAG, "Throwable isDeviceOwner:", t);
            }

        }
        return result;
    }

//    public String returnErrorInvoke(String error) {
//        JSONObject returnValue = new JSONObject();
//        try {
//            returnValue.put("error", error);
//        } catch (Exception e) {
//            Log.e(FlutterPushLinkPlugin.TAG, "PUSHLINK returnErrorInvoke", e);
//        }
//        return returnValue.toString();
//    }

    public static void resetCacheLastUriDownloadApk(Context context) {
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(context);
        prefs.edit().putString("uri_apk", "").apply();
        prefs.edit().putInt("icon_apk", 0).apply();
        prefs.edit().putString("hash_apk", "").apply();
    }

    public static void setMsgUpdateApk(Context context, String msg) {
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(context);
        prefs.edit().putString("msg_update_apk", msg).apply();
    }

}
