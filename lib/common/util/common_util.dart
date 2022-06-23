import 'dart:convert';
import 'dart:io';

import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:process_run/shell.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:uuid/uuid.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../const/color_const.dart';
import '../const/common_const.dart';
import '../enum/home_enum.dart';
import '../type/audio_data_type.dart';
import '../type/img_data_type.dart';
import '../type/link_data_type.dart';
import '../type/note_data_type.dart';
import '../type/other_data_type.dart';
import '../type/tree_node_type.dart';
import '../../widget/common_toast.dart';
import '../type/config_file_type.dart';
import '../type/video_data_type.dart';

class ConfigFile {
  ConfigFileType? configFile;

  ConfigFile.privateConstructor();

  static final instance = ConfigFile.privateConstructor();

  factory ConfigFile.getInstance() => instance;

  void setConfigFile(ConfigFileType config) {
    instance.configFile = config;
  }

  ConfigFileType? getConfigFile() {
    return instance.configFile;
  }
}

class CommonUtil {
  static Shell shell = Shell();

  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }

  static String getAppDataSavePath() {
    return Directory.current.path + "\\CcFavoritesData\\Data";
  }

  static String getAppDelDataSavePath() {
    return Directory.current.path + "\\CcFavoritesData\\DelData";
  }

  static String getConfigFilePath() {
    return Directory.current.path + "\\config\\config.json";
  }

  static String getInitConfigFilePath() {
    return Directory.current.path + "\\config\\init_config.json";
  }

  static ConfigFileType getConfigFile() {
    if (null != ConfigFile.getInstance().getConfigFile()) {
      return ConfigFile.getInstance().getConfigFile()!;
    } else {
      File configDistFile = File(CommonUtil.getConfigFilePath());
      if (!configDistFile.existsSync()) {
        configDistFile.createSync(recursive: true);
      }

      String configDist = configDistFile.readAsStringSync();
      if (configDist.isEmpty) {
        ConfigFileType configFile = ConfigFileType.fromJson(initConfig);

        String config = jsonEncode(configFile.toJson());
        if ("" == configFile.dataPath) {
          configFile.dataPath = CommonUtil.getAppDataSavePath();
          config = jsonEncode(configFile.toJson());
        }
        configDistFile.openWrite().write(config);
        ConfigFile.getInstance().setConfigFile(configFile);
        return ConfigFile.getInstance().getConfigFile()!;
      }

      Map<String, dynamic> json = jsonDecode(configDist);
      ConfigFileType configFile = ConfigFileType.fromJson(json);

      if ("" == configFile.dataPath) {
        configFile.dataPath = CommonUtil.getAppDataSavePath();
        String config = jsonEncode(configFile);
        configDistFile.openWrite().write(config);
      }
      ConfigFile.getInstance().setConfigFile(configFile);
      return ConfigFile.getInstance().getConfigFile()!;
    }
  }

  static void updateConfigFile(ConfigFileType configFile) {
    String filePath = CommonUtil.getConfigFilePath();
    File file = File(filePath);
    file.openWrite().write(jsonEncode(configFile));
    ConfigFile.getInstance().setConfigFile(configFile);
  }

  static List<String> getFileNameAndExtension(String file) {
    return file.split('.');
  }

  static String getFilePath(String file) {
    String splitStr = '\\';
    if (!file.contains("\\")) {
      splitStr = "/";
    }
    return file.split(splitStr).last;
  }

  static String getFileName(FileSystemEntity file) {
    String splitStr = '\\';
    if (!file.path.contains("\\")) {
      splitStr = "/";
    }
    return file.path.split(splitStr).last;
  }

  static String getParentDirectory(String path) {
    Directory directory = Directory(path);
    return directory.parent.path;
  }

  static Future<List<TreeNodeType>> getRootDirectoryListToTreeNodes() async {
    ConfigFileType config = CommonUtil.getConfigFile();
    var directory = Directory(config.dataPath);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    return CommonUtil.getDirectoryListToTreeNodes(config.dataPath);
  }

  static Future<List<LinkDataType>> getLinkFileList(
      String path, String keyWork) async {
    List<LinkDataType> list = [];
    try {
      ConfigFileType config = CommonUtil.getConfigFile();

      var directory = Directory(path + "\\" + config.linkFileDirectory);
      if (directory.existsSync()) {
        List<FileSystemEntity> files = directory.listSync(followLinks: false);
        for (var file in files) {
          var bool = FileSystemEntity.isFileSync(file.path);

          String fileName = CommonUtil.getFileName(file);
          String urlName = fileName.split('.').first;

          if (bool &&
              (fileName.endsWith(".json") || fileName.endsWith(".JSON")) &&
              urlName.contains(keyWork)) {
            //FileStat fileStat = file.statSync();
            String id = const Uuid().v5(Uuid.NAMESPACE_URL, file.path);
            File jsonFile = File(file.path);
            String jsonStr = jsonFile.readAsStringSync();
            Map<String, dynamic> json = jsonDecode(jsonStr);
            LinkDataType linkData =
                LinkDataType.fromJson(id, fileName, file.path, urlName, json);
            linkData.fileName = fileName;
            list.add(linkData);
          }
        }
      }
    } catch (e) {
      print(e);
    }
    return list;
  }

  static Future<List<TreeNodeType>> getDirectoryListToTreeNodes(
      String path) async {
    List<TreeNodeType> list = [];
    try {
      ConfigFileType config = CommonUtil.getConfigFile();

      var directory = Directory(path);
      List<FileSystemEntity> files = directory.listSync(followLinks: false);
      for (var file in files) {
        var bool = FileSystemEntity.isDirectorySync(file.path);
        String title = CommonUtil.getFileName(file);
        if (bool && !config.reservedDirectoryList.contains(title)) {
          //FileStat fileStat = file.statSync();

          Map<String, String> extra = {'path': file.path};
          String id = const Uuid().v5(Uuid.NAMESPACE_URL, file.path);
          list.add(TreeNodeType(
              id: id,
              icon: Icons.folder_open_rounded,
              title: title,
              expaned: false,
              checked: false,
              children: [],
              extra: extra));
        }
      }
    } catch (e) {
      print(e);
    }
    return list;
  }

  static Future<void> checkDelMoveDirectory(
      Function moveFunc, Function delFunc) async {
    ConfigFileType config = CommonUtil.getConfigFile();
    if ("" != config.delMovePath) {
      Directory directory = Directory(config.delMovePath);
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
        moveFunc(config.delMovePath);
      } else {
        moveFunc(config.delMovePath);
      }
    } else {
      delFunc();
    }
  }

  static void deleteFile(String path, Function successCb, Function failCb) {
    File file = File(path);
    if (file.existsSync()) {
      try {
        CommonUtil.checkDelMoveDirectory((String delMoveDirectory) {
          String fileName = CommonUtil.getFileName(file);
          String delDate = DateTime.now().millisecondsSinceEpoch.toString();
          file.renameSync(delMoveDirectory + "\\" + delDate + "-" + fileName);
          //file.copySync(delMoveDirectory + "\\" + delDate + "-" + fileName);
          //file.delete();
          successCb('删除成功！');
        }, () {
          try {
            file.deleteSync();
            successCb('删除成功！');
          } catch (e) {
            failCb('删除失败，请检查文件是否被打开！');
            print(e);
          }
        });
      } catch (e) {
        failCb('删除失败，请检查文件是否被打开！');
        print(e);
      }
    }
  }

  static void saveFile(
      String path, dynamic saveObj, Function successCb, Function failCb) {
    File file = File(path);
    if (!file.existsSync()) {
      try {
        String jsonStr = jsonEncode(saveObj);
        file.writeAsStringSync(jsonStr);
        successCb('保存成功！');
      } catch (e) {
        failCb('保存失败！');
        print(e);
      }
    } else {
      failCb('文件已存在！');
    }
  }

  static void updateFile(
      String path, dynamic saveObj, Function successCb, Function failCb) {
    File file = File(path);
    try {
      String jsonStr = jsonEncode(saveObj);
      file.writeAsStringSync(jsonStr);
      successCb('保存成功！');
    } catch (e) {
      failCb('保存失败！');
      print(e);
    }
  }

  static void fileMove(String sourcePath, String targetPath, Function successCb,
      Function failCb) {
    try {
      File file = File(sourcePath);
      if (file.existsSync()) {
        file.renameSync(targetPath);
        successCb("移动成功！");
      } else {
        failCb('目录不存在！');
      }
    } catch (e) {
      failCb('移动失败！');
      print(e);
    }
  }

  static void saveLinkFile(
      String path, dynamic saveObj, Function successCb, Function failCb) async {
    ConfigFileType config = CommonUtil.getConfigFile();

    String directoryPath = path + "\\" + config.linkFileDirectory;
    Directory directory = Directory(directoryPath);
    if (!directory.existsSync()) {
      directory.createSync();
    }

    String filePath = directoryPath + "\\" + saveObj['urlName'] + '.json';

    CommonUtil.saveFile(filePath, saveObj, successCb, failCb);
  }

  static void updateLinkFile(String oldUrlName, String path, dynamic saveObj,
      Function successCb, Function failCb) async {
    ConfigFileType config = CommonUtil.getConfigFile();

    String oldFilePath =
        path + "\\" + config.linkFileDirectory + "\\" + oldUrlName + '.json';

    File oldFile = File(oldFilePath);
    if (oldFile.existsSync()) {
      oldFile.deleteSync();
    }

    String filePath = path +
        "\\" +
        config.linkFileDirectory +
        "\\" +
        saveObj['urlName'] +
        '.json';

    CommonUtil.saveFile(filePath, saveObj, successCb, failCb);
  }

  static void linkFileMove(String urlName, String sourcePath, String targetPath,
      Function successCb, Function failCb) async {
    ConfigFileType config = CommonUtil.getConfigFile();
    Directory linkFileDirectory =
        Directory(targetPath + "\\" + config.linkFileDirectory);
    if (!linkFileDirectory.existsSync()) {
      linkFileDirectory.createSync();
    }

    CommonUtil.fileMove(sourcePath,
        linkFileDirectory.path + "\\" + urlName + ".json", successCb, failCb);
  }

  static void imgFileMove(String fileName, String sourcePath, String targetPath,
      Function successCb, Function failCb) async {
    ConfigFileType config = CommonUtil.getConfigFile();
    Directory imgFileDirectory =
        Directory(targetPath + "\\" + config.imgFileDirectory);
    if (!imgFileDirectory.existsSync()) {
      imgFileDirectory.createSync();
    }

    CommonUtil.fileMove(
        sourcePath, imgFileDirectory.path + "\\" + fileName, successCb, failCb);
  }

  static void imgFileRename(
      String sourcePath, String newName, Function successCb, Function failCb) {
    try {
      File file = File(sourcePath);
      String targetPath = file.parent.path + "\\" + newName;

      File targetFile = File(targetPath);
      if (sourcePath == targetPath) {
        successCb("重命名成功！");
        return;
      }

      if (targetFile.existsSync()) {
        failCb(newName + '已存在！');
        return;
      }

      if (file.existsSync()) {
        file.renameSync(targetPath);
        successCb("重命名成功！");
      } else {
        failCb('重命名的图片不存在！');
      }
    } catch (e) {
      failCb('重命名失败！');
      print(e);
    }
  }

  static void saveDirectory(String path, Function successCb, Function failCb) {
    Directory directory = Directory(path);
    if (!directory.existsSync()) {
      try {
        directory.createSync();
        successCb('保存成功！');
      } catch (e) {
        failCb('保存失败！');
        print(e);
      }
    } else {
      failCb('目录已存在！');
    }
  }

  static void updateDirectory(
      String path, String newPath, Function successCb, Function failCb) {
    Directory newDirectory = Directory(newPath);
    if (!newDirectory.existsSync()) {
      try {
        Directory directory = Directory(path);
        directory.renameSync(newPath);
        successCb('保存成功！');
      } catch (e) {
        failCb('保存失败！');
        print(e);
      }
    } else {
      failCb('目录已存在！');
    }
  }

  static void deleteDirectory(
      String path, Function successCb, Function failCb) {
    Directory directory = Directory(path);
    if (directory.existsSync()) {
      try {
        CommonUtil.checkDelMoveDirectory((String delMoveDirectory) {
          String fileName = CommonUtil.getFileName(directory);
          String delDate = DateTime.now().millisecondsSinceEpoch.toString();
          String destPath = delMoveDirectory + "\\" + delDate + "-" + fileName;
          try {
            directory.renameSync(destPath);
            successCb('删除成功！');
          } catch (e) {
            failCb('删除失败！');
            print(e);
          }
        }, () {
          try {
            directory.delete(recursive: true);
            successCb('删除成功！');
          } catch (e) {
            failCb('删除失败！');
            print(e);
          }
        });
      } catch (e) {
        failCb('删除失败！');
        print(e);
      }
    }
  }

  static Future<int> getDirectoryMaxHeight(String path) async {
    int maxHeight = 0;
    List<TreeNodeType> list =
        await CommonUtil.getDirectoryListToTreeNodes(path);
    if (list.isEmpty) {
      return 1;
    }
    for (var element in list) {
      int curHeight = await getDirectoryMaxHeight(element.extra['path']);
      if (curHeight > maxHeight) {
        maxHeight = curHeight;
      }
    }
    return maxHeight + 1;
  }

  static void moveDirectory(String sourcePath, String targetPath,
      Function successCb, Function failCb) {
    try {
      Directory targetDirectory = Directory(targetPath);
      if (targetDirectory.existsSync()) {
        failCb('目标目录已存在！');
        return;
      }

      Directory directory = Directory(sourcePath);
      if (directory.existsSync()) {
        directory.renameSync(targetPath);
        successCb("移动成功！");
      } else {
        failCb('目录不存在！');
      }
    } catch (e) {
      failCb('移动失败！');
      print(e);
    }
  }

  static void moveDirectoryToRoot(String directoryName, String sourcePath,
      Function successCb, Function failCb) async {
    ConfigFileType config = CommonUtil.getConfigFile();
    CommonUtil.moveDirectory(
        sourcePath, config.dataPath + "\\" + directoryName, successCb, failCb);
  }

  static Future<List<ImgDataType>> getImgFileList(
      String path, String keyWork) async {
    List<ImgDataType> list = [];
    try {
      ConfigFileType config = CommonUtil.getConfigFile();

      var directory = Directory(path + "\\" + config.imgFileDirectory);
      if (directory.existsSync()) {
        List<FileSystemEntity> files = directory.listSync(followLinks: false);
        for (var file in files) {
          var bool = FileSystemEntity.isFileSync(file.path);

          String fileName = CommonUtil.getFileName(file);
          String urlName = fileName.split('.').first;

          if (bool &&
              CommonUtil.isImgExtension(fileName) &&
              urlName.contains(keyWork)) {
            String id = const Uuid().v5(Uuid.NAMESPACE_URL, file.path);
            ImgDataType imgDataType =
                ImgDataType(id, fileName, file.path, false);
            list.add(imgDataType);
          }
        }
      }
    } catch (e) {
      print(e);
    }
    return list;
  }

  static Future<void> uploadImgFile(
      String savePath,
      String filePath,
      String fileName,
      String newName,
      Function successCb,
      Function failCb) async {
    try {
      ConfigFileType config = CommonUtil.getConfigFile();

      String imgDirectoryPath = savePath + "\\" + config.imgFileDirectory;
      Directory imgDirectory = Directory(imgDirectoryPath);
      if (!imgDirectory.existsSync()) {
        imgDirectory.createSync();
      }

      String extension = CommonUtil.getFileNameAndExtension(fileName)[1];

      String renamePath = savePath +
          "\\" +
          config.imgFileDirectory +
          "\\" +
          newName +
          "." +
          extension;

      File file = File(renamePath);
      if (!file.existsSync()) {
        File copyFile = File(filePath);
        copyFile.copySync(renamePath);
        successCb('上传图片成功！');
      } else {
        failCb('图片“' + newName + '”已存在，可重命名后上传！');
      }
    } catch (e) {
      failCb('上传图片失败！');
    }
  }

  static void getDownloadFile(String path, String fileName, Function successCb,
      Function failCb, String failTxt) {
    File file = File(path);
    if (file.existsSync()) {
      List<String> fileNames = CommonUtil.getFileNameAndExtension(fileName);
      successCb(file, fileNames);
    } else {
      failCb(failTxt);
    }
  }

  static void getDownloadImgFile(
      String path, String fileName, Function successCb, Function failCb) {
    CommonUtil.getDownloadFile(path, fileName, successCb, failCb, '图片不存在！');
  }

  static void getDownloadLinkFile(
      String path, String fileName, Function successCb, Function failCb) {
    CommonUtil.getDownloadFile(path, fileName, successCb, failCb, '书签不存在！');
  }

  static void getDownloadVideoFile(
      String path, String fileName, Function successCb, Function failCb) {
    CommonUtil.getDownloadFile(path, fileName, successCb, failCb, '视频不存在！');
  }

  static void getDownloadAudioFile(
      String path, String fileName, Function successCb, Function failCb) {
    CommonUtil.getDownloadFile(path, fileName, successCb, failCb, '音频不存在！');
  }

  static void getDownloadNoteFile(
      String path, String fileName, Function successCb, Function failCb) {
    CommonUtil.getDownloadFile(path, fileName, successCb, failCb, '笔记不存在！');
  }

  static void getDownloadOtherFile(
      String path, String fileName, Function successCb, Function failCb) {
    CommonUtil.getDownloadFile(path, fileName, successCb, failCb, '文件不存在！');
  }

  static Future<List<VideoDataType>> getVideoFileList(
      String path, String keyWork) async {
    List<VideoDataType> list = [];
    try {
      ConfigFileType config = CommonUtil.getConfigFile();

      var directory = Directory(path + "\\" + config.videoFileDirectory);
      if (directory.existsSync()) {
        List<FileSystemEntity> files = directory.listSync(followLinks: false);
        for (var file in files) {
          var bool = FileSystemEntity.isFileSync(file.path);

          String fileName = CommonUtil.getFileName(file);
          String urlName = fileName.split('.').first;

          if (bool &&
              CommonUtil.isVideoExtension(fileName) &&
              urlName.contains(keyWork)) {
            String id = const Uuid().v5(Uuid.NAMESPACE_URL, file.path);
            VideoDataType videoDataType =
                VideoDataType(id, fileName, file.path, false);
            list.add(videoDataType);
          }
        }
      }
    } catch (e) {
      print(e);
    }
    return list;
  }

  static Future<void> uploadVideoFile(
      String savePath,
      String filePath,
      String fileName,
      String newName,
      Function successCb,
      Function failCb) async {
    try {
      ConfigFileType config = CommonUtil.getConfigFile();

      String videoDirectoryPath = savePath + "\\" + config.videoFileDirectory;
      Directory videoDirectory = Directory(videoDirectoryPath);
      if (!videoDirectory.existsSync()) {
        videoDirectory.createSync();
      }

      String extension = CommonUtil.getFileNameAndExtension(fileName)[1];

      String renamePath = savePath +
          "\\" +
          config.videoFileDirectory +
          "\\" +
          newName +
          "." +
          extension;

      File file = File(renamePath);
      if (!file.existsSync()) {
        File copyFile = File(filePath);
        copyFile.copySync(renamePath);
        successCb('上传视频成功！');
      } else {
        failCb('视频“' + newName + '”已存在，可重命名后上传！');
      }
    } catch (e) {
      failCb('上传视频失败！');
    }
  }

  static void videoFileMove(String fileName, String sourcePath,
      String targetPath, Function successCb, Function failCb) async {
    ConfigFileType config = CommonUtil.getConfigFile();
    Directory videoFileDirectory =
        Directory(targetPath + "\\" + config.videoFileDirectory);
    if (!videoFileDirectory.existsSync()) {
      videoFileDirectory.createSync();
    }

    CommonUtil.fileMove(sourcePath, videoFileDirectory.path + "\\" + fileName,
        successCb, failCb);
  }

  static void videoFileRename(
      String sourcePath, String newName, Function successCb, Function failCb) {
    try {
      File file = File(sourcePath);
      String targetPath = file.parent.path + "\\" + newName;

      File targetFile = File(targetPath);
      if (sourcePath == targetPath) {
        successCb("重命名成功！");
        return;
      }

      if (targetFile.existsSync()) {
        failCb(newName + '已存在！');
        return;
      }

      if (file.existsSync()) {
        file.renameSync(targetPath);
        successCb("重命名成功！");
      } else {
        failCb('重命名的视频不存在！');
      }
    } catch (e) {
      failCb('重命名失败！');
      print(e);
    }
  }

  static Future<List<NoteDataType>> getNoteFileList(
      String path, String keyWork) async {
    List<NoteDataType> list = [];
    try {
      ConfigFileType config = CommonUtil.getConfigFile();

      var directory = Directory(path + "\\" + config.noteFileDirectory);
      if (directory.existsSync()) {
        List<FileSystemEntity> files = directory.listSync(followLinks: false);
        for (var file in files) {
          var bool = FileSystemEntity.isFileSync(file.path);

          String fileName = CommonUtil.getFileName(file);
          String urlName = fileName.split('.').first;

          if (bool &&
              CommonUtil.isNoteExtension(fileName) &&
              urlName.contains(keyWork) &&
              !urlName.startsWith("~\$")) {
            String id = const Uuid().v5(Uuid.NAMESPACE_URL, file.path);
            NoteDataType noteDataType =
                NoteDataType(id, fileName, file.path, false);
            list.add(noteDataType);
          }
        }
      }
    } catch (e) {
      print(e);
    }
    return list;
  }

  static Future<void> uploadNoteFile(
      String savePath,
      String filePath,
      String fileName,
      String newName,
      Function successCb,
      Function failCb) async {
    try {
      ConfigFileType config = CommonUtil.getConfigFile();

      String noteDirectoryPath = savePath + "\\" + config.noteFileDirectory;
      Directory noteDirectory = Directory(noteDirectoryPath);
      if (!noteDirectory.existsSync()) {
        noteDirectory.createSync();
      }

      String extension = CommonUtil.getFileNameAndExtension(fileName)[1];

      String renamePath = noteDirectory.path + "\\" + newName + "." + extension;

      File file = File(renamePath);
      if (!file.existsSync()) {
        File copyFile = File(filePath);
        copyFile.copySync(renamePath);
        successCb('上传笔记成功！');
      } else {
        failCb('笔记“' + newName + '”已存在，可重命名后上传！');
      }
    } catch (e) {
      failCb('上传笔记失败！');
    }
  }

  static void noteFileMove(String fileName, String sourcePath,
      String targetPath, Function successCb, Function failCb) async {
    ConfigFileType config = CommonUtil.getConfigFile();
    Directory fileDirectory =
        Directory(targetPath + "\\" + config.noteFileDirectory);
    if (!fileDirectory.existsSync()) {
      fileDirectory.createSync();
    }

    CommonUtil.fileMove(
        sourcePath, fileDirectory.path + "\\" + fileName, successCb, failCb);
  }

  static void noteFileRename(
      String sourcePath, String newName, Function successCb, Function failCb) {
    try {
      File file = File(sourcePath);
      String targetPath = file.parent.path + "\\" + newName;

      File targetFile = File(targetPath);
      if (sourcePath == targetPath) {
        successCb("重命名成功！");
        return;
      }

      if (targetFile.existsSync()) {
        failCb(newName + '已存在！');
        return;
      }

      if (file.existsSync()) {
        file.renameSync(targetPath);
        successCb("重命名成功！");
      } else {
        failCb('重命名的笔记不存在！');
      }
    } catch (e) {
      failCb('重命名失败！');
      print(e);
    }
  }

  static Future<void> saveNoteFile(String key, String path, String name,
      String extension, Function successCb, Function failCb) async {
    ConfigFileType config = CommonUtil.getConfigFile();

    try {
      var directory = Directory(path + "\\" + config.noteFileDirectory);
      if (!directory.existsSync()) {
        directory.createSync();
      }

      File saveFile = File(directory.path + "\\" + name + extension);

      if (!saveFile.existsSync()) {
        if (key == NoteFileSpecialTreatmentKey.excel.name) {
          var excel = Excel.createExcel();
          List<int>? fileBytes = excel.save(fileName: name + extension);
          if (fileBytes != null) {
            saveFile
              ..createSync(recursive: true)
              ..writeAsBytesSync(fileBytes);
          }
        } else if (key == NoteFileSpecialTreatmentKey.pdf.name) {
          final pdf = pw.Document();
          pdf.addPage(pw.Page(
              pageFormat: PdfPageFormat.a4,
              build: (pw.Context context) {
                return pw.Text(''); // Center
              }));
          await saveFile.writeAsBytes(await pdf.save());
        } else {
          saveFile.createSync();
        }
        successCb(saveFile.path, "创建成功！");
      } else {
        failCb("”" + name + '“已存在！');
      }
    } catch (e) {
      failCb("创建失败！");
      print(e);
    }
  }

  static void saveNoteMemoFile(String path, String extension, dynamic saveObj,
      Function successCb, Function failCb) async {
    ConfigFileType config = CommonUtil.getConfigFile();

    String directoryPath = path + "\\" + config.noteFileDirectory;
    Directory directory = Directory(directoryPath);
    if (!directory.existsSync()) {
      directory.createSync();
    }

    String filePath = directoryPath + "\\" + saveObj['memoName'] + extension;

    CommonUtil.saveFile(filePath, saveObj, successCb, failCb);
  }

  static void updateNoteMemoFile(
      String oldMemoName,
      String path,
      String extension,
      dynamic saveObj,
      Function successCb,
      Function failCb) async {
    ConfigFileType config = CommonUtil.getConfigFile();

    String oldFilePath = path +
        "\\" +
        config.noteFileDirectory +
        "\\" +
        oldMemoName +
        "." +
        extension;

    print(oldFilePath);

    File oldFile = File(oldFilePath);
    if (oldFile.existsSync()) {
      oldFile.deleteSync();
    }

    String filePath = path +
        "\\" +
        config.noteFileDirectory +
        "\\" +
        saveObj['memoName'] +
        "." +
        extension;

    CommonUtil.saveFile(filePath, saveObj, successCb, failCb);
  }

  static NoteMemoDataType getNoteMemoFile(File file) {
    String noteMemoStr = file.readAsStringSync();
    List<String> fileNames = CommonUtil.getFileNameAndExtension(file.path);
    if (noteMemoStr.isNotEmpty) {
      Map<String, dynamic> json = jsonDecode(noteMemoStr);
      return NoteMemoDataType.fromJson(json, fileNames[1]);
    } else {
      return NoteMemoDataType('', '', fileNames[1]);
    }
  }

  static Future<List<AudioDataType>> getAudioFileList(
      String path, String keyWork) async {
    List<AudioDataType> list = [];
    try {
      ConfigFileType config = CommonUtil.getConfigFile();

      var directory = Directory(path + "\\" + config.audioFileDirectory);
      if (directory.existsSync()) {
        List<FileSystemEntity> files = directory.listSync(followLinks: false);
        for (var file in files) {
          var bool = FileSystemEntity.isFileSync(file.path);

          String fileName = CommonUtil.getFileName(file);
          String urlName = fileName.split('.').first;

          if (bool &&
              CommonUtil.isAudioExtension(fileName) &&
              urlName.contains(keyWork)) {
            String id = const Uuid().v5(Uuid.NAMESPACE_URL, file.path);
            AudioDataType audioDataType =
                AudioDataType(id, fileName, file.path, false);
            list.add(audioDataType);
          }
        }
      }
    } catch (e) {
      print(e);
    }
    return list;
  }

  static Future<void> uploadAudioFile(
      String savePath,
      String filePath,
      String fileName,
      String newName,
      Function successCb,
      Function failCb) async {
    try {
      ConfigFileType config = CommonUtil.getConfigFile();

      String directoryPath = savePath + "\\" + config.audioFileDirectory;
      Directory directory = Directory(directoryPath);
      if (!directory.existsSync()) {
        directory.createSync();
      }

      String extension = CommonUtil.getFileNameAndExtension(fileName)[1];

      String renamePath = directory.path + "\\" + newName + "." + extension;

      File file = File(renamePath);
      if (!file.existsSync()) {
        File copyFile = File(filePath);
        copyFile.copySync(renamePath);
        successCb('上传音频成功！');
      } else {
        failCb('音频“' + newName + '”已存在，可重命名后上传！');
      }
    } catch (e) {
      failCb('上传音频失败！');
    }
  }

  static void audioFileMove(String fileName, String sourcePath,
      String targetPath, Function successCb, Function failCb) async {
    ConfigFileType config = CommonUtil.getConfigFile();
    Directory fileDirectory =
        Directory(targetPath + "\\" + config.audioFileDirectory);
    if (!fileDirectory.existsSync()) {
      fileDirectory.createSync();
    }

    CommonUtil.fileMove(
        sourcePath, fileDirectory.path + "\\" + fileName, successCb, failCb);
  }

  static void audioFileRename(
      String sourcePath, String newName, Function successCb, Function failCb) {
    try {
      File file = File(sourcePath);
      String targetPath = file.parent.path + "\\" + newName;

      File targetFile = File(targetPath);
      if (sourcePath == targetPath) {
        successCb("重命名成功！");
        return;
      }

      if (targetFile.existsSync()) {
        failCb(newName + '已存在！');
        return;
      }

      if (file.existsSync()) {
        file.renameSync(targetPath);
        successCb("重命名成功！");
      } else {
        failCb('重命名的音频不存在！');
      }
    } catch (e) {
      failCb('重命名失败！');
      print(e);
    }
  }

  static Future<List<OtherDataType>> getOtherFileList(
      String path, String keyWork) async {
    List<OtherDataType> list = [];
    try {
      ConfigFileType config = CommonUtil.getConfigFile();

      var directory = Directory(path + "\\" + config.otherFileDirectory);
      if (directory.existsSync()) {
        List<FileSystemEntity> files = directory.listSync(followLinks: false);
        for (var file in files) {
          var bool = FileSystemEntity.isFileSync(file.path);

          String fileName = CommonUtil.getFileName(file);
          String urlName = fileName.split('.').first;

          if (bool && urlName.contains(keyWork)) {
            String id = const Uuid().v5(Uuid.NAMESPACE_URL, file.path);
            OtherDataType otherDataType =
                OtherDataType(id, fileName, file.path, false);
            list.add(otherDataType);
          }
        }
      }
    } catch (e) {
      print(e);
    }
    return list;
  }

  static Future<void> uploadOtherFile(
      String savePath,
      String filePath,
      String fileName,
      String newName,
      Function successCb,
      Function failCb) async {
    try {
      ConfigFileType config = CommonUtil.getConfigFile();

      String directoryPath = savePath + "\\" + config.otherFileDirectory;
      Directory directory = Directory(directoryPath);
      if (!directory.existsSync()) {
        directory.createSync();
      }

      String extension = CommonUtil.getFileNameAndExtension(fileName)[1];

      String renamePath = directoryPath + "\\" + newName + "." + extension;

      File file = File(renamePath);
      if (!file.existsSync()) {
        File copyFile = File(filePath);
        copyFile.copySync(renamePath);
        successCb('上传文件成功！');
      } else {
        failCb('文件“' + newName + '”已存在，可重命名后上传！');
      }
    } catch (e) {
      failCb('上传文件失败！');
    }
  }

  static void otherFileMove(String fileName, String sourcePath,
      String targetPath, Function successCb, Function failCb) async {
    ConfigFileType config = CommonUtil.getConfigFile();
    Directory directory =
        Directory(targetPath + "\\" + config.otherFileDirectory);
    if (!directory.existsSync()) {
      directory.createSync();
    }

    CommonUtil.fileMove(
        sourcePath, directory.path + "\\" + fileName, successCb, failCb);
  }

  static void otherFileRename(
      String sourcePath, String newName, Function successCb, Function failCb) {
    try {
      File file = File(sourcePath);
      String targetPath = file.parent.path + "\\" + newName;

      File targetFile = File(targetPath);
      if (sourcePath == targetPath) {
        successCb("重命名成功！");
        return;
      }

      if (targetFile.existsSync()) {
        failCb(newName + '已存在！');
        return;
      }

      if (file.existsSync()) {
        file.renameSync(targetPath);
        successCb("重命名成功！");
      } else {
        failCb('重命名的文件不存在！');
      }
    } catch (e) {
      failCb('重命名失败！');
      print(e);
    }
  }

  static List<NoteSupportType> getNoteSupportFileList() {
    ConfigFileType config = CommonUtil.getConfigFile();
    return config.noteSupportFileList;
  }

  static NoteSupportType? getNoteSupportTypeByKey(String key) {
    for (var element in CommonUtil.getNoteSupportFileList()) {
      if (element.key == key) {
        return element;
      }
    }
    return null;
  }

  static Widget createMarkdownImgWidget(String title, String alt, String uri) {
    Map<String, dynamic> map = CommonUtil.getMarkdownImgInfo(uri.toString());
    String imgUri = map['uri'];
    bool isUrl = map['isUrl'];
    bool useDimensions = map['useDimensions'];
    double width = map['width'];
    double height = map['height'];

    if (isUrl) {
      return Tooltip(
          message: title,
          child: useDimensions
              ? Image.network(
                  imgUri,
                  width: width,
                  height: height,
                )
              : Image.network(imgUri));
    } else {
      File imgFile = File(imgUri);
      if (!imgFile.existsSync()) {
        return Text(alt);
      }

      return Tooltip(
        message: title,
        child: useDimensions
            ? Image.file(
                imgFile,
                width: width,
                height: height,
              )
            : Image.file(File(imgUri)),
      );
    }
  }

  static Map<String, dynamic> getMarkdownImgInfo(String uri) {
    Map<String, dynamic> info = {};
    int index = uri.lastIndexOf("?");
    if (index > 0) {
      List<String> list = uri.split("?");
      List<String> dimensionsList = list[1].split("x");
      if (dimensionsList.isNotEmpty) {
        if (dimensionsList.length > 1) {
          try {
            info['width'] = double.parse(dimensionsList[0]);
            info['height'] = double.parse(dimensionsList[1]);
            info['useDimensions'] = true;
          } catch (e) {
            info['useDimensions'] = false;
            info['width'] = 0.0;
            info['height'] = 0.0;
          }
        } else {
          try {
            info['width'] = double.parse(dimensionsList[0]);
            info['height'] = 0.0;
            info['useDimensions'] = true;
          } catch (e) {
            info['useDimensions'] = false;
            info['width'] = 0.0;
            info['height'] = 0.0;
          }
        }
      } else {
        info['useDimensions'] = false;
        info['width'] = 0.0;
        info['height'] = 0.0;
      }

      info['uri'] = list[0];
    } else {
      info['uri'] = uri;
      info['useDimensions'] = false;
      info['width'] = 0.0;
      info['height'] = 0.0;
    }

    info['isUrl'] = CommonUtil.isUrl(uri.toString());
    return info;
  }

  static void launchByUrl(String url) async {
    if (url.isNotEmpty) {
      try {
        //CommonUtil.shell.run("start $url");
        await launchUrlString(url);
      } catch (e) {
        CommonToast.showToast('不能打开地址“$url”!');
        print(e);
      }
    } else {
      CommonToast.showToast('地址不能为空!');
    }
  }

  static void launchFileByPath(String path) {
    CommonUtil.shell.run("start $path");
  }

  static bool isChinese(String value) {
    return RegExp(r"[\u4e00-\u9fa5]").hasMatch(value);
  }

  static bool isUrl(String value) {
    return RegExp(r"^((https|http|ftp|rtsp|mms)?:\/\/)[^\s]+").hasMatch(value);
  }

  static bool isEmail(String str) {
    return RegExp(r"^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$")
        .hasMatch(str);
  }

  static bool isFileName(String value) {
    return RegExp(r"^([\u4e00-\u9fa5|a-z|A-Z|0-9|_|-])*$").hasMatch(value);
  }

  static List<String> imgExtensionList() {
    ConfigFileType config = CommonUtil.getConfigFile();
    return config.imgExtensionList;
  }

  static List<String> videoExtensionList() {
    ConfigFileType config = CommonUtil.getConfigFile();
    return config.videoExtensionList;
  }

  static List<String> audioExtensionList() {
    ConfigFileType config = CommonUtil.getConfigFile();
    return config.audioExtensionList;
  }

  static List<String> noteExtensionList() {
    ConfigFileType config = CommonUtil.getConfigFile();
    return config.noteExtensionList;
  }

  static bool isImgExtension(String fileName) {
    for (var ele in CommonUtil.imgExtensionList()) {
      if (fileName.endsWith(ele)) {
        return true;
      }
    }

    return false;
  }

  static bool isVideoExtension(String fileName) {
    for (var ele in CommonUtil.videoExtensionList()) {
      if (fileName.endsWith(ele)) {
        return true;
      }
    }

    return false;
  }

  static bool isAudioExtension(String fileName) {
    for (var ele in CommonUtil.audioExtensionList()) {
      if (fileName.endsWith(ele)) {
        return true;
      }
    }

    return false;
  }

  static bool isNoteExtension(String fileName) {
    for (var ele in CommonUtil.noteExtensionList()) {
      if (fileName.endsWith(ele)) {
        return true;
      }
    }

    return false;
  }

  static void copyC(text) async {
    Clipboard.setData(ClipboardData(text: text));
    var clipboardData = await Clipboard.getData('text/plain');
    if (null != clipboardData && clipboardData.text!.isNotEmpty) {
      CommonToast.showToast("复制成功");
    } else {
      CommonToast.showToast("暂无内容");
    }
  }

  static void showImgViewer(context, String uri) {
    ImageProvider imageProvider = CommonUtil.isUrl(uri)
        ? Image.network(uri).image
        : Image.file(File(uri)).image;
    showImageViewer(context, imageProvider,
        backgroundColor: transparentColor2,
        closeButtonTooltip: '关闭',
        onViewerDismissed: () {});
  }
}
