import 'dart:io';
import 'utils.dart';
import 'package:xml/xml.dart';
import 'dart:convert';
import 'package:cli_menu/cli_menu.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

void main() async {
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

  printCI('green', '• Get package project', 0);

  String packageName = document.getElement('manifest').getAttribute('package');

  printCI('green', '• Package project: ' + packageName, 1);

  printCI('red', '  (Type the number) Select the path to the apk file:', 1);

  String pathDirectoryOutputsDebug =
      '${Directory.current.path}${Platform.pathSeparator}build${Platform.pathSeparator}app${Platform.pathSeparator}outputs${Platform.pathSeparator}apk${Platform.pathSeparator}debug';

  String pathDirectoryOutputsRelease =
      '${Directory.current.path}${Platform.pathSeparator}build${Platform.pathSeparator}app${Platform.pathSeparator}outputs${Platform.pathSeparator}apk${Platform.pathSeparator}release';

  List<String> apks = [];
  List<String> apksMenu = [];

  var directoryOutputsDebug = new Directory(pathDirectoryOutputsDebug);

  if (directoryOutputsDebug.existsSync()) {
    List contentsDebug = directoryOutputsDebug.listSync();
    for (var fileOrDir in contentsDebug) {
      if (fileOrDir is File) {
        if (fileOrDir.path.endsWith('.apk')) {
          apksMenu.add("debug: " + fileOrDir.path.split(Platform.pathSeparator).last);
          apks.add(fileOrDir.path);
        }
      }
    }
  }

  var directoryOutputsRelease = new Directory(pathDirectoryOutputsRelease);

  if (directoryOutputsRelease.existsSync()) {
    List contentsRelease = directoryOutputsRelease.listSync();
    for (var fileOrDir in contentsRelease) {
      if (fileOrDir is File) {
        if (fileOrDir.path.endsWith('.apk')) {
          apksMenu.add("release: " + fileOrDir.path.split(Platform.pathSeparator).last);
          apks.add(fileOrDir.path);
        }
      }
    }
  }

  apks.add("CANCEL");
  apksMenu.add("CANCEL");

  if (apks.length == 0) {
    printCI('red', 'No files APK to select', 2);
  } else {
    final menu = Menu(apksMenu);
    final result = menu.choose();
    var pathApk = apks[result.index];
    if (pathApk == 'CANCEL') {
      printCI('magenta', 'Process canceled', 2);
    } else {
      uploadFile(new File(pathApk), pushLinkApiKey);
    }
  }
}

void uploadFile(File apk, String pushLinkApiKey) async {
  // ignore: deprecated_member_use
  var stream = new http.ByteStream(DelegatingStream.typed(apk.openRead()));
  var length = await apk.length();
  var uri = Uri.parse("https://www.pushlink.com/apps/api_upload");
  var request = new MultipartRequest(
    "POST",
    uri,
    onProgress: (int bytes, int total) {
      final progress = ((bytes / total) * 100).toStringAsFixed(2);
      printCIInLine('cyan', "Upload APK in progress $progress% sent", 0);
    },
  );
  request.fields["apiKey"] = pushLinkApiKey;
  request.fields["current"] = "true";
  var multipartFile = new http.MultipartFile('apk', stream, length, filename: basename(apk.path));
  request.files.add(multipartFile);

  printCI('reset', '', 1);
  printCI('yellow', 'Upload started APK: ' + apk.path, 1);

  await request.send().then((response) async {
    response.stream.transform(utf8.decoder).listen((value) {
      printCI('reset', '', 0);
      printCI('reset', '', 0);
      printCI(
        value != null && value.toUpperCase().trim().startsWith('PushLink deploy fails'.toUpperCase()) ? 'red' : 'green',
        'Response: ' + value,
        1,
      );
    });
  }).catchError((e) {
    print(e);
  });
}

class MultipartRequest extends http.MultipartRequest {
  MultipartRequest(
    String method,
    Uri url, {
    this.onProgress,
  }) : super(method, url);
  final void Function(int bytes, int totalBytes) onProgress;
  http.ByteStream finalize() {
    final byteStream = super.finalize();
    if (onProgress == null) return byteStream;
    final total = this.contentLength;
    int bytes = 0;
    final t = StreamTransformer.fromHandlers(
      handleData: (List<int> data, EventSink<List<int>> sink) {
        bytes += data.length;
        onProgress(bytes, total);
        sink.add(data);
      },
    );
    final stream = byteStream.transform(t);
    return http.ByteStream(stream);
  }
}

//clear && flutter pub run flutter_push_link:publish.apk
