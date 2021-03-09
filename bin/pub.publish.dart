import 'dart:io';
import 'utils.dart';
import 'package:xml/xml.dart';

void main(List<String> arguments) async {
  var arg0 = arguments.length > 0 ? arguments[0] : "";

  init();

  String pubspec = '${Directory.current.path}${Platform.pathSeparator}pubspec.yaml';

  var filePubspec = new File(pubspec);

  if (!filePubspec.existsSync()) {
    printCI('red', 'The file pubspec.yaml does not exist', 2);
    exit(0);
  }

  final contentPubspec = filePubspec.readAsStringSync();

  var version = '';
  for (var item in contentPubspec.split(new RegExp(r"\r\n|\r|\n"))) {
    if (item.startsWith("version:")) {
      version = item.split("version:")[1].trim();
    }
  }

  String androiSrcMain =
      '${Directory.current.path}${Platform.pathSeparator}android${Platform.pathSeparator}src${Platform.pathSeparator}main${Platform.pathSeparator}';

  final fileAndroidManifest = new File(androiSrcMain + 'AndroidManifest.xml');
  final document = XmlDocument.parse(fileAndroidManifest.readAsStringSync());

  printCI('green', '• Get package project', 1);

  String packageName = document.getElement('manifest').getAttribute('package');

  String pathAndroidPackage =
      androiSrcMain + '${Platform.pathSeparator}java${Platform.pathSeparator}' + packageName.replaceAll('.', '${Platform.pathSeparator}');

  var fileVersion = new File(pathAndroidPackage + Platform.pathSeparator + 'Version.java');

  var contentFileVersion = fileVersion.readAsStringSync();

  var splitContentFileVersion = contentFileVersion.split('pluginVersion = "');

  var newFileVersionJava = splitContentFileVersion[0] + 'pluginVersion = "' + version + '"' + splitContentFileVersion[1].split('"')[1];

  var sink = fileVersion.openWrite();
  sink.write(newFileVersionJava);
  sink.close();

  String command = 'dart pub publish ' + arg0;

  printCI('green', '• Update file version plugin', 1);

  printCI('cyan', '• Started command: "$command"', 1);

  if (Platform.isWindows) {
    Process.run('cmd', ['/c', command]).then((result) {
      stdout.write(result.stdout);
      stderr.write(result.stderr);

      printCI('reset', '', 1);

      printCI('green', 'Finished command: $command', 1);
    });
  } else {
    Process.run('sh', ['-c', command]).then((result) {
      stdout.write(result.stdout);
      stderr.write(result.stderr);

      printCI('reset', '', 1);

      printCI('green', 'Finished command: $command', 1);
    });
  }
}

//clear && flutter pub run flutter_push_link:pub.publish --dry-run
