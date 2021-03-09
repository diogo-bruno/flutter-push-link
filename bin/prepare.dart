import 'dart:io';
import 'package:xml/xml.dart';
import 'utils.dart';

String pushlinkAdminReceiver = '''

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
''';

String xmlAdminDevice = '''
<device-admin xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-policies>
        <limit-password />
        <watch-login />
        <reset-password />
        <force-lock />
        <wipe-data />
        <expire-password />
        <encrypted-storage />
        <disable-camera />
        <disable-keyguard-features/>
    </uses-policies>
</device-admin>
''';

void main(List<String> arguments) async {
  init();

  printCI('cyan', 'Prepare Android settings', 2);
  //print(arguments);

  String androiSrcMain =
      '${Directory.current.path}${Platform.pathSeparator}android${Platform.pathSeparator}app${Platform.pathSeparator}src${Platform.pathSeparator}main${Platform.pathSeparator}';

  final fileAndroidManifest = new File(androiSrcMain + 'AndroidManifest.xml');
  final document = XmlDocument.parse(fileAndroidManifest.readAsStringSync());

  printCI('green', '• Get package project', 0);

  String packageName = document.getElement('manifest').getAttribute('package');

  String pathAndroidPackage =
      androiSrcMain + '${Platform.pathSeparator}java${Platform.pathSeparator}' + packageName.replaceAll('.', '${Platform.pathSeparator}');

  printCI('green', '• Package project: ' + packageName, 0);

  var filePushlinkAdminReceiver = new File(pathAndroidPackage + '${Platform.pathSeparator}PushlinkAdminReceiver.java');
  filePushlinkAdminReceiver.createSync(recursive: true);
  var sink = filePushlinkAdminReceiver.openWrite();
  sink.write('package $packageName;\n' + pushlinkAdminReceiver);
  sink.close();

  var directoryXmlAdminDevice = new Directory(androiSrcMain + '${Platform.pathSeparator}res${Platform.pathSeparator}xml${Platform.pathSeparator}');

  directoryXmlAdminDevice.createSync(recursive: true);

  printCI('green', '• Create class PushlinkAdminReceiver', 0);

  var fileXmlAdminDevice = new File(directoryXmlAdminDevice.path + 'device_admin_sample.xml');
  filePushlinkAdminReceiver.createSync(recursive: true);
  sink = fileXmlAdminDevice.openWrite();
  sink.write(xmlAdminDevice);
  sink.close();

  printCI('green', '• Create XML device_admin', 0);

  bool permissionInternet = false;
  bool permissionInstallPACKAGES = false;
  bool apacheHttpLegacy = false;
  bool fileProvider = false;
  bool adminReceiver = false;

  XmlElement xmlApacheHttpLegacy = XmlElement(
      XmlName('uses-library'), [XmlAttribute(XmlName('android:name'), 'org.apache.http.legacy'), XmlAttribute(XmlName('android:required'), 'false')]);

  XmlElement xmlFileProvider = XmlElement(XmlName('provider'), [
    XmlAttribute(XmlName('android:name'), 'com.pushlink.android.FileProvider'),
    XmlAttribute(XmlName('android:authorities'), packageName),
    XmlAttribute(XmlName('android:exported'), 'true')
  ]);

  XmlElement xmlAdminReceiver = XmlElement(XmlName('receiver'), [
    XmlAttribute(XmlName('android:name'), '.PushlinkAdminReceiver'),
    XmlAttribute(XmlName('android:permission'), 'android.permission.BIND_DEVICE_ADMIN'),
  ], [
    XmlElement(XmlName('meta-data'),
        [XmlAttribute(XmlName('android:name'), 'android.app.device_admin'), XmlAttribute(XmlName('android:resource'), '@xml/device_admin_sample')]),
    XmlElement(XmlName('intent-filter'), [], [
      XmlElement(XmlName('action'), [XmlAttribute(XmlName('android:name'), 'android.app.action.DEVICE_ADMIN_ENABLED')]),
      XmlElement(XmlName('action'), [XmlAttribute(XmlName('android:name'), 'android.intent.action.MY_PACKAGE_REPLACED')])
    ])
  ]);

  document.getElement('manifest').findAllElements('uses-permission').forEach((node) => {
        if (node.getAttribute('android:name') == 'android.permission.INTERNET')
          {permissionInternet = true}
        else if (node.getAttribute('android:name') == 'android.permission.REQUEST_INSTALL_PACKAGES')
          {permissionInstallPACKAGES = true}
      });

  for (var node in document.getElement('manifest').getElement('application').findAllElements('uses-library')) {
    if (node.getAttribute('android:name') == 'org.apache.http.legacy') {
      node.replace(xmlApacheHttpLegacy);
      apacheHttpLegacy = true;
    }
  }

  for (var node in document.getElement('manifest').getElement('application').findAllElements('provider')) {
    if (node.getAttribute('android:name') == 'com.pushlink.android.FileProvider') {
      node.replace(xmlFileProvider);
      fileProvider = true;
    }
  }

  for (var node in document.getElement('manifest').getElement('application').findAllElements('receiver')) {
    if (node.getAttribute('android:name') == '.PushlinkAdminReceiver') {
      node.replace(xmlAdminReceiver);
      adminReceiver = true;
    }
  }

  if (!apacheHttpLegacy) {
    document.getElement('manifest').getElement('application').children.add(xmlApacheHttpLegacy);
  }

  if (!adminReceiver) {
    document.getElement('manifest').getElement('application').children.add(xmlAdminReceiver);
  }

  if (!fileProvider) {
    document.getElement('manifest').getElement('application').children.add(xmlFileProvider);
  }

  if (!permissionInternet) {
    XmlElement internet = XmlElement(XmlName('uses-permission'), [XmlAttribute(XmlName('android:name'), 'android.permission.INTERNET')]);
    document.getElement('manifest').children.add(internet);
  }

  if (!permissionInstallPACKAGES) {
    XmlElement internet =
        XmlElement(XmlName('uses-permission'), [XmlAttribute(XmlName('android:name'), 'android.permission.REQUEST_INSTALL_PACKAGES')]);
    document.getElement('manifest').children.add(internet);
  }

  String newXmlAndroidManifest = document.toXmlString(
    pretty: true,
    level: 2,
    newLine: '\n',
    indentAttribute: (value) => true,
  );

  sink = fileAndroidManifest.openWrite();
  sink.write(newXmlAndroidManifest);
  sink.close();

  printCI('green', '• Update file AndroidManifest.xml', 2);

  printCI('yellow', 'For strategy CUSTOM update, requires the app to be a device owner!', 1);

  printCI('white', 'Command to device owner:', 1);

  printCI(
    'red',
    'adb shell dpm set-device-owner ' + packageName + '/.PushlinkAdminReceiver',
    2,
  );

  printCI('magenta', 'Finished Configuration', 2);
}

//clear && flutter pub run flutter_push_link:prepare
