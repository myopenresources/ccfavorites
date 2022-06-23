import 'dart:io';
import 'package:file_saver/file_saver.dart';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';

import '../common/const/color_const.dart';
import '../common/const/common_const.dart';
import '../common/const/style_const.dart';
import '../common/enum/btn_enum.dart';
import '../common/enum/home_enum.dart';
import '../common/type/img_data_type.dart';
import '../common/type/tree_node_type.dart';
import '../common/util/common_util.dart';
import '../widget/common_confirm_dialog.dart';
import '../widget/common_toast.dart';
import '../widget/empty.dart';
import '../widget/icon_outlined_btn.dart';
import 'home_common_dialog.dart';
import 'home_right_dialog.dart';

GlobalKey<HomeImgDataListState> homeImgDataListGlobalKey = GlobalKey();

class HomeImgDataList extends StatefulWidget {
  const HomeImgDataList({Key? key}) : super(key: key);

  @override
  HomeImgDataListState createState() => HomeImgDataListState();
}

class HomeImgDataListState extends State<HomeImgDataList> {
  bool showLoading = false;
  TreeNodeType? currentNode;
  List<ImgDataType> dataList = [];
  TextEditingController nameKeyWorkCtrl = TextEditingController();

  void getImgFileList(String keyWork) {
    setState(() {
      dataList = [];
      showLoading = true;
    });
    imageCache.clear();
    Future.delayed(const Duration(milliseconds: loadTime), () {
      if (null != currentNode) {
        CommonUtil.getImgFileList(currentNode!.extra['path'], keyWork)
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
    getImgFileList('');
  }

  List<ImgDataType> getSelectList() {
    List<ImgDataType> selectList = [];
    for (var element in dataList) {
      if (element.selected) {
        selectList.add(element);
      }
    }

    return selectList;
  }

  void del(index) {
    CommonConfirmDialog.showCustomConfirmDialog('deleteImgDataItemFileDialog',
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
      CommonUtil.imgFileMove(
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
    HomeImgDataDialog.showRenameDialog(
        dataList[index].filePath, dataList[index].fileName, () {
      getDataList();
    });
  }

  void download(index) {
    CommonUtil.getDownloadImgFile(
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
    List<ImgDataType> selectList = getSelectList();

    if (selectList.isEmpty) {
      CommonToast.showToast('请选择要移动的图片！');
      return;
    }

    HomeCommonDialog.showMoveDialog(currentNode!.id, homeLeftTreeMaxLevel,
        (TreeNodeType targetNode) {
      String targetPath = targetNode.extra['path'];

      int successCount = 0;
      int failCount = 0;

      for (var element in selectList) {
        CommonUtil.imgFileMove(element.fileName, element.filePath, targetPath,
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
    List<ImgDataType> selectList = getSelectList();

    if (selectList.isEmpty) {
      CommonToast.showToast('请选择要删除的图片！');
      return;
    }

    if (null == currentNode) {
      CommonToast.showToast('请选择目录！');
      return;
    }

    CommonConfirmDialog.showCustomConfirmDialog(
        'deleteImgDataSelectFileDialog', 280, 170, '你确定删除选中的图片吗？', (pop) {
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
    List<ImgDataType> selectList = getSelectList();
    if (selectList.isEmpty) {
      CommonToast.showToast('请选择要下载的图片！');
      return;
    }

    for (var i = 0; i < selectList.length; i++) {
      var element = selectList[i];
      CommonUtil.getDownloadImgFile(element.filePath, element.fileName,
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
    HomeImgDataDialog.showSelectImgDialog(currentNode!.extra['path'],
        (isUpload) {
      if (isUpload) {
        getDataList();
      }
    });
  }

  void showPhoto(filePath) {
    CommonUtil.showImgViewer(context,filePath);
  }

  void openFile(index) {
    CommonUtil.launchFileByPath(dataList[index].filePath);
  }

  void searchFile() {
    getImgFileList(nameKeyWorkCtrl.text);
  }

  void selectAllByState(state) {
    for (var element in dataList) {
      element.selected = state;
    }

    setState(() {});
  }

  void itemMenuHandle(result, index) {
    switch (result) {
      case ImgDataListRowOperationPopupMenu.move:
        move(index);
        break;
      case ImgDataListRowOperationPopupMenu.del:
        del(index);
        break;
      case ImgDataListRowOperationPopupMenu.rename:
        rename(index);
        break;
      case ImgDataListRowOperationPopupMenu.download:
        download(index);
        break;
      case ImgDataListRowOperationPopupMenu.open:
        openFile(index);
        break;
      case ImgDataListRowOperationPopupMenu.copyPath:
        CommonUtil.copyC(dataList[index].filePath);
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

  Widget buildDataList(context) {
    if (showLoading) {
      return Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 0.0),
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

    return MasonryGridView.count(
      crossAxisCount: 4,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: dataList.length,
      itemBuilder: (context, index) {
        return Container(
          alignment: Alignment.centerLeft,
          key: ValueKey(dataList[index].id),
          margin: EdgeInsets.only(left: index == 0 ? 0.0 : 8.0, bottom: 8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(
                width: 0.0,
                color: dataList[index].selected
                    ? selectBorderColor2
                    : borderColor2),
            boxShadow: [
              BoxShadow(
                  color: dataList[index].selected
                      ? selectShadowColor1
                      : shadowColor1,
                  blurRadius: 4.0,
                  spreadRadius: 0.1,
                  offset: const Offset(0.1, 0.1)),
            ],
            color: whiteColor,
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              children: [
                Stack(
                  children: [
                    GestureDetector(
                      child: Container(
                        alignment: Alignment.center,
                        child: Image.file(File(dataList[index].filePath)),
                      ),
                      onTap: () {
                        showPhoto(dataList[index].filePath);
                      },
                    ),
                    Positioned(
                      child: Container(
                        height: 25,
                        color: translucentColor3,
                        child: Row(
                          children: [
                            Checkbox(
                                value: dataList[index].selected,
                                onChanged: (isSelected) {
                                  setState(() {
                                    dataList[index].selected = isSelected!;
                                  });
                                }),
                            const Spacer(),
                            PopupMenuButton<ImgDataListRowOperationPopupMenu>(
                              tooltip: '',
                              padding: const EdgeInsets.all(0),
                              //iconSize: 19,
                              //icon: const Icon(Icons.menu_outlined),
                              child: Container(
                                width: 20,
                                height: 20,
                                padding: const EdgeInsets.all(3.0),
                                margin: const EdgeInsets.only(right: 4.0),
                                decoration: const BoxDecoration(
                                  color: moreBtnBg2,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(100)),
                                ),
                                child: const Icon(
                                  Icons.more_vert,
                                  size: 14,
                                  color: primaryColor,
                                ),
                              ),
                              offset: const Offset(20, 25),
                              onSelected:
                                  (ImgDataListRowOperationPopupMenu result) {
                                itemMenuHandle(result, index);
                              },
                              itemBuilder: (BuildContext context) => <
                                  PopupMenuEntry<
                                      ImgDataListRowOperationPopupMenu>>[
                                const PopupMenuItem<
                                    ImgDataListRowOperationPopupMenu>(
                                  value:
                                      ImgDataListRowOperationPopupMenu.rename,
                                  height: 36,
                                  child: Text(
                                    '重命名',
                                    style: menuItemStyle,
                                  ),
                                ),
                                const PopupMenuItem<
                                    ImgDataListRowOperationPopupMenu>(
                                  value: ImgDataListRowOperationPopupMenu.del,
                                  height: 36,
                                  child: Text('删除', style: menuItemStyle),
                                ),
                                const PopupMenuItem<
                                    ImgDataListRowOperationPopupMenu>(
                                  value: ImgDataListRowOperationPopupMenu.move,
                                  height: 36,
                                  child: Text('移动', style: menuItemStyle),
                                ),
                                const PopupMenuItem<
                                    ImgDataListRowOperationPopupMenu>(
                                  value:
                                      ImgDataListRowOperationPopupMenu.download,
                                  height: 36,
                                  child: Text('下载', style: menuItemStyle),
                                ),
                                const PopupMenuItem<
                                    ImgDataListRowOperationPopupMenu>(
                                  value:
                                  ImgDataListRowOperationPopupMenu.copyPath,
                                  height: 36,
                                  child: Text('复制', style: menuItemStyle),
                                ),
                                const PopupMenuItem<
                                    ImgDataListRowOperationPopupMenu>(
                                  value: ImgDataListRowOperationPopupMenu.open,
                                  height: 36,
                                  child: Text('打开', style: menuItemStyle),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.all(6),
                    child: GestureDetector(
                      child: Text(
                        dataList[index].fileName,
                        style: imgCardTitleStyle,
                      ),
                      onTap: () {
                        showPhoto(dataList[index].filePath);
                      },
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

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
        Container(
          alignment: Alignment.centerLeft,
          height: 34,
          padding: const EdgeInsets.only(left: 10.0, top: 5.0, bottom: 5.0),
          child: Row(
            children: [
              IconOutlinedBtn(
                btnType: BtnType.outlinedPrimary,
                text: '选择全部',
                onPressed: () {
                  selectAllByState(true);
                },
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: IconOutlinedBtn(
                  btnType: BtnType.outlinedGray,
                  text: '取消选择',
                  onPressed: () {
                    selectAllByState(false);
                  },
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Text(
                  '共有' + dataList.length.toString() + '个图片',
                  style: imgDataListTotalStyle,
                ),
              ),
            ],
          ),
        ),
        Expanded(
            child: SingleChildScrollView(
          controller: ScrollController(),
          child: Container(
              padding: const EdgeInsets.only(
                  top: 5.0, left: 15.0, right: 15.0, bottom: 10.0),
              width: width,
              child: buildDataList(context)),
        ))
      ],
    );
  }
}
