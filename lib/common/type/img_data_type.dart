import 'package:flutter/material.dart';

import '../enum/home_enum.dart';

class ImgDataType {
  String id;
  String fileName;
  String filePath;
  bool selected;

  ImgDataType(this.id, this.fileName, this.filePath, this.selected);
}

class ImgUploadDataType {
  String fileName;
  String filePath;
  TextEditingController controller;
  bool showLoading;
  FileDataUploadState uploadState;
  String uploadMsg;

  ImgUploadDataType(this.fileName, this.filePath, this.controller,
      this.showLoading, this.uploadState, this.uploadMsg);
}
