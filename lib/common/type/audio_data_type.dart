import 'package:flutter/material.dart';

import '../enum/home_enum.dart';

class AudioDataType {
  String id;
  String fileName;
  String filePath;
  bool selected;

  AudioDataType(this.id, this.fileName, this.filePath, this.selected);
}

class AudioUploadDataType {
  String fileName;
  String filePath;
  TextEditingController controller;
  bool showLoading;
  FileDataUploadState uploadState;
  String uploadMsg;

  AudioUploadDataType(this.fileName, this.filePath, this.controller,
      this.showLoading, this.uploadState, this.uploadMsg);
}
