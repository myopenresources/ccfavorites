import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import '../common/const/common_const.dart';
import '../common/const/color_const.dart';
import '../common/const/style_const.dart';
import '../common/enum/btn_enum.dart';
import '../common/enum/home_enum.dart';
import '../common/util/common_util.dart';
import '../common/type/link_data_type.dart';
import '../common/type/tree_node_type.dart';
import '../widget/common_confirm_dialog.dart';
import '../widget/common_toast.dart';
import '../widget/empty.dart';
import '../widget/icon_outlined_btn.dart';
import 'home_common_dialog.dart';
import 'home_right_dialog.dart';

GlobalKey<HomeLinkDataListState> homeLinkDataListGlobalKey = GlobalKey();

class HomeLinkDataList extends StatefulWidget {
  const HomeLinkDataList({Key? key}) : super(key: key);

  @override
  HomeLinkDataListState createState() => HomeLinkDataListState();
}

class HomeLinkDataListState extends State<HomeLinkDataList> {
  bool showLoading = false;
  TreeNodeType? currentNode;
  List<LinkDataType> dataList = [];
  TextEditingController urlNameKeyWorkCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getLinkFileList(String keyWork) {
    setState(() {
      dataList = [];
      showLoading = true;
    });
    Future.delayed(const Duration(milliseconds: loadTime), () {
      if (null != currentNode) {
        CommonUtil.getLinkFileList(currentNode!.extra['path'], keyWork)
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
          urlNameKeyWorkCtrl.text = '';
          dataList = [];
          showLoading = false;
        });
      }
    });
  }

  void getDataList() {
    getLinkFileList('');
  }

  void searchFile() {
    getLinkFileList(urlNameKeyWorkCtrl.text);
  }

  void selectAllByState(bool state) {
    for (var element in dataList) {
      element.selected = state;
    }

    setState(() {});
  }

  void showAddOrEditDialog(
    String oldUrlName,
    String urlName,
    String url,
    String remarks,
  ) {
    if (null == currentNode) {
      CommonToast.showToast('请选择目录！');
      return;
    }
    HomeLinkDataDialog.showAddOrEditDialog(
        oldUrlName, urlName, url, remarks, currentNode!.extra['path'], () {
      getDataList();
    });
  }

  List<LinkDataType> getSelectList() {
    List<LinkDataType> selectList = [];
    for (var element in dataList) {
      if (element.selected) {
        selectList.add(element);
      }
    }

    return selectList;
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
    List<LinkDataType> selectList = getSelectList();

    if (selectList.isEmpty) {
      CommonToast.showToast('请选择要移动的书签！');
      return;
    }

    HomeCommonDialog.showMoveDialog(currentNode!.id, homeLeftTreeMaxLevel,
        (TreeNodeType targetNode) {
      String targetPath = targetNode.extra['path'];

      int successCount = 0;
      int failCount = 0;

      for (var element in selectList) {
        CommonUtil.linkFileMove(element.urlName, element.filePath, targetPath,
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
    List<LinkDataType> selectList = getSelectList();

    if (selectList.isEmpty) {
      CommonToast.showToast('请选择要删除的书签！');
      return;
    }

    if (null == currentNode) {
      CommonToast.showToast('请选择目录！');
      return;
    }

    CommonConfirmDialog.showCustomConfirmDialog(
        'deleteLinkDataSelectFileDialog', 280, 170, '你确定删除选中的书签吗？', (pop) {
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
    List<LinkDataType> selectList = getSelectList();
    if (selectList.isEmpty) {
      CommonToast.showToast('请选择要下载的书签！');
      return;
    }
    for (var i = 0; i < selectList.length; i++) {
      var element = selectList[i];
      CommonUtil.getDownloadLinkFile(element.filePath, element.fileName,
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

  void del(index) {
    CommonConfirmDialog.showCustomConfirmDialog('deleteLinkDataItemFileDialog',
        280, 170, '你确定删除“' + dataList[index].urlName + '”吗？', (pop) {
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

  void itemMenuHandle(result, index) {
    switch (result) {
      case LinkDataListRowOperationPopupMenu.openBrowser:
        CommonUtil.launchByUrl(dataList[index].url);
        break;
      case LinkDataListRowOperationPopupMenu.del:
        del(index);
        break;
      case LinkDataListRowOperationPopupMenu.edit:
        showAddOrEditDialog(dataList[index].urlName, dataList[index].urlName,
            dataList[index].url, dataList[index].remarks);
        break;
      case LinkDataListRowOperationPopupMenu.move:
        move(index);
        break;
      case LinkDataListRowOperationPopupMenu.copyLink:
        CommonUtil.copyC(dataList[index].url);
        break;
      case LinkDataListRowOperationPopupMenu.detail:
        HomeLinkDataDialog.showDetailDialog(dataList[index]);
        break;
    }
  }

  void move(index) {
    HomeCommonDialog.showMoveDialog(currentNode!.id, homeLeftTreeMaxLevel,
        (TreeNodeType targetNode) {
      String targetPath = targetNode.extra['path'];
      CommonUtil.linkFileMove(
          dataList[index].urlName, dataList[index].filePath, targetPath, (msg) {
        CommonToast.showToast(msg);
        getDataList();
      }, (msg) {
        CommonToast.showToast(msg);
      });
    });
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
                  dataList[index].urlName,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: dataTableRowLinkedStyle,
                ),
              ),
              onTap: () =>
                  {HomeLinkDataDialog.showDetailDialog(dataList[index])}),
          DataCell(
              SizedBox(
                width: otherWidth,
                child: Text(
                  dataList[index].url,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: dataTableRowLinkedStyle,
                ),
              ),
              onTap: () => {CommonUtil.launchByUrl(dataList[index].url)}),
          DataCell(
              Container(
                padding: const EdgeInsets.only(right: 25),
                width: operationColumnWidth,
                child: PopupMenuButton<LinkDataListRowOperationPopupMenu>(
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
                  //icon: const Icon(Icons.menu_outlined),
                  //icon: const Icon(Icons.more_vert, color: primaryColor),
                  offset: const Offset(20, 25),
                  onSelected: (LinkDataListRowOperationPopupMenu result) {
                    itemMenuHandle(result, index);
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<LinkDataListRowOperationPopupMenu>>[
                    const PopupMenuItem<LinkDataListRowOperationPopupMenu>(
                      value: LinkDataListRowOperationPopupMenu.edit,
                      height: 36,
                      child: Text(
                        '编辑',
                        style: menuItemStyle,
                      ),
                    ),
                    const PopupMenuItem<LinkDataListRowOperationPopupMenu>(
                      value: LinkDataListRowOperationPopupMenu.del,
                      height: 36,
                      child: Text('删除', style: menuItemStyle),
                    ),
                    const PopupMenuItem<LinkDataListRowOperationPopupMenu>(
                      value: LinkDataListRowOperationPopupMenu.move,
                      height: 36,
                      child: Text('移动', style: menuItemStyle),
                    ),
                    const PopupMenuItem<LinkDataListRowOperationPopupMenu>(
                      value: LinkDataListRowOperationPopupMenu.openBrowser,
                      height: 36,
                      child: Text('浏览器打开', style: menuItemStyle),
                    ),
                    const PopupMenuItem<LinkDataListRowOperationPopupMenu>(
                      value: LinkDataListRowOperationPopupMenu.copyLink,
                      height: 36,
                      child: Text('复制地址', style: menuItemStyle),
                    ),
                    const PopupMenuItem<LinkDataListRowOperationPopupMenu>(
                      value: LinkDataListRowOperationPopupMenu.detail,
                      height: 36,
                      child: Text('查看书签', style: menuItemStyle),
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
            '地址',
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

  Widget buildTools(context) {
    return Row(children: [
      Padding(
          padding: const EdgeInsets.only(right: 10.0, left: 10.0),
          child: IconOutlinedBtn(
              text: '添加',
              icon: Icons.add,
              btnType: BtnType.primary,
              onPressed: () {
                showAddOrEditDialog('', '', '', '');
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
          controller: urlNameKeyWorkCtrl,
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
                urlNameKeyWorkCtrl.text = '';
                getDataList();
              })),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    double operationColumnWidth = 50;

    double otherWidth =
        (width - operationColumnWidth - homeLeftWidth - 180) / 2;

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
