package com.pushlink.flutter_push_link_example;

import android.app.admin.DeviceAdminReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Handler;
import android.preference.PreferenceManager;
import android.util.Log;
import android.widget.Toast;

public class PushlinkAdminReceiver extends DeviceAdminReceiver {

    SharedPreferences prefs;

    @Override
    public void onReceive(Context context, Intent intent) {
        super.onReceive(context, intent);

        if (intent.getAction().equals(Intent.ACTION_MY_PACKAGE_REPLACED)) {

            Log.i("PUSHLINK", "MY_PACKAGE_REPLACED called");

            prefs = PreferenceManager.getDefaultSharedPreferences(context);

            String msgUpdateApk = prefs.getString("msg_update_apk", "");

            if (msgUpdateApk != null && !msgUpdateApk.equals("")) {
                Toast.makeText(context, msgUpdateApk, Toast.LENGTH_SHORT).show();
            }

            try {

                new Handler().postDelayed(new Runnable() {
                    public void run() {
                        Intent i = context.getPackageManager().getLaunchIntentForPackage(context.getPackageName());
                        i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS);
                        context.startActivity(i);
                        Log.i("PUSHLINK", "MY_PACKAGE_REPLACED startActivity initialized");
                    }
                }, 600);

            } catch (Exception ex) {

                Log.e("PUSHLINK", "Exception ACTION_MY_PACKAGE_REPLACED onReceive ", ex);

            }

        } else {

            Log.i("PUSHLINK", "DEVICE_ADMIN_ENABLED called");

        }

    }

}
