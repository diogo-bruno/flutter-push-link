import 'dart:core';
import 'dart:io' show stdout;

void init() {
  print('''

██████╗ ██╗   ██╗███████╗██╗  ██╗    ██╗     ██╗███╗   ██╗██╗  ██╗
██╔══██╗██║   ██║██╔════╝██║  ██║    ██║     ██║████╗  ██║██║ ██╔╝
██████╔╝██║   ██║███████╗███████║    ██║     ██║██╔██╗ ██║█████╔╝ 
██╔═══╝ ██║   ██║╚════██║██╔══██║    ██║     ██║██║╚██╗██║██╔═██╗ 
██║     ╚██████╔╝███████║██║  ██║    ███████╗██║██║ ╚████║██║  ██╗
╚═╝      ╚═════╝ ╚══════╝╚═╝  ╚═╝    ╚══════╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝

''');
}

void printCI(color, msg, consoleLines) {
  var colorsConsole = {};
  colorsConsole['reset'] = '\x1b[0m';
  colorsConsole['black'] = '\x1b[30m';
  colorsConsole['red'] = '\x1b[31m';
  colorsConsole['green'] = '\x1b[32m';
  colorsConsole['yellow'] = '\x1b[33m';
  colorsConsole['blue'] = '\x1b[34m';
  colorsConsole['magenta'] = '\x1b[35m';
  colorsConsole['cyan'] = '\x1b[36m';
  colorsConsole['white'] = '\x1b[37m';

  if (msg != null) {
    if (color == null) color = 'reset';
    var colorP = color != null ? colorsConsole[color] : colorsConsole['reset'];
    if (colorP == null) colorP = colorsConsole['reset'];
    print(colorP + msg + colorsConsole['reset']);
  }

  if (consoleLines > 0) {
    for (var index = 0; index < consoleLines; index++) {
      print(colorsConsole['reset'] + '');
    }
  }
}

void printCIInLine(color, msg, consoleLines) {
  var colorsConsole = {};
  colorsConsole['reset'] = '\x1b[0m';
  colorsConsole['black'] = '\x1b[30m';
  colorsConsole['red'] = '\x1b[31m';
  colorsConsole['green'] = '\x1b[32m';
  colorsConsole['yellow'] = '\x1b[33m';
  colorsConsole['blue'] = '\x1b[34m';
  colorsConsole['magenta'] = '\x1b[35m';
  colorsConsole['cyan'] = '\x1b[36m';
  colorsConsole['white'] = '\x1b[37m';

  if (msg != null) {
    if (color == null) color = 'reset';
    var colorP = color != null ? colorsConsole[color] : colorsConsole['reset'];
    if (colorP == null) colorP = colorsConsole['reset'];
    stdout.write("\r " + colorP + msg + colorsConsole['reset'] + " \r");
  }

  if (consoleLines > 0) {
    for (var index = 0; index < consoleLines; index++) {
      stdout.write("\r " + colorsConsole['reset'] + '' + " \r");
    }
  }
}
