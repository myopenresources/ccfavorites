import 'package:flutter/material.dart';

import '../enum/home_enum.dart';

class OtherDataType {
  String id;
  String fileName;
  String filePath;
  bool selected;

  OtherDataType(this.id, this.fileName, this.filePath, this.selected);
}

class OtherUploadDataType {
  String fileName;
  String filePath;
  TextEditingController controller;
  bool showLoading;
  FileDataUploadState uploadState;
  String uploadMsg;

  OtherUploadDataType(this.fileName, this.filePath, this.controller,
      this.showLoading, this.uploadState, this.uploadMsg);
}
