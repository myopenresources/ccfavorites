import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../common/const/color_const.dart';
import '../common/const/common_const.dart';
import '../common/const/style_const.dart';
import '../common/enum/btn_enum.dart';
import '../common/type/config_file_type.dart';
import '../common/util/common_util.dart';
import '../widget/common_toast.dart';
import '../widget/dialog_container.dart';
import '../widget/directory_select.dart';
import '../widget/icon_outlined_btn.dart';

class HomeTreeDialog {
  static void showAddOrEditDialog(
      String oldDirectoryName, String directoryName, String path, Function cb) {
    TextEditingController directoryNameCtrl = TextEditingController();
    directoryNameCtrl.text = directoryName;

    SmartDialog.compatible.show(
      tag: 'homeTreeDialog',
      alignmentTemp: Alignment.center,
      backDismiss: false,
      clickBgDismissTemp: false,
      isLoadingTemp: false,
      widget: DialogContainer(
          dialogHeight: 190,
          dialogWidth: 400,
          dialogTitle: '' != oldDirectoryName ? '编辑目录' : '添加目录',
          onDialogClose: () {
            SmartDialog.dismiss(tag: 'homeTreeDialog');
          },
          dialogBodyBuilder: (context) => Container(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Column(
                  children: [
                    TextField(
                      controller: directoryNameCtrl,
                      minLines: 1,
                      maxLines: 1,
                      style: inputStyle,
                      inputFormatters: [LengthLimitingTextInputFormatter(64)],
                      decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(4),
                            ),
                            borderSide: BorderSide(
                              color: borderColor1,
                              width: 0.5, //边线宽度为2
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(4),
                              ),
                              borderSide: BorderSide(
                                color: borderColor1,
                                width: 0.5, //宽度为5
                              )),
                          isDense: true,
                          labelText: "名称：",
                          labelStyle: inputLabelStyle,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          //errorText: "",
                          hintText: "请输入名称！",
                          helperText: "格式："+isFileNameTip,
                          hintStyle: inputHintStyle,
                          helperStyle: inputHelperStyle,
                          alignLabelWithHint: true,
                          prefixText: '名称：'),
                    )
                  ],
                ),
              ),
          dialogFooterBuilder: (context) => Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconOutlinedBtn(
                      text: '确认',
                      icon: Icons.check,
                      btnType: BtnType.primary,
                      onPressed: () {
                        if (directoryNameCtrl.value.text.trim().isEmpty) {
                          CommonToast.showToast("请输入名称！");
                          return;
                        }

                        if (!CommonUtil.isFileName(
                            directoryNameCtrl.value.text.trim())) {
                          CommonToast.showToast(isFileNameTip);
                          return;
                        }

                        if (oldDirectoryName.isNotEmpty) {
                          String newPath = CommonUtil.getParentDirectory(path) +
                              "\\" +
                              directoryNameCtrl.value.text.trim();

                          CommonUtil.updateDirectory(path, newPath, (msg) {
                            CommonToast.showToast(msg);
                            SmartDialog.dismiss(tag: 'homeTreeDialog');
                            cb(directoryNameCtrl.value.text.trim());
                          }, (msg) {
                            CommonToast.showToast(msg);
                            SmartDialog.dismiss(tag: 'homeTreeDialog');
                          });
                        } else {
                          CommonUtil.saveDirectory(
                              path + "\\" + directoryNameCtrl.value.text.trim(),
                              (msg) {
                            CommonToast.showToast(msg);
                            SmartDialog.dismiss(tag: 'homeTreeDialog');
                            cb(directoryNameCtrl.value.text.trim());
                          }, (msg) {
                            CommonToast.showToast(msg);
                            SmartDialog.dismiss(tag: 'homeTreeDialog');
                          });
                        }
                      }),
                  Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: IconOutlinedBtn(
                          text: '关闭',
                          icon: Icons.close,
                          btnType: BtnType.gray,
                          onPressed: () {
                            SmartDialog.dismiss(tag: 'homeTreeDialog');
                          }))
                ],
              )),
    );
  }

  static Future<void> showSettingDialog(Function cb) async {
    String dataSaveInitPath =  CommonUtil.getAppDataSavePath();
    ConfigFileType configFileType =  CommonUtil.getConfigFile();
    String dataPath = configFileType.dataPath;
    String delMovePath = configFileType.delMovePath;

    void saveSetting() {
      if (dataPath.isEmpty) {
        CommonToast.showToast('数据存储目录不能为空！');
        return;
      }

      configFileType.dataPath = dataPath;
      configFileType.delMovePath = delMovePath;
      CommonUtil.updateConfigFile(configFileType);
      SmartDialog.dismiss(tag: 'homeAppSettingDialog');
      CommonToast.showToast('保存成功！');
      cb();
    }

    SmartDialog.compatible.show(
      tag: 'homeAppSettingDialog',
      alignmentTemp: Alignment.center,
      backDismiss: false,
      clickBgDismissTemp: false,
      isLoadingTemp: false,
      widget: DialogContainer(
          dialogHeight: 320,
          dialogWidth: 600,
          dialogTitle: '应用设置',
          onDialogClose: () {
            SmartDialog.dismiss(tag: 'homeAppSettingDialog');
          },
          dialogBodyBuilder: (context) => Container(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                alignment: Alignment.topLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      child: const Text(
                        '存储目录设置',
                        style: appSettingLineTitleStyle,
                      ),
                    ),
                    Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        child: DirectorySelect(
                            value: dataPath,
                            initialDirectory: dataSaveInitPath,
                            label: "数据存储目录：",
                            helperText: "格式：系统中有权限访问的目录路径！",
                            onChanged: (path) {
                              dataPath = path;
                            })),
                    DirectorySelect(
                        value: delMovePath,
                        initialDirectory: dataSaveInitPath,
                        label: "删除存储目录：",
                        helperText: "格式：系统中有权限访问的目录路径，清空则删除文件或目录后不移入到删除存储目录！",
                        onChanged: (path) {
                          delMovePath = path;
                        }),
                  ],
                ),
              ),
          dialogFooterBuilder: (context) => Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconOutlinedBtn(
                      text: '确认',
                      icon: Icons.check,
                      btnType: BtnType.primary,
                      onPressed: () {
                        saveSetting();
                      }),
                  Padding(
                      padding: const EdgeInsets.only(right: 10.0, left: 10.0),
                      child: IconOutlinedBtn(
                          text: '关闭',
                          icon: Icons.close,
                          btnType: BtnType.gray,
                          onPressed: () {
                            SmartDialog.dismiss(tag: 'homeAppSettingDialog');
                          }))
                ],
              )),
    );
  }
}
