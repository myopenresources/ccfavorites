import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../common/const/color_const.dart';
import '../common/enum/btn_enum.dart';
import 'dialog_container.dart';
import 'icon_outlined_btn.dart';

class CommonConfirmDialog {
  /*static void showConfirmDialog2(
      BuildContext context,
      String content,
      Function confirmCallback,
      Function cancelCallback,
      String btnTxt,
      String btn2Txt) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              "提示",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            content: Text(content, style: const TextStyle(fontSize: 14)),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  confirmCallback(() => {Navigator.of(context).pop()});
                },
                child: Text('' != btnTxt ? btnTxt : "确认"),
              ),
              TextButton(
                onPressed: () {
                  cancelCallback(() => {Navigator.of(context).pop()});
                },
                child: Text('' != btn2Txt ? btn2Txt : "取消"),
              ),
            ],
          );
        });
  }*/

  static void showCustomConfirmDialog(
    String tag,
    double dialogWidth,
    double dialogHeight,
    String content,
    Function confirmCallback,
    Function cancelCallback,
    String btnTxt,
    String btn2Txt,
  ) {
    SmartDialog.compatible.show(
      tag: tag,
      backDismiss: false,
      clickBgDismissTemp: false,
      isLoadingTemp: false,
      widget: DialogContainer(
          dialogHeight: dialogHeight,
          dialogWidth: dialogWidth,
          dialogPadding: 20,
          dialogHeaderCloseBtn: false,
          dialogHeaderBorderColor: transparentColor1,
          dialogFooterBorderColor: transparentColor1,
          dialogTitle: '提示',
          onDialogClose: () {
            SmartDialog.dismiss(tag: tag);
          },
          dialogBodyBuilder: (context) => Container(
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Text(content),
              ),
          dialogFooterBuilder: (context) => Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      confirmCallback(() => {SmartDialog.dismiss(tag: tag)});
                    },
                    child: Text('' != btnTxt ? btnTxt : "确认"),
                  ),
                  TextButton(
                    onPressed: () {
                      cancelCallback(() => {SmartDialog.dismiss(tag: tag)});
                    },
                    child: Text('' != btn2Txt ? btn2Txt : "取消"),
                  ),
                ],
              )),
    );
  }
}
