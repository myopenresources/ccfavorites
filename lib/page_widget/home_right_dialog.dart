import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

import '../common/const/color_const.dart';
import '../common/const/common_const.dart';
import '../common/const/style_const.dart';
import '../common/enum/btn_enum.dart';
import '../common/type/link_data_type.dart';
import '../common/util/common_util.dart';
import '../widget/common_toast.dart';
import '../widget/dialog_container.dart';
import '../widget/icon_outlined_btn.dart';
import 'home_audio_upload.dart';
import 'home_img_upload.dart';
import 'home_note_upload.dart';
import 'home_other_upload.dart';
import 'home_video_upload.dart';

class HomeLinkDataDialog {
  static void showAddOrEditDialog(String oldUrlName, String urlName, String url,
      String remarks, String path, Function cb) {
    TextEditingController urlNameCtrl = TextEditingController();
    TextEditingController urlCtrl = TextEditingController();
    TextEditingController remarksCtrl = TextEditingController();
    urlNameCtrl.text = urlName;
    urlCtrl.text = url;
    remarksCtrl.text = remarks;

    String tag = 'homeLinkDataListAddDialog';

    SmartDialog.compatible.show(
      tag: tag,
      alignmentTemp: Alignment.center,
      backDismiss: false,
      clickBgDismissTemp: false,
      isLoadingTemp: false,
      widget: DialogContainer(
          dialogWidth: 450,
          dialogHeight: 450,
          dialogTitle: '' != oldUrlName ? '编辑书签' : '添加书签',
          onDialogClose: () {
            SmartDialog.dismiss(tag: tag);
          },
          dialogBodyBuilder: (context) => Container(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Column(
                  children: [
                    TextField(
                      controller: urlNameCtrl,
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
                          helperText: "格式：" + isFileNameTip,
                          hintStyle: inputHintStyle,
                          helperStyle: inputHelperStyle,
                          alignLabelWithHint: true,
                          prefixText: '名称：'),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: TextField(
                        controller: urlCtrl,
                        minLines: 5,
                        maxLines: 5,
                        style: inputStyle,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(300) //限制长度
                        ],
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
                            labelText: "链接：",
                            labelStyle: inputLabelStyle,
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            //errorText: "",
                            helperText: "格式：合法的URL地址，并且不超过300个字符！",
                            hintText: "请输入链接！",
                            hintStyle: inputHintStyle,
                            helperStyle: inputHelperStyle,
                            alignLabelWithHint: true,
                            prefixText: '链接：'),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: TextField(
                        controller: remarksCtrl,
                        minLines: 5,
                        maxLines: 5,
                        style: inputStyle,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(300) //限制长度
                        ],
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
                            labelText: "备注：",
                            labelStyle: inputLabelStyle,
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            //errorText: "",
                            helperText: "格式：内容不超过300个字符！",
                            hintText: "请输入备注！",
                            hintStyle: inputHintStyle,
                            helperStyle: inputHelperStyle,
                            alignLabelWithHint: true,
                            prefixText: '备注：'),
                      ),
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
                        if (urlNameCtrl.value.text.trim().isEmpty) {
                          CommonToast.showToast("请输入名称！");
                          return;
                        }

                        if (!CommonUtil.isFileName(
                            urlNameCtrl.value.text.trim())) {
                          CommonToast.showToast(isFileNameTip);
                          return;
                        }

                        if (urlCtrl.value.text.trim().isEmpty) {
                          CommonToast.showToast("请输入链接！");
                          return;
                        }

                        if (oldUrlName.isNotEmpty) {
                          CommonUtil.updateLinkFile(oldUrlName, path, {
                            "urlName": urlNameCtrl.value.text.trim(),
                            "url": urlCtrl.value.text,
                            "remarks": remarksCtrl.value.text
                          }, (msg) {
                            CommonToast.showToast(msg);
                            SmartDialog.dismiss(tag: tag);
                            cb();
                          }, (msg) {
                            CommonToast.showToast(msg);
                            SmartDialog.dismiss(tag: tag);
                          });
                        } else {
                          CommonUtil.saveLinkFile(path, {
                            "urlName": urlNameCtrl.value.text.trim(),
                            "url": urlCtrl.value.text,
                            "remarks": remarksCtrl.value.text
                          }, (msg) {
                            CommonToast.showToast(msg);
                            SmartDialog.dismiss(tag: tag);
                            cb();
                          }, (msg) {
                            CommonToast.showToast(msg);
                            SmartDialog.dismiss(tag: tag);
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
                            SmartDialog.dismiss(tag: tag);
                          }))
                ],
              )),
    );
  }

  static void showDetailDialog(LinkDataType data) {
    String tag = 'homeLinkDataListDetailDialog';
    TextEditingController urlNameCtrl = TextEditingController();
    TextEditingController urlCtrl = TextEditingController();
    TextEditingController remarksCtrl = TextEditingController();
    urlNameCtrl.text = data.urlName;
    urlCtrl.text = data.url;
    remarksCtrl.text = data.remarks;

    void openLink() {
      CommonUtil.launchByUrl(data.url);
    }

    void copyLink() {
      CommonUtil.copyC(data.url);
    }

    SmartDialog.compatible.show(
      tag: tag,
      alignmentTemp: Alignment.center,
      backDismiss: false,
      clickBgDismissTemp: false,
      isLoadingTemp: false,
      widget: DialogContainer(
          dialogWidth: 450,
          dialogHeight: 450,
          dialogTitle: '查看书签',
          onDialogClose: () {
            SmartDialog.dismiss(tag: tag);
          },
          dialogBodyBuilder: (context) => Container(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Column(
                  children: [
                    TextField(
                      controller: urlNameCtrl,
                      minLines: 3,
                      maxLines: 3,
                      style: inputStyle,
                      inputFormatters: [LengthLimitingTextInputFormatter(64)],
                      onChanged: (val) {
                        urlNameCtrl.text = data.urlName;
                      },
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
                          hintStyle: inputHintStyle,
                          helperStyle: inputHelperStyle,
                          alignLabelWithHint: true,
                          prefixText: '名称：'),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: TextField(
                        controller: urlCtrl,
                        minLines: 6,
                        maxLines: 6,
                        style: inputStyle,
                        onChanged: (val) {
                          urlCtrl.text = data.url;
                        },
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(300) //限制长度
                        ],
                        decoration: InputDecoration(
                            counter: Row(
                              children: [
                                const Spacer(),
                                Container(
                                    margin: const EdgeInsets.only(right: 12.0),
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.copy,
                                      child: GestureDetector(
                                        onTap: copyLink,
                                        child: const Text(
                                          '复制链接',
                                          style: linkStyle,
                                        ),
                                      ),
                                    )),
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: openLink,
                                    child: const Text(
                                      '打开链接',
                                      style: linkStyle,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(4),
                              ),
                              borderSide: BorderSide(
                                color: borderColor1,
                                width: 0.5, //边线宽度为2
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(4),
                                ),
                                borderSide: BorderSide(
                                  color: borderColor1,
                                  width: 0.5, //宽度为5
                                )),
                            isDense: true,
                            labelText: "链接：",
                            labelStyle: inputLabelStyle,
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            //errorText: "",
                            hintStyle: inputHintStyle,
                            helperStyle: inputHelperStyle,
                            alignLabelWithHint: true,
                            prefixText: '链接：'),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: TextField(
                        controller: remarksCtrl,
                        minLines: 6,
                        maxLines: 6,
                        style: inputStyle,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(300) //限制长度
                        ],
                        onChanged: (val) {
                          remarksCtrl.text = data.remarks;
                        },
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
                            labelText: "备注：",
                            labelStyle: inputLabelStyle,
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            //errorText: "",
                            hintStyle: inputHintStyle,
                            helperStyle: inputHelperStyle,
                            alignLabelWithHint: true,
                            prefixText: '备注：'),
                      ),
                    )
                  ],
                ),
              ),
          dialogFooterBuilder: (context) => Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: IconOutlinedBtn(
                          text: '关闭',
                          icon: Icons.close,
                          btnType: BtnType.gray,
                          onPressed: () {
                            SmartDialog.dismiss(tag: tag);
                          }))
                ],
              )),
    );
  }
}

class HomeImgDataDialog {
  static void showRenameDialog(String path, String name, Function cb) {
    TextEditingController fileNameCtrl = TextEditingController();
    fileNameCtrl.text = CommonUtil.getFileNameAndExtension(name).first;
    String tag = 'homeImgDataListRenameDialog';

    SmartDialog.compatible.show(
      tag: tag,
      alignmentTemp: Alignment.center,
      backDismiss: false,
      clickBgDismissTemp: false,
      isLoadingTemp: false,
      widget: DialogContainer(
          dialogHeight: 200,
          dialogWidth: 400,
          dialogTitle: '重命名',
          onDialogClose: () {
            SmartDialog.dismiss(tag: tag);
          },
          dialogBodyBuilder: (context) => Container(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Column(
                  children: [
                    TextField(
                      controller: fileNameCtrl,
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
                          helperText: "格式：" + isFileNameTip,
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
                        if (fileNameCtrl.value.text.trim().isEmpty) {
                          CommonToast.showToast("请输入名称！");
                          return;
                        }

                        if (!CommonUtil.isFileName(
                            fileNameCtrl.value.text.trim())) {
                          CommonToast.showToast(isFileNameTip);
                          return;
                        }

                        String fileName = fileNameCtrl.text.trim() +
                            "." +
                            CommonUtil.getFileNameAndExtension(name).last;

                        CommonUtil.imgFileRename(path, fileName, (msg) {
                          CommonToast.showToast(msg);
                          SmartDialog.dismiss(tag: tag);
                          cb();
                        }, (msg) {
                          CommonToast.showToast(msg);
                          SmartDialog.dismiss(tag: tag);
                        });
                      }),
                  Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: IconOutlinedBtn(
                          text: '关闭',
                          icon: Icons.close,
                          btnType: BtnType.gray,
                          onPressed: () {
                            SmartDialog.dismiss(tag: tag);
                          }))
                ],
              )),
    );
  }

  static void showSelectImgDialog(String path, Function cb) {
    String tag = 'homeImgDataListUploadDialog';
    SmartDialog.compatible.show(
      tag: tag,
      alignmentTemp: Alignment.center,
      backDismiss: false,
      clickBgDismissTemp: false,
      isLoadingTemp: false,
      widget: HomeImgUpload(tag: tag, savePath: path, onClose: cb),
    );
  }
}

class HomeVideoDataDialog {
  static void showRenameDialog(String path, String name, Function cb) {
    TextEditingController fileNameCtrl = TextEditingController();
    fileNameCtrl.text = CommonUtil.getFileNameAndExtension(name).first;
    String tag = 'homeVideoDataListRenameDialog';

    SmartDialog.compatible.show(
      tag: tag,
      alignmentTemp: Alignment.center,
      backDismiss: false,
      clickBgDismissTemp: false,
      isLoadingTemp: false,
      widget: DialogContainer(
          dialogHeight: 200,
          dialogWidth: 400,
          dialogTitle: '重命名',
          onDialogClose: () {
            SmartDialog.dismiss(tag: tag);
          },
          dialogBodyBuilder: (context) => Container(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Column(
                  children: [
                    TextField(
                      controller: fileNameCtrl,
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
                          helperText: "格式：" + isFileNameTip,
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
                        if (fileNameCtrl.value.text.trim().isEmpty) {
                          CommonToast.showToast("请输入名称！");
                          return;
                        }

                        if (!CommonUtil.isFileName(
                            fileNameCtrl.value.text.trim())) {
                          CommonToast.showToast(isFileNameTip);
                          return;
                        }

                        String fileName = fileNameCtrl.text.trim() +
                            "." +
                            CommonUtil.getFileNameAndExtension(name).last;

                        CommonUtil.videoFileRename(path, fileName, (msg) {
                          CommonToast.showToast(msg);
                          SmartDialog.dismiss(tag: tag);
                          cb();
                        }, (msg) {
                          CommonToast.showToast(msg);
                          SmartDialog.dismiss(tag: tag);
                        });
                      }),
                  Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: IconOutlinedBtn(
                          text: '关闭',
                          icon: Icons.close,
                          btnType: BtnType.gray,
                          onPressed: () {
                            SmartDialog.dismiss(tag: tag);
                          }))
                ],
              )),
    );
  }

  static void showSelectVideoDialog(String path, Function cb) {
    String tag = 'homeVideoDataListUploadDialog';
    SmartDialog.compatible.show(
      tag: tag,
      alignmentTemp: Alignment.center,
      backDismiss: false,
      clickBgDismissTemp: false,
      isLoadingTemp: false,
      widget: HomeVideoUpload(tag: tag, savePath: path, onClose: cb),
    );
  }
}

class HomeAudioDataDialog {
  static void showRenameDialog(String path, String name, Function cb) {
    TextEditingController fileNameCtrl = TextEditingController();
    fileNameCtrl.text = CommonUtil.getFileNameAndExtension(name).first;
    String tag = 'homeAudioDataListRenameDialog';

    SmartDialog.compatible.show(
      tag: tag,
      alignmentTemp: Alignment.center,
      backDismiss: false,
      clickBgDismissTemp: false,
      isLoadingTemp: false,
      widget: DialogContainer(
          dialogHeight: 200,
          dialogWidth: 400,
          dialogTitle: '重命名',
          onDialogClose: () {
            SmartDialog.dismiss(tag: tag);
          },
          dialogBodyBuilder: (context) => Container(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Column(
                  children: [
                    TextField(
                      controller: fileNameCtrl,
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
                          helperText: "格式：" + isFileNameTip,
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
                        if (fileNameCtrl.value.text.trim().isEmpty) {
                          CommonToast.showToast("请输入名称！");
                          return;
                        }

                        if (!CommonUtil.isFileName(
                            fileNameCtrl.value.text.trim())) {
                          CommonToast.showToast(isFileNameTip);
                          return;
                        }

                        String fileName = fileNameCtrl.text.trim() +
                            "." +
                            CommonUtil.getFileNameAndExtension(name).last;

                        CommonUtil.audioFileRename(path, fileName, (msg) {
                          CommonToast.showToast(msg);
                          SmartDialog.dismiss(tag: tag);
                          cb();
                        }, (msg) {
                          CommonToast.showToast(msg);
                          SmartDialog.dismiss(tag: tag);
                        });
                      }),
                  Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: IconOutlinedBtn(
                          text: '关闭',
                          icon: Icons.close,
                          btnType: BtnType.gray,
                          onPressed: () {
                            SmartDialog.dismiss(tag: tag);
                          }))
                ],
              )),
    );
  }

  static void showSelectAudioDialog(String path, Function cb) {
    String tag = 'homeAudioDataListUploadDialog';
    SmartDialog.compatible.show(
      tag: tag,
      alignmentTemp: Alignment.center,
      backDismiss: false,
      clickBgDismissTemp: false,
      isLoadingTemp: false,
      widget: HomeAudioUpload(tag: tag, savePath: path, onClose: cb),
    );
  }
}

class HomeNoteDataDialog {
  static void showAddDialog(
      String key, String title, String path, String extension, Function cb) {
    TextEditingController fileNameCtrl = TextEditingController();
    fileNameCtrl.text = '';
    String tag = 'homeNoteDataListAddDialog';

    void createFile(Function createSuccess) {
      if (fileNameCtrl.value.text.trim().isEmpty) {
        CommonToast.showToast("请输入名称！");
        return;
      }

      if (!CommonUtil.isFileName(fileNameCtrl.value.text.trim())) {
        CommonToast.showToast(isFileNameTip);
        return;
      }

      CommonUtil.saveNoteFile(
          key, path, fileNameCtrl.value.text.trim(), extension,
          (String filePath, String msg) {
        CommonToast.showToast(msg);
        createSuccess(filePath);
        cb();
        SmartDialog.dismiss(tag: tag);
      }, (msg) {
        CommonToast.showToast(msg);
        SmartDialog.dismiss(tag: tag);
      });
    }

    SmartDialog.compatible.show(
      tag: tag,
      alignmentTemp: Alignment.center,
      backDismiss: false,
      clickBgDismissTemp: false,
      isLoadingTemp: false,
      widget: DialogContainer(
          dialogHeight: 200,
          dialogWidth: 400,
          dialogTitle: title,
          onDialogClose: () {
            SmartDialog.dismiss(tag: tag);
          },
          dialogBodyBuilder: (context) => Container(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Column(
                  children: [
                    TextField(
                      controller: fileNameCtrl,
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
                          helperText: "格式：" + isFileNameTip,
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
                        createFile((String filePath) {});
                      }),
                  Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: IconOutlinedBtn(
                          text: '确认并打开',
                          icon: Icons.check,
                          btnType: BtnType.primary,
                          onPressed: () {
                            createFile((String filePath) {
                              CommonUtil.launchFileByPath(filePath);
                            });
                          })),
                  Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: IconOutlinedBtn(
                          text: '关闭',
                          icon: Icons.close,
                          btnType: BtnType.gray,
                          onPressed: () {
                            SmartDialog.dismiss(tag: tag);
                          }))
                ],
              )),
    );
  }

  static void showRenameDialog(String path, String name, Function cb) {
    TextEditingController fileNameCtrl = TextEditingController();
    fileNameCtrl.text = CommonUtil.getFileNameAndExtension(name).first;
    String tag = 'homeNoteDataListRenameDialog';

    SmartDialog.compatible.show(
      tag: tag,
      alignmentTemp: Alignment.center,
      backDismiss: false,
      clickBgDismissTemp: false,
      isLoadingTemp: false,
      widget: DialogContainer(
          dialogHeight: 200,
          dialogWidth: 400,
          dialogTitle: '重命名',
          onDialogClose: () {
            SmartDialog.dismiss(tag: tag);
          },
          dialogBodyBuilder: (context) => Container(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Column(
                  children: [
                    TextField(
                      controller: fileNameCtrl,
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
                          helperText: "格式：" + isFileNameTip,
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
                        if (fileNameCtrl.value.text.trim().isEmpty) {
                          CommonToast.showToast("请输入名称！");
                          return;
                        }

                        if (!CommonUtil.isFileName(
                            fileNameCtrl.value.text.trim())) {
                          CommonToast.showToast(isFileNameTip);
                          return;
                        }

                        String fileName = fileNameCtrl.text.trim() +
                            "." +
                            CommonUtil.getFileNameAndExtension(name).last;

                        CommonUtil.noteFileRename(path, fileName, (msg) {
                          CommonToast.showToast(msg);
                          SmartDialog.dismiss(tag: tag);
                          cb();
                        }, (msg) {
                          CommonToast.showToast(msg);
                          SmartDialog.dismiss(tag: tag);
                        });
                      }),
                  Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: IconOutlinedBtn(
                          text: '关闭',
                          icon: Icons.close,
                          btnType: BtnType.gray,
                          onPressed: () {
                            SmartDialog.dismiss(tag: tag);
                          }))
                ],
              )),
    );
  }

  static void showSelectNoteDialog(String path, Function cb) {
    String tag = 'homeNoteDataListUploadDialog';
    SmartDialog.compatible.show(
      tag: tag,
      alignmentTemp: Alignment.center,
      backDismiss: false,
      clickBgDismissTemp: false,
      isLoadingTemp: false,
      widget: HomeNoteUpload(tag: tag, savePath: path, onClose: cb),
    );
  }

  static void showAddOrEditMemoDialog(String oldMemoName, String newMemoName,
      String extension, String data, String path, Function cb) {
    TextEditingController memoNameCtrl = TextEditingController();
    TextEditingController dataCtrl = TextEditingController();
    memoNameCtrl.text = newMemoName;
    dataCtrl.text = data;

    String tag = 'homeNoteDataListAddMemoDialog';

    String mdData = dataCtrl.text;

    double dialogWidth = 950;
    double dataWidgetWidth = (dialogWidth - 30) / 2;
    double dataWidgetHeight = 466;

    void save(bool close) {
      if (memoNameCtrl.value.text.trim().isEmpty) {
        CommonToast.showToast("请输入名称！");
        return;
      }

      if (!CommonUtil.isFileName(memoNameCtrl.value.text.trim())) {
        CommonToast.showToast(isFileNameTip);
        return;
      }

      if (oldMemoName.isNotEmpty) {
        CommonUtil.updateNoteMemoFile(oldMemoName, path, extension, {
          "memoName": memoNameCtrl.value.text.trim(),
          "data": dataCtrl.value.text
        }, (msg) {
          CommonToast.showToast(msg);
          if (close) {
            SmartDialog.dismiss(tag: tag);
          }
          cb();
        }, (msg) {
          CommonToast.showToast(msg);
          if (close) {
            SmartDialog.dismiss(tag: tag);
          }
        });
      } else {
        CommonUtil.saveNoteMemoFile(path, extension, {
          "memoName": memoNameCtrl.value.text.trim(),
          "data": dataCtrl.value.text
        }, (msg) {
          CommonToast.showToast(msg);
          SmartDialog.dismiss(tag: tag);
          cb();
        }, (msg) {
          CommonToast.showToast(msg);
          SmartDialog.dismiss(tag: tag);
        });
      }
    }

    SmartDialog.compatible.show(
        tag: tag,
        alignmentTemp: Alignment.center,
        backDismiss: false,
        clickBgDismissTemp: false,
        isLoadingTemp: false,
        widget: StatefulBuilder(builder: (BuildContext statefulContext,
            void Function(void Function()) statefulSetState) {
          return DialogContainer(
              dialogWidth: dialogWidth,
              dialogHeight: 680,
              dialogTitle: '' != oldMemoName ? '编辑备忘' : '添加备忘',
              onDialogClose: () {
                SmartDialog.dismiss(tag: tag);
              },
              dialogBodyBuilder: (context) => Container(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Column(
                      children: [
                        TextField(
                          controller: memoNameCtrl,
                          minLines: 1,
                          maxLines: 1,
                          style: inputStyle,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(64)
                          ],
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
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              //errorText: "",
                              hintText: "请输入名称！",
                              helperText: "格式：" + isFileNameTip,
                              hintStyle: inputHintStyle,
                              helperStyle: inputHelperStyle,
                              alignLabelWithHint: true,
                              prefixText: '名称：'),
                        ),
                        Container(
                          width: dialogWidth - 20,
                          margin: const EdgeInsets.only(top: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: dataWidgetWidth,
                                child: TextField(
                                  controller: dataCtrl,
                                  minLines: 34,
                                  maxLines: 34,
                                  style: inputStyle,
                                  onChanged: (val) {
                                    statefulSetState(() {
                                      mdData = val;
                                    });
                                  },
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(5000)
                                    //限制长度
                                  ],
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
                                      labelText: "内容：",
                                      labelStyle: inputLabelStyle,
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.never,
                                      //errorText: "",
                                      helperText: "格式：内容不超过5000个字符！",
                                      hintText: "请输入内容！",
                                      hintStyle: inputHintStyle,
                                      helperStyle: inputHelperStyle,
                                      alignLabelWithHint: true,
                                      prefixText: '内容：'),
                                ),
                              ),
                              Container(
                                width: dataWidgetWidth,
                                height: dataWidgetHeight,
                                margin: const EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                  color: whiteColor,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(4),
                                  ),
                                  border: Border.all(
                                      color: borderColor1, width: 0.5),
                                ),
                                child: Markdown(
                                  data: mdData,
                                  selectable: true,
                                  imageBuilder:
                                      (Uri uri, String? title, String? alt) {
                                    return CommonUtil.createMarkdownImgWidget(
                                        title ?? '', alt ?? '', uri.toString());
                                  },
                                  onTapLink: (String text, String? href,
                                          String title) =>
                                      {CommonUtil.launchByUrl(href!)},
                                  extensionSet: md.ExtensionSet(
                                    md.ExtensionSet.gitHubFlavored
                                        .blockSyntaxes,
                                    [
                                      md.EmojiSyntax(),
                                      ...md.ExtensionSet.gitHubFlavored
                                          .inlineSyntaxes
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
              dialogFooterBuilder: (context) => Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if ('' != oldMemoName)
                        Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: IconOutlinedBtn(
                                text: '保存',
                                icon: Icons.save,
                                btnType: BtnType.primary,
                                onPressed: () {
                                  save(false);
                                })),
                      IconOutlinedBtn(
                          text: '确认',
                          icon: Icons.check,
                          btnType: BtnType.primary,
                          onPressed: () {
                            save(true);
                          }),
                      Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: IconOutlinedBtn(
                              text: '关闭',
                              icon: Icons.close,
                              btnType: BtnType.gray,
                              onPressed: () {
                                SmartDialog.dismiss(tag: tag);
                              }))
                    ],
                  ));
        }));
  }

  static void showMemoViewDialog(String newMemoName, String data, Function cb) {
    TextEditingController memoNameCtrl = TextEditingController();
    memoNameCtrl.text = newMemoName;
    String mdData = data;

    double dialogWidth = 960;
    double dataWidgetHeight = 500;

    String tag = 'homeNoteDataListMemoViewDialog';

    SmartDialog.compatible.show(
      tag: tag,
      alignmentTemp: Alignment.center,
      backDismiss: false,
      clickBgDismissTemp: false,
      isLoadingTemp: false,
      widget: DialogContainer(
          dialogWidth: dialogWidth,
          dialogHeight: 660,
          dialogTitle: '查看备忘',
          onDialogClose: () {
            SmartDialog.dismiss(tag: tag);
          },
          dialogBodyBuilder: (context) => Container(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Column(
                  children: [
                    TextField(
                      controller: memoNameCtrl,
                      minLines: 1,
                      maxLines: 1,
                      style: inputStyle,
                      onChanged: (val) {
                        memoNameCtrl.text = newMemoName;
                      },
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
                          hintText: "",
                          hintStyle: inputHintStyle,
                          helperStyle: inputHelperStyle,
                          alignLabelWithHint: true,
                          prefixText: '名称：'),
                    ),
                    Container(
                      width: dialogWidth,
                      height: dataWidgetHeight,
                      margin: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(4),
                        ),
                        border: Border.all(color: borderColor1, width: 0.5),
                      ),
                      child: Markdown(
                        data: mdData,
                        selectable: true,
                        onTapLink: (String text, String? href, String title) =>
                            {CommonUtil.launchByUrl(href!)},
                        imageBuilder: (Uri uri, String? title, String? alt) {
                          return CommonUtil.createMarkdownImgWidget(
                              title ?? '', alt ?? '', uri.toString());
                        },
                        extensionSet: md.ExtensionSet(
                          md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                          [
                            md.EmojiSyntax(),
                            ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
          dialogFooterBuilder: (context) => Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconOutlinedBtn(
                      text: '关闭',
                      icon: Icons.close,
                      btnType: BtnType.gray,
                      onPressed: () {
                        SmartDialog.dismiss(tag: tag);
                      })
                ],
              )),
    );
  }
}


class HomeOtherDataDialog {
  static void showRenameDialog(String path, String name, Function cb) {
    TextEditingController fileNameCtrl = TextEditingController();
    fileNameCtrl.text = CommonUtil.getFileNameAndExtension(name).first;
    String tag = 'homeOtherDataListRenameDialog';

    SmartDialog.compatible.show(
      tag: tag,
      alignmentTemp: Alignment.center,
      backDismiss: false,
      clickBgDismissTemp: false,
      isLoadingTemp: false,
      widget: DialogContainer(
          dialogHeight: 200,
          dialogWidth: 400,
          dialogTitle: '重命名',
          onDialogClose: () {
            SmartDialog.dismiss(tag: tag);
          },
          dialogBodyBuilder: (context) => Container(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: Column(
              children: [
                TextField(
                  controller: fileNameCtrl,
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
                      helperText: "格式：" + isFileNameTip,
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
                    if (fileNameCtrl.value.text.trim().isEmpty) {
                      CommonToast.showToast("请输入名称！");
                      return;
                    }

                    if (!CommonUtil.isFileName(
                        fileNameCtrl.value.text.trim())) {
                      CommonToast.showToast(isFileNameTip);
                      return;
                    }

                    String fileName = fileNameCtrl.text.trim() +
                        "." +
                        CommonUtil.getFileNameAndExtension(name).last;

                    CommonUtil.otherFileRename(path, fileName, (msg) {
                      CommonToast.showToast(msg);
                      SmartDialog.dismiss(tag: tag);
                      cb();
                    }, (msg) {
                      CommonToast.showToast(msg);
                      SmartDialog.dismiss(tag: tag);
                    });
                  }),
              Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: IconOutlinedBtn(
                      text: '关闭',
                      icon: Icons.close,
                      btnType: BtnType.gray,
                      onPressed: () {
                        SmartDialog.dismiss(tag: tag);
                      }))
            ],
          )),
    );
  }

  static void showSelectOtherDialog(String path, Function cb) {
    String tag = 'homeOtherDataListUploadDialog';
    SmartDialog.compatible.show(
      tag: tag,
      alignmentTemp: Alignment.center,
      backDismiss: false,
      clickBgDismissTemp: false,
      isLoadingTemp: false,
      widget: HomeOtherUpload(tag: tag, savePath: path, onClose: cb),
    );
  }
}

