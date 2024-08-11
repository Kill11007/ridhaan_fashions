import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

class PdfApi {
  static Future<File> saveDocument({
    required String name,
    required Document pdf,
  }) async {
    final bytes = await pdf.save();
    Directory generalDownloadDir = Directory('/storage/emulated/0/Download');
    File file = await File('${generalDownloadDir.path}/$name').create();
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      } else if (result.isDenied) {
        await openAppSettings();
      }
    }
    return false;
  }

  static Future<File> getFile(String fileName) async {
    Directory? directory;
    try {
      if (Platform.isAndroid) {
        if (await _requestPermission(Permission.storage)) {
          directory = await getExternalStorageDirectory();
          String newPath = "";
          print(directory);
          List<String> paths = directory!.path.split("/");
          for (int x = 1; x < paths.length; x++) {
            String folder = paths[x];
            if (folder != "Android") {
              newPath += "/$folder";
            } else {
              break;
            }
          }
          newPath =
              "$newPath/ridhaan_fashions"; //TODO make ridhaan_fashions as constant
          directory = Directory(newPath);
          if (!await directory.exists()) {
            await directory.create(recursive: true);
          }
          if (await directory.exists()) {
            File saveFile = File("${directory.path}/$fileName");

            return saveFile;
          }
        }
      }
    } catch (e) {
      print(e);
    }
    throw "File Not Created";
  }
}
