import 'dart:io';

import 'package:ccfavorites/widget/common_toast.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../common/const/color_const.dart';
import '../common/const/common_const.dart';
import '../common/const/style_const.dart';
import '../common/enum/btn_enum.dart';
import '../common/enum/home_enum.dart';
import '../common/type/audio_data_type.dart';
import '../common/util/common_util.dart';
import '../widget/dialog_container.dart';
import '../widget/icon_outlined_btn.dart';

class HomeAudioUpload extends StatefulWidget {
  final String tag;
  final String savePath;
  final Function onClose;

  const HomeAudioUpload(
      {required this.tag,
      required this.savePath,
      required this.onClose,
      Key? key})
      : super(key: key);

  @override
  State<HomeAudioUpload> createState() => HomeAudioUploadState();
}

class HomeAudioUploadState extends State<HomeAudioUpload> {
  List<AudioUploadDataType> selectList = [];
  bool isUpload = false;

  void selectFiles() {
    if (selectList.length >= uploadLimit) {
      CommonToast.showToast('选择的音频不能超过$uploadLimit个！');
      return;
    }
    final typeGroup =
        XTypeGroup(label: '音频', extensions: CommonUtil.audioExtensionList());
    openFiles(acceptedTypeGroups: [typeGroup]).then((value) {
      List<AudioUploadDataType> list = [];
      int end = value.length>uploadLimit?uploadLimit:value.length;
      for (var i = 0; i < end; i++) {
        var element = value[i];
        String fileName = CommonUtil.getFileNameAndExtension(element.name)[0];
        list.add(AudioUploadDataType(
            element.name,
            element.path,
            TextEditingController(text: fileName),
            false,
            FileDataUploadState.notUploaded,
            ''));
      }
      setState(() {
        selectList.addAll(list);
      });
    });
  }

  void uploadFiles() {
    if (selectList.isEmpty) {
      CommonToast.showToast('请先选择音频！');
      return;
    }

    for (var element in selectList) {
      if (!CommonUtil.isFileName(element.controller.text.trim())) {
        setState(() {
          element.uploadState = FileDataUploadState.uploadedFail;
          element.uploadMsg = isFileNameTip;
        });

        continue;
      }
      setState(() {
        element.showLoading = true;
      });
      Future.delayed(const Duration(milliseconds: loadTime), () {
        CommonUtil.uploadAudioFile(widget.savePath, element.filePath,
            element.fileName, element.controller.text, (msg) {
          selectList.remove(element);
          setState(() {
            element.uploadState = FileDataUploadState.uploadSuccess;
            element.uploadMsg = msg;
            element.showLoading = false;
            isUpload = true;
          });
        }, (msg) {
          setState(() {
            element.uploadMsg = msg;
            element.uploadState = FileDataUploadState.uploadedFail;
            element.showLoading = false;
          });
        });
      });
    }
  }

  Widget buildUploadState(context, AudioUploadDataType item) {
    if (item.showLoading) {
      return const LinearProgressIndicator();
    } else {
      if (item.uploadState == FileDataUploadState.uploadedFail) {
        return Text(
          item.uploadMsg,
          style: audioUploadStateMsgStyle,
        );
      } else {
        return Container();
      }
    }
  }

  Widget buildAudioList(context) {
    return Container(
        margin: const EdgeInsets.only(top: 10, bottom: 10),
        height: 315,
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: Column(
              children: List.generate(
            selectList.length,
            (index) => Container(
              margin: EdgeInsets.only(top: index == 0 ? 0.0 : 10.0),
              padding: const EdgeInsets.all(10.0),
              height: 135,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(width: 0.0, color: borderColor2),
                color: whiteColor,
              ),
              child: Container(
                  margin: const EdgeInsets.only(left: 0),
                  width: 400,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                              width: 280,
                              child: Text(selectList[index].fileName,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1)),
                          const Spacer(),
                          SizedBox(
                            height: 22,
                            child: IconOutlinedBtn(
                              btnType: BtnType.outlinedRed,
                              text: '删除',
                              onPressed: () {
                                setState(() {
                                  selectList.removeAt(index);
                                });
                              },
                            ),
                          )
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 8, bottom: 10),
                        child: TextField(
                          controller: selectList[index].controller,
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
                              labelText: "重命名：",
                              labelStyle: inputLabelStyle,
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              //errorText: "",
                              hintText: "请输入新名称！",
                              helperText: "格式："+isFileNameTip,
                              hintStyle: inputHintStyle,
                              helperStyle: inputHelperStyle,
                              alignLabelWithHint: true,
                              prefixText: '名称：'),
                        ),
                      ),
                      buildUploadState(context, selectList[index])
                    ],
                  )),
            ),
          )),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return DialogContainer(
        dialogHeight: 460,
        dialogWidth: 420,
        dialogTitle: '上传音频',
        onDialogClose: () {
          SmartDialog.dismiss(tag: widget.tag);
          widget.onClose(isUpload);
        },
        dialogBodyBuilder: (context) => Container(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconOutlinedBtn(
                          text: '选择音频',
                          icon: Icons.search,
                          btnType: BtnType.outlinedPrimary,
                          onPressed: () {
                            selectFiles();
                          }),
                      Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: IconOutlinedBtn(
                              text: '上传音频',
                              icon: Icons.upload_file,
                              btnType: BtnType.outlinedGreen,
                              onPressed: () {
                                uploadFiles();
                              }))
                    ],
                  ),
                  buildAudioList(context)
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
                          SmartDialog.dismiss(tag: widget.tag);
                          widget.onClose(isUpload);
                        }))
              ],
            ));
  }
}
