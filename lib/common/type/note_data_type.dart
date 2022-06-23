import 'package:flutter/material.dart';

import '../enum/home_enum.dart';

class NoteDataType {
  String id;
  String fileName;
  String filePath;
  bool selected;

  NoteDataType(this.id, this.fileName, this.filePath, this.selected);
}

class NoteUploadDataType {
  String fileName;
  String filePath;
  TextEditingController controller;
  bool showLoading;
  FileDataUploadState uploadState;
  String uploadMsg;

  NoteUploadDataType(this.fileName, this.filePath, this.controller,
      this.showLoading, this.uploadState, this.uploadMsg);
}

class NoteMemoDataType {
  String memoName;
  String data;
  String extension;

  NoteMemoDataType(this.memoName, this.data,this.extension);

  factory NoteMemoDataType.fromJson(Map<String, dynamic> json,String extension) {
    return NoteMemoDataType(json['memoName'],json['data'],extension);
  }
}
