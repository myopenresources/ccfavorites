import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class CommonToast {
  static void showToast(String msg) {
    SmartDialog.compatible.showToast(msg,time:const Duration(milliseconds: 1500));
  }
}
