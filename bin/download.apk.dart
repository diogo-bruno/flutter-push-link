import 'dart:io';
import 'utils.dart';
import 'package:xml/xml.dart';
import 'dart:convert';
import 'dart:async';
import 'package:clippy/server.dart' as clippy;

void main(List<String> arguments) async {
  init();

  printCI('cyan', 'Download APK', 2);

  String dotEnv = '${Directory.current.path}${Platform.pathSeparator}.env';

  var fileDotEnv = new File(dotEnv);

  if (!fileDotEnv.existsSync()) {
    printCI('red', 'The file .env does not exist containing the PUSH_LINK_API_KEY', 2);
    exit(0);
  }

  final contentDotEnv = fileDotEnv.readAsStringSync();

  String pushLinkApiKey = '';

  for (var item in contentDotEnv.split(new RegExp(r"\r\n|\r|\n"))) {
    if (item.startsWith("PUSH_LINK_API_KEY=")) {
      pushLinkApiKey = item.split("PUSH_LINK_API_KEY=")[1].trim();
    }
  }

  if (pushLinkApiKey == null || pushLinkApiKey.isEmpty) {
    printCI('red', 'env.PUSH_LINK_API_KEY does not exist, please create PUSH_LINK_API_KEY in file .env in your project!', 1);
    exit(0);
  }

  String androiSrcMain =
      '${Directory.current.path}${Platform.pathSeparator}android${Platform.pathSeparator}app${Platform.pathSeparator}src${Platform.pathSeparator}main${Platform.pathSeparator}';

  final fileAndroidManifest = new File(androiSrcMain + 'AndroidManifest.xml');
  final document = XmlDocument.parse(fileAndroidManifest.readAsStringSync());

  printCI('green', '• Get package project', 1);

  String packageName = document.getElement('manifest').getAttribute('package');

  HttpClient client = new HttpClient();
  client.findProxy = HttpClient.findProxyFromEnvironment;

  packageName = 'com.example';
  packageName = 'com.pushlink.background';

  String url = 'https://www.pushlink.com/download?package=' + packageName + '&api_key=' + pushLinkApiKey;

  var directoryPushlinkApkDownload = new Directory(Directory.current.path + '${Platform.pathSeparator}pushlink-apk-download');

  directoryPushlinkApkDownload.createSync(recursive: true);

  File downloadFile = new File(directoryPushlinkApkDownload.path + Platform.pathSeparator + packageName + '.apk');

  client.getUrl(Uri.parse(url)).then((HttpClientRequest request) {
    return request.close();
  }).then((HttpClientResponse response) async {
    String contentDisposition = response.headers.value('content-disposition');

    if (contentDisposition != null && contentDisposition.startsWith('attachment;filename=')) {
      var length = response.contentLength;
      var sink = downloadFile.openWrite();

      Future.doWhile(() async {
        var received = await downloadFile.length();

        var progress = ((received / length) * 100).toStringAsFixed(2);
        printCIInLine('cyan', "Download APK in progress $progress%", 0);

        return received != length;
      });

      await response.pipe(sink);

      printCI("reset", "", 2);

      printCI('green', 'Running command install APk:', 1);

      var comandAdbInstall = 'adb install -r ' + directoryPushlinkApkDownload.path + Platform.pathSeparator + packageName + '.apk';

      printCI('magenta', comandAdbInstall, 1);

      if (Platform.isWindows) {
        Process.run('cmd.exe', ['/c', "echo " + comandAdbInstall + "| clip"]).then((result) {
          // stdout.write(result.stdout);
          // stderr.write(result.stderr);
          printCI('white', 'Command copied to the clipboard', 1);
        });
      } else {
        await clippy.write(comandAdbInstall);
        printCI('white', 'Command copied to the clipboard', 1);
      }
    } else {
      String responseBody = await readResponse(response);

      printCI('red', responseBody, 2);
    }
  });
}

Future<String> readResponse(HttpClientResponse response) {
  final completer = Completer<String>();
  final contents = StringBuffer();
  response.transform(utf8.decoder).listen((data) {
    contents.write(data);
  }, onDone: () => completer.complete(contents.toString()));
  return completer.future;
}

//clear && flutter pub run flutter_push_link:download.apk
