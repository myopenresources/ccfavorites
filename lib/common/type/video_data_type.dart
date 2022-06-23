import 'package:flutter/material.dart';

import '../enum/home_enum.dart';

class VideoDataType {
  String id;
  String fileName;
  String filePath;
  bool selected;

  VideoDataType(this.id, this.fileName, this.filePath, this.selected);
}

class VideoUploadDataType {
  String fileName;
  String filePath;
  TextEditingController controller;
  bool showLoading;
  FileDataUploadState uploadState;
  String uploadMsg;

  VideoUploadDataType(this.fileName, this.filePath, this.controller,
      this.showLoading, this.uploadState, this.uploadMsg);
}
