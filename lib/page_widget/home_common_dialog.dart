import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../common/const/color_const.dart';
import '../common/enum/btn_enum.dart';
import '../common/type/tree_node_type.dart';
import '../common/util/common_util.dart';
import '../widget/common_confirm_dialog.dart';
import '../widget/dialog_container.dart';
import '../widget/icon_outlined_btn.dart';
import '../widget/tree_view.dart';

class HomeCommonDialog {
  static void showMoveDialog(String sourceNodeId, int maxLevel, Function move) {
    List<TreeNodeType> treeData = [];

    Future<List<TreeNodeType>> load(TreeNodeType parent, int level) async {
      await Future.delayed(const Duration(milliseconds: 350));
      return await CommonUtil.getDirectoryListToTreeNodes(parent.extra['path']);
    }

    Future<List<TreeNodeType>> initData() async {
      return await CommonUtil.getRootDirectoryListToTreeNodes();
    }

    Widget buildNodeBtn(context, TreeNodeType node) {
      if (node.id == sourceNodeId) {
        return Container(height: 22, padding: const EdgeInsets.only(left: 8.0));
      }
      return Container(
        height: 22,
        padding: const EdgeInsets.only(left: 8.0),
        child: IconOutlinedBtn(
            text: '移动',
            icon: Icons.drive_file_move_outline,
            btnType: BtnType.outlinedPrimary,
            onPressed: () {
              CommonConfirmDialog.showCustomConfirmDialog(
                  'moveConfirmDialog', 250, 150, '您确认移动到“${node.title}目录？”',
                  (pop) {
                move(node);
                SmartDialog.dismiss(tag: 'homeFileMoveDialog');
                SmartDialog.dismiss(tag: 'moveConfirmDialog');
              }, (pop) {
                pop();
              }, '', '');
              //move(node);
            }),
      );
    }

    Widget buildTreeView(context) {
      final emptyTop = MediaQuery.of(context).size.height / 4.0 - 70;

      return TreeView(
          emptyTop: emptyTop,
          data: treeData,
          lazy: true,
          load: load,
          initData: initData,
          maxLevel: maxLevel,
          showActions: true,
          showCheckBox: false,
          showNodeIcon: true,
          hoverColor: transparentColor1,
          useTitleSelect: false,
          nodeIconStyle:
              const TreeNodeIconStyleType(size: 19.0, color: primaryColor),
          actionsBuilder: (context, node, level, hoverId) {
            return buildNodeBtn(context, node);
          });
    }

    SmartDialog.compatible.show(
      tag: 'homeFileMoveDialog',
      alignmentTemp: Alignment.center,
      backDismiss: false,
      clickBgDismissTemp: false,
      isLoadingTemp: false,
      widget: DialogContainer(
          dialogHeight: 400,
          dialogWidth: 500,
          dialogTitle: '移动',
          onDialogClose: () {
            SmartDialog.dismiss(tag: 'homeFileMoveDialog');
          },
          dialogBodyBuilder: (context) => Container(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Scrollbar(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                        left: 0.0, right: 15.0, bottom: 8.0),
                    child: buildTreeView(context),
                  ),
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
                        SmartDialog.dismiss(tag: 'homeFileMoveDialog');
                      })
                ],
              )),
    );
  }
}
