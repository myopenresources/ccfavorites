import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:uuid/uuid.dart';

import '../common/const/common_const.dart';
import '../common/const/color_const.dart';
import '../common/enum/home_enum.dart';
import '../common/const/style_const.dart';
import '../common/util/common_util.dart';
import '../event/event.dart';
import '../common/type/tree_node_type.dart';
import '../widget/common_confirm_dialog.dart';
import '../widget/common_toast.dart';
import '../widget/tree_view.dart';
import 'home_common_dialog.dart';
import 'home_left_dialog.dart';
import 'left_title_bar.dart';

class HomeLeft extends StatefulWidget {
  const HomeLeft({Key? key}) : super(key: key);

  @override
  HomeLeftState createState() => HomeLeftState();
}

class HomeLeftState extends State<HomeLeft> {
  List<TreeNodeType> treeData = [];
  bool showLoading = false;

  Future<List<TreeNodeType>> load(TreeNodeType parent, int level) async {
    await Future.delayed(const Duration(milliseconds: loadTime));
    return await CommonUtil.getDirectoryListToTreeNodes(parent.extra['path']);
  }

  @override
  void initState() {
    super.initState();
  }

  Future<List<TreeNodeType>> initData() async {
    return await CommonUtil.getRootDirectoryListToTreeNodes();
  }

  /*
   * 刷新目录
   */
  void refreshDir() {
    setState(() {
      showLoading = true;
    });
    Future.delayed(const Duration(milliseconds: loadTime), () {
      setState(() {
        TreeViewSelect.getInstance().currentSelectNodeId = '';
        showLoading = false;
      });
    });
  }

  /*
   * 刷新目录和文件
   */
  void refreshDirAndFileDataList() {
    eventBus.fire(HomeLeftTreeRefreshEvent(true));
    setState(() {
      showLoading = true;
    });
    Future.delayed(const Duration(milliseconds: loadTime), () {
      setState(() {
        TreeViewSelect.getInstance().currentSelectNodeId = '';
        showLoading = false;
      });
    });
  }

  void deepUpdateNodePath(List<TreeNodeType> children, String newParentPath) {
    for (var element in children) {
      String newPath = newParentPath + "\\" + element.title;
      element.extra['path'] = newPath;
      element.id = const Uuid().v5(Uuid.NAMESPACE_URL, newPath);

      if (element.children.isNotEmpty) {
        deepUpdateNodePath(element.children, newPath);
      }
    }
  }

  /*
   * 添加或编辑目录
   */
  void showAddOrEditDialog(TreeNodeType node, bool isEdit, bool isRoot) {
    String oldDirectoryName = isEdit ? node.title : '';
    String directoryName = isEdit ? node.title : '';
    String parentPath = node.extra['path'];

    HomeTreeDialog.showAddOrEditDialog(
        oldDirectoryName, directoryName, parentPath, (title) {
      if (isEdit) {
        setState(() {
          String parentPath = CommonUtil.getParentDirectory(node.extra['path']);
          String newPath = parentPath + "\\" + title;
          node.extra['path'] = newPath;
          node.id = const Uuid().v5(Uuid.NAMESPACE_URL, newPath);
          node.title = title;

          if (node.children.isNotEmpty) {
            deepUpdateNodePath(node.children, newPath);
          }
        });
      } else {
        String path = parentPath + "\\" + title;
        Map<String, String> extra = {'path': path};
        String id = const Uuid().v5(Uuid.NAMESPACE_URL, path);

        TreeNodeType appendNode = TreeNodeType(
            id: id,
            icon: Icons.folder_open_rounded,
            title: title,
            expaned: false,
            checked: false,
            children: [],
            extra: extra);

        // 根目录的添加
        if (isRoot) {
          treeViewGlobalKey.currentState!.addRootChild(appendNode, () {});
        } else {
          //子目录添加，并且是有子节点数据的情况
          if (node.children.isNotEmpty) {
            setState(() {
              node.children.add(appendNode);
            });
          }
        }
      }
    });
  }

  void showAddRootDialog() {
    String path = ConfigFile.getInstance().configFile!.dataPath;
    Map<String, String> extra = {'path': path};

    showAddOrEditDialog(
        TreeNodeType(
            id: '',
            icon: Icons.folder_open_rounded,
            title: '',
            expaned: false,
            checked: false,
            children: [],
            extra: extra),
        false,
        true);
  }

  void treeNodeMenuHandle(result, node) {
    if (result == HeaderPopupMenu.addDir) {
      showAddOrEditDialog(node, false, false);
    }

    if (result == HeaderPopupMenu.editDir) {
      showAddOrEditDialog(node, true, false);
    }

    if (result == HeaderPopupMenu.delDir) {
      CommonConfirmDialog.showCustomConfirmDialog(
          'deleteHomeTreeDirDialog', 280, 170, '你确定删除”' + node.title + '“吗？',
          (pop) {
        CommonUtil.deleteDirectory(node.extra['path'], (msg) {
          CommonToast.showToast(msg);
          pop();
          treeViewGlobalKey.currentState!.deleteNodeChild(node.id,
              (parentNode) {
            eventBus.fire(HomeLeftTreeRefreshEvent(true));
            //setState(() {});
          });
          //refreshDirAndFileDataList();
        }, (msg) {
          CommonToast.showToast(msg);
          pop();
        });
      }, (pop) {
        pop();
      }, '', '');
    }

    if (result == HeaderPopupMenu.moveDir) {
      CommonUtil.getDirectoryMaxHeight(node.extra['path']).then((value) => {
            if (value > homeLeftTreeMaxLevel)
              {
                CommonToast.showToast('该目录层级超过' +
                    (homeLeftTreeMaxLevel + 1).toString() +
                    '级，请先移动部分子目录！')
              }
            else
              {
                HomeCommonDialog.showMoveDialog(
                    node.id, homeLeftTreeMaxLevel - 1,
                    (TreeNodeType targetNode) {
                  String targetPath =
                      targetNode.extra['path'] + "\\" + node.title;
                  CommonUtil.moveDirectory(node.extra['path'], targetPath,
                      (msg) {
                    CommonToast.showToast(msg);
                    refreshDirAndFileDataList();
                  }, (msg) {
                    CommonToast.showToast(msg);
                  });
                })
              }
          });
    }

    if (result == HeaderPopupMenu.moveRootDir) {
      CommonConfirmDialog.showCustomConfirmDialog(
          'homeMoveTreeDirToRootDirDialog', 280, 170, '你确认要移动到根目录吗？', (pop) {
        CommonUtil.moveDirectoryToRoot(node.title, node.extra['path'], (msg) {
          CommonToast.showToast(msg);
          SmartDialog.dismiss(tag: 'homeMoveTreeDirToRootDirDialog');
          refreshDirAndFileDataList();
        }, (msg) {
          SmartDialog.dismiss(tag: 'homeMoveTreeDirToRootDirDialog');
          CommonToast.showToast(msg);
        });
      }, (pop) {
        pop();
      }, '', '');
    }
  }

  Widget buildTreeView(context) {
    final emptyTop = MediaQuery.of(context).size.height / 4.0 - 70;

    if (!showLoading) {
      return TreeView(
        key: treeViewGlobalKey,
        emptyTop: emptyTop,
        data: treeData,
        lazy: true,
        load: load,
        initData: initData,
        maxLevel: homeLeftTreeMaxLevel,
        showActions: true,
        showCheckBox: false,
        showNodeIcon: true,
        nodeIconStyle:
            const TreeNodeIconStyleType(size: 19.0, color: primaryColor),
        actionsBuilder: (context, node, level, hoverId) {
          return PopupMenuButton<HeaderPopupMenu>(
            tooltip: '',
            child: const Padding(
              padding: EdgeInsets.only(right: 3.0),
              child: Icon(
                Icons.more_vert,
                size: 15,
              ),
            ),
            offset: const Offset(0, 25),
            padding: const EdgeInsets.all(0.0),
            onSelected: (HeaderPopupMenu result) {
              treeNodeMenuHandle(result, node);
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<HeaderPopupMenu>>[
              if (level < homeLeftTreeMaxLevel)
                const PopupMenuItem<HeaderPopupMenu>(
                  value: HeaderPopupMenu.addDir,
                  height: 36,
                  child: Text(
                    '添加子目录',
                    style: menuItemStyle,
                  ),
                ),
              const PopupMenuItem<HeaderPopupMenu>(
                value: HeaderPopupMenu.editDir,
                height: 36,
                child: Text(
                  '编辑目录',
                  style: menuItemStyle,
                ),
              ),
              const PopupMenuItem<HeaderPopupMenu>(
                value: HeaderPopupMenu.delDir,
                height: 36,
                child: Text(
                  '删除目录',
                  style: menuItemStyle,
                ),
              ),
              const PopupMenuItem<HeaderPopupMenu>(
                value: HeaderPopupMenu.moveDir,
                height: 36,
                child: Text(
                  '移动到目录',
                  style: menuItemStyle,
                ),
              ),
              if (level > 0)
                const PopupMenuItem<HeaderPopupMenu>(
                  value: HeaderPopupMenu.moveRootDir,
                  height: 36,
                  child: Text(
                    '移动到根目录',
                    style: menuItemStyle,
                  ),
                ),
            ],
          );
        },
        onNodeClick: (node, parent) {
          eventBus.fire(TreeNodeClickEvent(node));
        },
      );
    } else {
      return Container(
        margin: const EdgeInsets.only(top: 10.0),
        width: 12.0,
        height: 12.0,
        child: const CircularProgressIndicator(strokeWidth: 1.0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      width: homeLeftWidth,
      decoration: const BoxDecoration(
        color: homeLeftBgColor,
        //border: Border(right: BorderSide(color: borderColor1, width: 0.5)),
      ),
      child: Column(
        children: [
          LeftTitleBar(
              titleWidth: homeLeftWidth,
              leftBackground: homeLeftBgColor,
              leftBuilder: (context) => SizedBox(
                  width: 30,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      child: const Icon(
                        Icons.settings,
                        size: 15,
                        color: primaryColor,
                      ),
                      onTap: () {
                        HomeTreeDialog.showSettingDialog(() {
                          refreshDirAndFileDataList();
                        });
                      },
                    ),
                  ))),
          Container(
            alignment: Alignment.centerLeft,
            height: 35,
            decoration: const BoxDecoration(
              border: Border(
                  //bottom: BorderSide(color: homeLeftBorderColor, width: 0.5),
                  top: BorderSide(color: homeLeftBorderColor, width: 0.5)),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text(
                    '我的宝藏目录',
                    style: TextStyle(color: blackColor, fontSize: 13.5),
                  ),
                ),
                const Spacer(),
                IconButton(
                    padding: const EdgeInsets.all(0.0),
                    iconSize: 16,
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      refreshDirAndFileDataList();
                    }),
                IconButton(
                    padding: const EdgeInsets.all(0.0),
                    iconSize: 16,
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      showAddRootDialog();
                    }),
              ],
            ),
          ),
          Expanded(
              child: Scrollbar(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
              child: buildTreeView(context),
            ),
          ))
        ],
      ),
    );
  }
}
