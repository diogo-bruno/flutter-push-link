package com.pushlink.flutter_push_link;

import android.app.Activity;
import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;

import com.pushlink.flutter_push_link.actions.AddExceptionMetadataAction;
import com.pushlink.flutter_push_link.actions.AddMetadataAction;
import com.pushlink.flutter_push_link.actions.DisableExceptionNotificationAction;
import com.pushlink.flutter_push_link.actions.EnableExceptionNotificationAction;
import com.pushlink.flutter_push_link.actions.GetCurrentStrategyAction;
import com.pushlink.flutter_push_link.actions.GetDeviceId;
import com.pushlink.flutter_push_link.actions.HasPendingUpdateAction;
import com.pushlink.flutter_push_link.actions.InstallAPK;
import com.pushlink.flutter_push_link.actions.PushLinkPluginAction;
import com.pushlink.flutter_push_link.actions.SendAsyncExceptionFlutter;
import com.pushlink.flutter_push_link.actions.SetCurrentActivityAction;
import com.pushlink.flutter_push_link.actions.SetCurrentStrategyAction;
import com.pushlink.flutter_push_link.actions.SetIdleAction;
import com.pushlink.flutter_push_link.actions.StartAction;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import io.reactivex.rxjava3.android.schedulers.AndroidSchedulers;
import io.reactivex.rxjava3.core.Observable;
import io.reactivex.rxjava3.disposables.Disposable;
import io.reactivex.rxjava3.functions.Action;
import io.reactivex.rxjava3.functions.Consumer;

/**
 * FlutterPushLinkPlugin
 */
public class FlutterPushLinkPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {

    private Disposable timerSubscription;
    private MethodChannel channel;

    private Context context;
    private Activity activity;

    private Toast mToast;

    public static EventChannel.EventSink eventsChannel;
    public static final String STREAM = "com.pushlink.eventchannel/strategyCustom";

    public static final String TAG = "PushLinkPlugin";

    public static final String START_ACTION = "start";
    public static final String ADD_EXCEPTION_METADATA = "addExceptionMetadata";
    public static final String ADD_METADATA = "addMetadata";
    public static final String DISABLE_EXCEPTION_NOTIFICATION = "disableExceptionNotification";
    public static final String ENABLE_EXCEPTION_NOTIFICATION = "enableExceptionNotification";
    public static final String SET_CURRENT_STRATEGY = "setCurrentStrategy";
    public static final String GET_CURRENT_STRATEGY = "getCurrentStrategy";
    public static final String SET_CURRENT_ACTIVITY = "setCurrentActivity";
    public static final String HAS_PENDING_UPDATE = "hasPendingUpdate";
    public static final String SET_IDLE = "idle";
    public static final String GET_DEVICE_ID = "getDeviceId";
    public static final String INSTALL_APK = "installApk";
    public static final String SEND_EXCEPTION_FLUTTER = "sendExceptionFlutter";

    private static final Map<String, PushLinkPluginAction> actions;

    static {
        actions = new HashMap<>();
        actions.put(START_ACTION, new StartAction());
        actions.put(ADD_EXCEPTION_METADATA, new AddExceptionMetadataAction());
        actions.put(ADD_METADATA, new AddMetadataAction());
        actions.put(DISABLE_EXCEPTION_NOTIFICATION, new DisableExceptionNotificationAction());
        actions.put(ENABLE_EXCEPTION_NOTIFICATION, new EnableExceptionNotificationAction());
        actions.put(SET_CURRENT_STRATEGY, new SetCurrentStrategyAction());
        actions.put(GET_CURRENT_STRATEGY, new GetCurrentStrategyAction());
        actions.put(HAS_PENDING_UPDATE, new HasPendingUpdateAction());
        actions.put(SET_IDLE, new SetIdleAction());
        actions.put(SET_CURRENT_ACTIVITY, new SetCurrentActivityAction());
        actions.put(GET_DEVICE_ID, new GetDeviceId());
        actions.put(INSTALL_APK, new InstallAPK());
        actions.put(SEND_EXCEPTION_FLUTTER, new SendAsyncExceptionFlutter());
    }

    public FlutterPushLinkPlugin() {
        Log.i(FlutterPushLinkPlugin.TAG, "Initializing " + TAG + " v:" + Version.pluginVersion);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {

        Result resultThread = new MethodResultWrapper(result);

        if (call.method.equals("getPlatformVersion")) {

            result.success("Android " + android.os.Build.VERSION.RELEASE);

        } else if (actions.containsKey(call.method)) {

            try {

                PushLinkPluginAction pluginAction = actions.get(call.method);
                assert pluginAction != null;
                pluginAction.execute(activity, context, call, result, resultThread);

            } catch (Exception e) {
                Log.e(FlutterPushLinkPlugin.TAG, "PushLinkPluginAction Exception", e);
            }

        } else if (call.method.equals("testEventChannel")) {

            testEventChannel();

        } else if (call.method.equals("toast") && call.hasArgument("message")) {

            if (mToast != null) {
                mToast.cancel();
            }
            mToast = Toast.makeText(context, "", Toast.LENGTH_LONG);
            mToast.setText(call.argument("message").toString());
            mToast.show();

        } else {

            result.notImplemented();

        }

    }

    public void testEventChannel() {

        timerSubscription = Observable
                .interval(0, 1, TimeUnit.SECONDS)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(
                        new Consumer<Long>() {
                            @Override
                            public void accept(Long timer) {
                                Log.w(TAG, "emitting timer event " + timer);
                                if (eventsChannel != null)
                                    eventsChannel.success(timer);
                            }
                        },
                        new Consumer<Throwable>() {
                            @Override
                            public void accept(Throwable error) {
                                Log.e(TAG, "error in emitting timer", error);

                                if (eventsChannel != null)
                                    eventsChannel.error("STREAM", "Error in processing observable", error.getMessage());
                            }
                        },
                        new Action() {
                            @Override
                            public void run() {
                                Log.w(TAG, "closing the timer observable");
                            }
                        }
                );
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_push_link");
        channel.setMethodCallHandler(this);
        context = flutterPluginBinding.getApplicationContext();

        new EventChannel(flutterPluginBinding.getBinaryMessenger(), STREAM).setStreamHandler(
                new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object args, final EventChannel.EventSink events) {
                        if (eventsChannel != null) {
                            eventsChannel.endOfStream();
                        }
                        eventsChannel = events;
                        Log.w(TAG, "adding listener");
                    }

                    @Override
                    public void onCancel(Object args) {
                        Log.w(TAG, "cancelling listener");
                        if (eventsChannel != null) {
                            eventsChannel.endOfStream();
                        }
                        eventsChannel = null;
                        if (timerSubscription != null) {
                            timerSubscription.dispose();
                            timerSubscription = null;
                        }
                    }
                }
        );

    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

    }

    @Override
    public void onDetachedFromActivity() {

    }

    private static class MethodResultWrapper implements Result {
        private final Result methodResult;
        private final Handler handler;

        MethodResultWrapper(Result result) {
            methodResult = result;
            handler = new Handler(Looper.getMainLooper());
        }

        @Override
        public void success(final Object result) {
            handler.post(new Runnable() {
                @Override
                public void run() {
                    methodResult.success(result);
                }
            });
        }

        @Override
        public void error(final String errorCode, final String errorMessage, final Object errorDetails) {
            handler.post(new Runnable() {
                @Override
                public void run() {
                    methodResult.error(errorCode, errorMessage, errorDetails);
                }
            });
        }

        @Override
        public void notImplemented() {
            handler.post(new Runnable() {
                @Override
                public void run() {
                    methodResult.notImplemented();
                }
            });
        }
    }

}
