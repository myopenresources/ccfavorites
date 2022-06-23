import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';

import '../common/const/color_const.dart';
import '../common/const/common_const.dart';
import '../common/const/style_const.dart';
import '../common/enum/btn_enum.dart';
import '../common/enum/home_enum.dart';
import '../common/type/config_file_type.dart';
import '../common/type/note_data_type.dart';
import '../common/type/tree_node_type.dart';
import '../common/util/common_util.dart';
import '../widget/common_confirm_dialog.dart';
import '../widget/common_toast.dart';
import '../widget/empty.dart';
import '../widget/icon_outlined_btn.dart';
import 'home_common_dialog.dart';
import 'home_right_dialog.dart';

GlobalKey<HomeNoteDataListState> homeNodeDataListGlobalKey = GlobalKey();

class HomeNoteDataList extends StatefulWidget {
  const HomeNoteDataList({Key? key}) : super(key: key);

  @override
  HomeNoteDataListState createState() => HomeNoteDataListState();
}

class HomeNoteDataListState extends State<HomeNoteDataList> {
  bool showLoading = false;
  TreeNodeType? currentNode;
  List<NoteDataType> dataList = [];
  TextEditingController nameKeyWorkCtrl = TextEditingController();

  Map<String, String> defaultAddType = {'upload': 'upload', 'memo': 'memo'};

  void getNoteFileList(String keyWork) {
    setState(() {
      dataList = [];
      showLoading = true;
    });
    Future.delayed(const Duration(milliseconds: loadTime), () {
      if (null != currentNode) {
        CommonUtil.getNoteFileList(currentNode!.extra['path'], keyWork)
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
    getNoteFileList('');
  }

  List<NoteDataType> getSelectList() {
    List<NoteDataType> selectList = [];
    for (var element in dataList) {
      if (element.selected) {
        selectList.add(element);
      }
    }

    return selectList;
  }

  void del(index) {
    CommonConfirmDialog.showCustomConfirmDialog('deleteNoteDataItemFileDialog',
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
      CommonUtil.noteFileMove(
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
    HomeNoteDataDialog.showRenameDialog(
        dataList[index].filePath, dataList[index].fileName, () {
      getDataList();
    });
  }

  void download(index) {
    CommonUtil.getDownloadNoteFile(
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
    List<NoteDataType> selectList = getSelectList();

    if (selectList.isEmpty) {
      CommonToast.showToast('请选择要移动的笔记！');
      return;
    }

    HomeCommonDialog.showMoveDialog(currentNode!.id, homeLeftTreeMaxLevel,
        (TreeNodeType targetNode) {
      String targetPath = targetNode.extra['path'];

      int successCount = 0;
      int failCount = 0;

      for (var element in selectList) {
        CommonUtil.noteFileMove(element.fileName, element.filePath, targetPath,
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
    List<NoteDataType> selectList = getSelectList();

    if (selectList.isEmpty) {
      CommonToast.showToast('请选择要删除的笔记！');
      return;
    }

    if (null == currentNode) {
      CommonToast.showToast('请选择目录！');
      return;
    }

    CommonConfirmDialog.showCustomConfirmDialog(
        'deleteNoteDataSelectFileDialog', 280, 170, '你确定删除选中的笔记吗？', (pop) {
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
    List<NoteDataType> selectList = getSelectList();
    if (selectList.isEmpty) {
      CommonToast.showToast('请选择要下载的笔记！');
      return;
    }

    for (var i = 0; i < selectList.length; i++) {
      var element = selectList[i];
      CommonUtil.getDownloadNoteFile(element.filePath, element.fileName,
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
    HomeNoteDataDialog.showSelectNoteDialog(currentNode!.extra['path'],
        (isUpload) {
      if (isUpload) {
        getDataList();
      }
    });
  }

  Future<void> openNote(index) async {
    if (dataList[index]
        .filePath
        .endsWith('.' + defaultAddType['memo'].toString())) {
      File file = File(dataList[index].filePath);
      if (file.existsSync()) {
        NoteMemoDataType noteMemoDataType = CommonUtil.getNoteMemoFile(file);
        HomeNoteDataDialog.showMemoViewDialog(noteMemoDataType.memoName,
            noteMemoDataType.data, (msg) => {getDataList()});
      } else {
        CommonToast.showToast('文件不存在！');
      }
    } else {
      String filePath = dataList[index].filePath;
      CommonUtil.launchFileByPath(filePath);
    }
  }

  void searchFile() {
    getNoteFileList(nameKeyWorkCtrl.text);
  }

  void selectAllByState(state) {
    for (var element in dataList) {
      element.selected = state;
    }

    setState(() {});
  }

  void itemMenuHandle(result, index) {
    switch (result) {
      case NoteDataListRowOperationPopupMenu.move:
        move(index);
        break;
      case NoteDataListRowOperationPopupMenu.del:
        del(index);
        break;
      case NoteDataListRowOperationPopupMenu.rename:
        rename(index);
        break;
      case NoteDataListRowOperationPopupMenu.download:
        download(index);
        break;
      case NoteDataListRowOperationPopupMenu.open:
        openNote(index);
        break;
      case NoteDataListRowOperationPopupMenu.edit:
        getEditMemoFile(index);
        break;
    }
  }

  void addBtnItemMenuHandle(String result) {
    if (result == defaultAddType['upload']) {
      upload();
    } else if (result == defaultAddType['memo']) {
      NoteSupportType? noteSupportType =
          CommonUtil.getNoteSupportTypeByKey(result);
      if (null != noteSupportType) {
        showAddOrEditMemoDialog('', '', noteSupportType.extension, '');
      }
    } else {
      NoteSupportType? noteSupportType =
          CommonUtil.getNoteSupportTypeByKey(result);
      if (null != noteSupportType) {
        HomeNoteDataDialog.showAddDialog(
            noteSupportType.key,
            noteSupportType.label,
            currentNode!.extra['path'],
            noteSupportType.extension, () {
          getDataList();
        });
      } else {
        CommonToast.showToast('不支持的创建类型！');
      }
    }
  }

  void getEditMemoFile(index) {
    File file = File(dataList[index].filePath);
    if (file.existsSync()) {
      NoteMemoDataType noteMemoDataType = CommonUtil.getNoteMemoFile(file);
      showAddOrEditMemoDialog(
          noteMemoDataType.memoName,
          noteMemoDataType.memoName,
          noteMemoDataType.extension,
          noteMemoDataType.data);
    } else {
      CommonToast.showToast('文件不存在！');
    }
  }

  void showAddOrEditMemoDialog(
      String oldName, String newName, String extension, String data) {
    if (null == currentNode) {
      CommonToast.showToast('请选择目录！');
      return;
    }
    HomeNoteDataDialog.showAddOrEditMemoDialog(
        oldName, newName, extension, data, currentNode!.extra['path'], () {
      getDataList();
    });
  }

  List<PopupMenuEntry<String>> addBtnMenuItemBuilder(BuildContext context) {
    List<PopupMenuItem<String>> list = [];

    for (var element in CommonUtil.getNoteSupportFileList()) {
      list.add(PopupMenuItem<String>(
        value: element.key,
        height: 36,
        child: Text(
          element.label,
          style: menuItemStyle,
        ),
      ));
    }

    list.add(PopupMenuItem<String>(
      value: defaultAddType['upload'],
      height: 36,
      child: const Text(
        '上传',
        style: menuItemStyle,
      ),
    ));
    return list;
  }

  Widget buildTools(context) {
    return Row(children: [
      Padding(
          padding: const EdgeInsets.only(right: 10.0, left: 10.0),
          child: PopupMenuButton<String>(
              tooltip: '',
              iconSize: 19,
              child: Container(
                height: 28,
                padding: const EdgeInsets.only(
                    top: 6.0, bottom: 6.0, left: 16.0, right: 16.0),
                decoration: const BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(4))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.add,
                          size: 15,
                          color: whiteColor,
                        )),
                    Text(
                      '添加',
                      style: TextStyle(fontSize: 13, color: whiteColor),
                    )
                  ],
                ),
              ),
              offset: const Offset(20, 25),
              onSelected: (String result) {
                addBtnItemMenuHandle(result);
              },
              itemBuilder: (context) => addBtnMenuItemBuilder(context))),
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

  List<PopupMenuEntry<NoteDataListRowOperationPopupMenu>> buildPopupMenuItem(
      fileName) {
    List<PopupMenuEntry<NoteDataListRowOperationPopupMenu>> list = [];
    if (fileName.endsWith('.' + defaultAddType['memo'].toString())) {
      list.add(const PopupMenuItem<NoteDataListRowOperationPopupMenu>(
        value: NoteDataListRowOperationPopupMenu.edit,
        height: 36,
        child: Text(
          '编辑',
          style: menuItemStyle,
        ),
      ));
    } else {
      list.add(const PopupMenuItem<NoteDataListRowOperationPopupMenu>(
        value: NoteDataListRowOperationPopupMenu.rename,
        height: 36,
        child: Text(
          '重命名',
          style: menuItemStyle,
        ),
      ));
    }

    list.add(const PopupMenuItem<NoteDataListRowOperationPopupMenu>(
      value: NoteDataListRowOperationPopupMenu.del,
      height: 36,
      child: Text('删除', style: menuItemStyle),
    ));

    list.add(const PopupMenuItem<NoteDataListRowOperationPopupMenu>(
      value: NoteDataListRowOperationPopupMenu.move,
      height: 36,
      child: Text('移动', style: menuItemStyle),
    ));

    list.add(const PopupMenuItem<NoteDataListRowOperationPopupMenu>(
      value: NoteDataListRowOperationPopupMenu.download,
      height: 36,
      child: Text('下载', style: menuItemStyle),
    ));

    list.add(const PopupMenuItem<NoteDataListRowOperationPopupMenu>(
      value: NoteDataListRowOperationPopupMenu.open,
      height: 36,
      child: Text('打开', style: menuItemStyle),
    ));

    return list;
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
                child: Text(
                  dataList[index].fileName,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: dataTableRowLinkedStyle,
                ),
              ),
              onTap: () => {openNote(index)}),
          DataCell(
              Container(
                padding: const EdgeInsets.only(right: 25),
                width: operationColumnWidth,
                child: PopupMenuButton<NoteDataListRowOperationPopupMenu>(
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
                  offset: const Offset(20, 25),
                  onSelected: (NoteDataListRowOperationPopupMenu result) {
                    itemMenuHandle(result, index);
                  },
                  itemBuilder: (BuildContext context) =>
                      buildPopupMenuItem(dataList[index].fileName),
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
