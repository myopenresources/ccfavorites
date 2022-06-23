class NoteSupportType {
  String key;
  String label;
  String extension;

  NoteSupportType(this.key, this.label, this.extension);
}

class ConfigFileType {
  String dataPath;
  List<String> reservedDirectoryList;
  String linkFileDirectory;
  String imgFileDirectory;
  String videoFileDirectory;
  String audioFileDirectory;
  String noteFileDirectory;
  String otherFileDirectory;
  String delMovePath;
  List<String> imgExtensionList;
  List<String> videoExtensionList;
  List<String> audioExtensionList;
  List<String> noteExtensionList;
  List<NoteSupportType> noteSupportFileList;

  ConfigFileType(
      this.dataPath,
      this.reservedDirectoryList,
      this.linkFileDirectory,
      this.noteFileDirectory,
      this.imgFileDirectory,
      this.videoFileDirectory,
      this.audioFileDirectory,
      this.otherFileDirectory,
      this.delMovePath,
      this.imgExtensionList,
      this.videoExtensionList,
      this.audioExtensionList,
      this.noteExtensionList,
      this.noteSupportFileList,
      );

  factory ConfigFileType.fromJson(Map<String, dynamic> json) {
    List<String> reservedDirectoryList =
        (json['reservedDirectoryList'] as List<dynamic>).cast<String>();

    List<String> imgExtensionList =
        (json['imgExtensionList'] as List<dynamic>).cast<String>();

    List<String> videoExtensionList =
        (json['videoExtensionList'] as List<dynamic>).cast<String>();

    List<String> audioExtensionList =
        (json['audioExtensionList'] as List<dynamic>).cast<String>();

    List<String> noteExtensionList =
        (json['noteExtensionList'] as List<dynamic>).cast<String>();

    List<NoteSupportType> noteSupportFileList = [];
    for (var support in json['noteSupportFileList']) {
      noteSupportFileList.add(NoteSupportType(
          support['key'], support['label'], support['extension']));
    }

    return ConfigFileType(
        json['dataPath'],
        reservedDirectoryList,
        json['linkFileDirectory'],
        json['noteFileDirectory'],
        json['imgFileDirectory'],
        json['videoFileDirectory'],
        json['audioFileDirectory'],
        json['otherFileDirectory'],
        json['delMovePath'],
        imgExtensionList,
        videoExtensionList,
        audioExtensionList,
        noteExtensionList,
        noteSupportFileList);
  }

  Map<String, dynamic> toJson() {
    ConfigFileType instance = this;

    List<Map<String, dynamic>> noteSupportFileList = [];

    for (var element in instance.noteSupportFileList) {
      noteSupportFileList.add({
        "key": element.key,
        "label": element.label,
        "extension": element.extension
      });
    }

    Map<String, dynamic> json = {
      "dataPath": instance.dataPath,
      "reservedDirectoryList": instance.reservedDirectoryList,
      "linkFileDirectory": instance.linkFileDirectory,
      "imgFileDirectory": instance.imgFileDirectory,
      "videoFileDirectory": instance.videoFileDirectory,
      "audioFileDirectory": instance.audioFileDirectory,
      "noteFileDirectory": instance.noteFileDirectory,
      "otherFileDirectory": instance.otherFileDirectory,
      "delMovePath": instance.delMovePath,
      "imgExtensionList": instance.imgExtensionList,
      "videoExtensionList": instance.videoExtensionList,
      "audioExtensionList": instance.audioExtensionList,
      "noteExtensionList": instance.noteExtensionList,
      "noteSupportFileList": noteSupportFileList
    };
    return json;
  }
}
