import 'dart:io';
import 'package:file_saver/file_saver.dart';

import 'package:flutter/material.dart';

import '../common/const/color_const.dart';
import '../common/const/common_const.dart';
import '../common/const/style_const.dart';
import '../common/enum/btn_enum.dart';
import '../common/enum/home_enum.dart';
import '../common/type/tree_node_type.dart';
import '../common/type/audio_data_type.dart';
import '../common/util/common_util.dart';
import '../widget/common_confirm_dialog.dart';
import '../widget/common_toast.dart';
import '../widget/empty.dart';
import '../widget/icon_outlined_btn.dart';
import 'home_common_dialog.dart';
import 'home_right_dialog.dart';

GlobalKey<HomeAudioDataListState> homeAudioDataListGlobalKey = GlobalKey();

class HomeAudioDataList extends StatefulWidget {
  const HomeAudioDataList({Key? key}) : super(key: key);

  @override
  HomeAudioDataListState createState() => HomeAudioDataListState();
}

class HomeAudioDataListState extends State<HomeAudioDataList> {
  bool showLoading = false;
  TreeNodeType? currentNode;
  List<AudioDataType> dataList = [];
  TextEditingController nameKeyWorkCtrl = TextEditingController();

  void getAudioFileList(String keyWork) {
    setState(() {
      dataList=[];
      showLoading = true;
    });
    Future.delayed(const Duration(milliseconds: loadTime), () {
      if (null != currentNode) {
        CommonUtil.getAudioFileList(currentNode!.extra['path'], keyWork)
            .then((value) => {
                  if (mounted)
                    {
                      setState(() {
                        dataList = value;
                        showLoading = false;
                      })
                    }
                });
      } else {
        setState(() {
          nameKeyWorkCtrl.text = '';
          dataList = [];
          showLoading = false;
        });
      }
    });
  }

  void getDataList() {
    getAudioFileList('');
  }

  List<AudioDataType> getSelectList() {
    List<AudioDataType> selectList = [];
    for (var element in dataList) {
      if (element.selected) {
        selectList.add(element);
      }
    }

    return selectList;
  }

  void del(index) {
    CommonConfirmDialog.showCustomConfirmDialog('deleteAudioDataItemFileDialog',
        280, 170, '你确定删除“' + dataList[index].fileName + '”吗？', (pop) {
      CommonUtil.deleteFile(dataList[index].filePath, (msg) {
        pop();
        CommonToast.showToast(msg);
        getDataList();
      }, (msg) {
        pop();
        CommonToast.showToast(msg);
      });
    }, (pop) {
      pop();
    }, '', '');
  }

  void move(index) {
    HomeCommonDialog.showMoveDialog(currentNode!.id, homeLeftTreeMaxLevel,
        (TreeNodeType targetNode) {
      String targetPath = targetNode.extra['path'];
      CommonUtil.audioFileMove(
          dataList[index].fileName, dataList[index].filePath, targetPath,
          (msg) {
        CommonToast.showToast(msg);
        getDataList();
      }, (msg) {
        CommonToast.showToast(msg);
      });
    });
  }

  void rename(index) {
    HomeAudioDataDialog.showRenameDialog(
        dataList[index].filePath, dataList[index].fileName, () {
      getDataList();
    });
  }

  void download(index) {
    CommonUtil.getDownloadAudioFile(
        dataList[index].filePath, dataList[index].fileName,
        (File file, List<String> fileNames) {
      FileSaver.instance
          .saveFile(fileNames[0], file.readAsBytesSync(), fileNames[1])
          .then((value) => {CommonToast.showToast('下载成功，请到下载目录查看！')});
    }, (msg) {
      CommonToast.showToast(msg);
    });
  }

  void batchDelOrMoveCheck(String label, int selectCount, int successCount,
      int failCount, Function pop) {
    if ((successCount + failCount) == selectCount) {
      CommonToast.showToast('共$label成功$successCount个，失败$failCount个！');
      getDataList();
      pop();
    }
  }

  void batchMove() {
    List<AudioDataType> selectList = getSelectList();

    if (selectList.isEmpty) {
      CommonToast.showToast('请选择要移动的音频！');
      return;
    }

    HomeCommonDialog.showMoveDialog(currentNode!.id, homeLeftTreeMaxLevel,
        (TreeNodeType targetNode) {
      String targetPath = targetNode.extra['path'];

      int successCount = 0;
      int failCount = 0;

      for (var element in selectList) {
        CommonUtil.audioFileMove(element.fileName, element.filePath, targetPath,
            (msg) {
          successCount++;
          batchDelOrMoveCheck(
              '移动', selectList.length, successCount, failCount, () {});
        }, (msg) {
          failCount++;
          batchDelOrMoveCheck(
              '移动', selectList.length, successCount, failCount, () {});
        });
      }
    });
  }

  void batchDel() {
    List<AudioDataType> selectList = getSelectList();

    if (selectList.isEmpty) {
      CommonToast.showToast('请选择要删除的音频！');
      return;
    }

    if (null == currentNode) {
      CommonToast.showToast('请选择目录！');
      return;
    }

    CommonConfirmDialog.showCustomConfirmDialog(
        'deleteAudioDataSelectFileDialog', 280, 170, '你确定删除选中的音频吗？', (pop) {
      int successCount = 0;
      int failCount = 0;

      for (var element in selectList) {
        CommonUtil.deleteFile(element.filePath, (msg) {
          successCount++;
          batchDelOrMoveCheck(
              '删除', selectList.length, successCount, failCount, pop);
        }, (msg) {
          failCount++;
          batchDelOrMoveCheck(
              '删除', selectList.length, successCount, failCount, pop);
        });
      }
    }, (pop) {
      pop();
    }, '', '');
  }

  void batchDownload() {
    List<AudioDataType> selectList = getSelectList();
    if (selectList.isEmpty) {
      CommonToast.showToast('请选择要下载的音频！');
      return;
    }

    for (var i = 0; i < selectList.length; i++) {
      var element = selectList[i];
      CommonUtil.getDownloadAudioFile(element.filePath, element.fileName,
          (File file, List<String> fileNames) {
        FileSaver.instance
            .saveFile(fileNames[0], file.readAsBytesSync(), fileNames[1])
            .then((value) => {
                  if (i == selectList.length - 1)
                    {
                      CommonToast.showToast('下载成功，请到下载目录查看！'),
                      selectAllByState(false)
                    }
                });
      }, (msg) {
        CommonToast.showToast(msg);
      });
    }
  }

  void upload() {
    HomeAudioDataDialog.showSelectAudioDialog(currentNode!.extra['path'],
        (isUpload) {
      if (isUpload) {
        getDataList();
      }
    });
  }

  Future<void> openAudio(index) async {
    String filePath = dataList[index].filePath;
    CommonUtil.launchFileByPath(filePath);
  }

  void searchFile() {
    getAudioFileList(nameKeyWorkCtrl.text);
  }

  void selectAllByState(state) {
    for (var element in dataList) {
      element.selected = state;
    }

    setState(() {});
  }

  void itemMenuHandle(result, index) {
    switch (result) {
      case AudioDataListRowOperationPopupMenu.move:
        move(index);
        break;
      case AudioDataListRowOperationPopupMenu.del:
        del(index);
        break;
      case AudioDataListRowOperationPopupMenu.rename:
        rename(index);
        break;
      case AudioDataListRowOperationPopupMenu.download:
        download(index);
        break;
      case AudioDataListRowOperationPopupMenu.open:
        openAudio(index);
        break;
    }
  }

  Widget buildTools(context) {
    return Row(children: [
      Padding(
          padding: const EdgeInsets.only(right: 10.0, left: 10.0),
          child: IconOutlinedBtn(
              text: '上传',
              icon: Icons.upload_file,
              btnType: BtnType.primary,
              onPressed: () {
                upload();
              })),
      Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: IconOutlinedBtn(
              text: '删除',
              icon: Icons.clear,
              btnType: BtnType.red,
              onPressed: () {
                batchDel();
              })),
      Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: IconOutlinedBtn(
              text: '移动',
              icon: Icons.drive_file_move_outline,
              btnType: BtnType.green,
              onPressed: () {
                batchMove();
              })),
      Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: IconOutlinedBtn(
              text: '下载',
              icon: Icons.download_outlined,
              btnType: BtnType.blue,
              onPressed: () {
                batchDownload();
              })),
      const Spacer(),
      Container(
        width: 250,
        height: 30,
        margin: const EdgeInsets.only(right: 0.0),
        child: TextField(
          controller: nameKeyWorkCtrl,
          style: inputStyle,
          textAlignVertical: TextAlignVertical.center,
          decoration: const InputDecoration(
            hintText: "请输入搜索的名称",
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
                  width: 0.5,
                )),
            contentPadding:
                EdgeInsets.only(top: 0.0, bottom: 0, left: 8.0, right: 8.0),
            hintStyle: inputHintStyle,
          ),
        ),
      ),
      Padding(
          padding: const EdgeInsets.only(right: 10.0, left: 10.0),
          child: IconOutlinedBtn(
              text: '搜索',
              icon: Icons.search,
              btnType: BtnType.primary,
              onPressed: () {
                searchFile();
              })),
      Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: IconOutlinedBtn(
              text: '重置',
              icon: Icons.refresh,
              btnType: BtnType.gray,
              onPressed: () {
                nameKeyWorkCtrl.text = '';
                getDataList();
              })),
    ]);
  }

  List<DataRow> buildDataRows(context, otherWidth, operationColumnWidth) {
    return List.generate(dataList.length, (int index) {
      return DataRow(
        selected: dataList[index].selected,
        onSelectChanged: <bool>(isSelected) {
          setState(() {
            dataList[index].selected = isSelected;
          });
        },
        cells: <DataCell>[
          DataCell(
              SizedBox(
                width: otherWidth,
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/audio.png',
                      width: 16,
                    ),
                    Text(
                      ' ' + dataList[index].fileName,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: dataTableRowLinkedStyle,
                    )
                  ],
                ),
              ),
              onTap: () => {openAudio(index)}),
          DataCell(
              Container(
                padding: const EdgeInsets.only(right: 25),
                width: operationColumnWidth,
                child: PopupMenuButton<AudioDataListRowOperationPopupMenu>(
                  tooltip: '',
                  child: Container(
                    width: 30,
                    height: 25,
                    padding: const EdgeInsets.all(3.0),
                    decoration: const BoxDecoration(
                      color: moreBtnBg1,
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                    ),
                    child: const Icon(
                      Icons.more_vert,
                      size: 14,
                      color: primaryColor,
                    ),
                  ),
                  //iconSize: 19,
                  //icon: const Icon(Icons.menu_outlined),
                  //icon: const Icon(Icons.more_vert, color: primaryColor),
                  offset: const Offset(20, 25),
                  onSelected: (AudioDataListRowOperationPopupMenu result) {
                    itemMenuHandle(result, index);
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<AudioDataListRowOperationPopupMenu>>[
                    const PopupMenuItem<AudioDataListRowOperationPopupMenu>(
                      value: AudioDataListRowOperationPopupMenu.rename,
                      height: 36,
                      child: Text(
                        '重命名',
                        style: menuItemStyle,
                      ),
                    ),
                    const PopupMenuItem<AudioDataListRowOperationPopupMenu>(
                      value: AudioDataListRowOperationPopupMenu.del,
                      height: 36,
                      child: Text('删除', style: menuItemStyle),
                    ),
                    const PopupMenuItem<AudioDataListRowOperationPopupMenu>(
                      value: AudioDataListRowOperationPopupMenu.move,
                      height: 36,
                      child: Text('移动', style: menuItemStyle),
                    ),
                    const PopupMenuItem<AudioDataListRowOperationPopupMenu>(
                      value: AudioDataListRowOperationPopupMenu.download,
                      height: 36,
                      child: Text('下载', style: menuItemStyle),
                    ),
                    const PopupMenuItem<AudioDataListRowOperationPopupMenu>(
                      value: AudioDataListRowOperationPopupMenu.open,
                      height: 36,
                      child: Text('打开', style: menuItemStyle),
                    ),
                  ],
                ),
              ),
              onTap: () => {}),
        ],
      );
    });
  }

  Widget buildDataList(context, otherWidth, operationColumnWidth) {
    if (showLoading) {
      return Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 15.0),
            width: 12.0,
            height: 12.0,
            child: const CircularProgressIndicator(strokeWidth: 1.0),
          )
        ],
      );
    }

    final top = MediaQuery.of(context).size.height / 4.0 - 80;
    if (dataList.isEmpty) {
      return Container(
        height: 400,
        margin: EdgeInsets.only(
          top: top,
        ),
        child: const Empty(),
      );
    }
    return DataTable(
      dividerThickness: 0.5,
      headingRowColor: MaterialStateProperty.all(lightGrayColorC),
      headingRowHeight: 44,
      dataRowHeight: 44,
      showBottomBorder: true,
      showCheckboxColumn: true,
      columns: const <DataColumn>[
        DataColumn(
          label: Text(
            '名称',
            style: dataTableHeaderStyle,
          ),
        ),
        DataColumn(
          label: Text(
            '操作',
            style: dataTableHeaderStyle,
          ),
        ),
      ],
      rows: buildDataRows(context, otherWidth, operationColumnWidth),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    double operationColumnWidth = 50;

    double otherWidth = (width - operationColumnWidth - homeLeftWidth - 125);

    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          height: 50,
          padding: const EdgeInsets.all(0),
          decoration: const BoxDecoration(
            color: whiteColor,
            border: Border(
              bottom: BorderSide(color: borderColor1, width: 0.5),
            ),
          ),
          child: buildTools(context),
        ),
        Expanded(
            child: SingleChildScrollView(
          controller: ScrollController(),
          child: SizedBox(
              width: width,
              child: buildDataList(context, otherWidth, operationColumnWidth)),
        ))
      ],
    );
  }
}
