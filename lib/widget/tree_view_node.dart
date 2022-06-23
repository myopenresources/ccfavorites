import 'package:ccfavorites/widget/tree_view.dart';
import 'package:flutter/material.dart';

import '../common/const/color_const.dart';
import '../common/type/tree_node_type.dart';
import '../common/type_def/type_def.dart';

class TreeViewNode extends StatefulWidget {
  final TreeNodeType data;
  final TreeNodeType parent;

  final bool lazy;
  final Widget icon;
  final bool showCheckBox;
  final bool showActions;
  final double offsetLeft;
  final int level;
  final int maxLevel;
  final bool showNodeIcon;
  final TreeNodeIconStyleType nodeIconStyle;
  final TextStyle titleStyle;
  final TextStyle titleSelectedStyle;
  final Color hoverColor;
  final bool useTitleSelect;

  final WidgetActionsBuilder? actionsBuilder;

  final Function(TreeNodeType node) onTap;
  final void Function(bool checked, TreeNodeType node) onCheck;

  final void Function(TreeNodeType node) onExpand;
  final void Function(TreeNodeType node) onCollapse;

  final Future Function(TreeNodeType node, int level) load;
  final void Function(TreeNodeType node) onLoad;

  final void Function(TreeNodeType node, TreeNodeType parent) onNodeClick;

  const TreeViewNode({
    Key? key,
    required this.data,
    required this.parent,
    required this.offsetLeft,
    required this.level,
    required this.maxLevel,
    required this.showCheckBox,
    required this.showActions,
    required this.icon,
    required this.lazy,
    required this.load,
    required this.onTap,
    required this.onCheck,
    required this.onLoad,
    required this.onExpand,
    required this.onCollapse,
    required this.onNodeClick,
    required this.nodeIconStyle,
    required this.showNodeIcon,
    required this.titleStyle,
    required this.titleSelectedStyle,
    required this.hoverColor,
    required this.useTitleSelect,
    this.actionsBuilder,
  }) : super(key: key);

  @override
  TreeViewNodeState createState() => TreeViewNodeState();
}

class TreeViewNodeState extends State<TreeViewNode>
    with SingleTickerProviderStateMixin {
  bool isChecked = false;
  bool showLoading = false;
  Color bgColor = Colors.transparent;
  String hoverId = '';

  Widget buildActionsEle(
      context, TreeNodeType node, int level, String hoverId) {
    if (null != widget.actionsBuilder) {
      return widget.actionsBuilder!(context, node, level, hoverId);
    } else {
      return Container();
    }
  }

  List<TreeViewNode> geneTreeNodes(List list) {
    return List.generate(list.length, (int index) {
      return TreeViewNode(
          data: list[index],
          parent: widget.data,
          icon: widget.icon,
          lazy: widget.lazy,
          load: widget.load,
          offsetLeft: widget.offsetLeft,
          level: widget.level + 1,
          maxLevel: widget.maxLevel,
          showCheckBox: widget.showCheckBox,
          showActions: widget.showActions,
          showNodeIcon: widget.showNodeIcon,
          nodeIconStyle: widget.nodeIconStyle,
          titleStyle: widget.titleStyle,
          titleSelectedStyle: widget.titleSelectedStyle,
          onTap: widget.onTap,
          onCheck: widget.onCheck,
          onExpand: widget.onExpand,
          onLoad: widget.onLoad,
          onCollapse: widget.onCollapse,
          onNodeClick: widget.onNodeClick,
          actionsBuilder: widget.actionsBuilder,
          hoverColor: widget.hoverColor,
          useTitleSelect: widget.useTitleSelect);
    });
  }

  void onExpandOrCollapse() {
    if (widget.data.expaned) {
      widget.onExpand(widget.data);
    } else if (!widget.data.expaned) {
      widget.onCollapse(widget.data);
    }
  }

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        MouseRegion(
          onHover: (event) {},
          onEnter: (event) {
            bgColor = widget.hoverColor;
            hoverId = widget.data.id;
            setState(() {});
          },
          onExit: (event) {
            bgColor = Colors.transparent;
            hoverId = '';
            setState(() {});
          },
          child: Container(
            color: bgColor,
            margin: const EdgeInsets.only(bottom: 0.5),
            padding: const EdgeInsets.only(right: 0.5),
            height: 35,
            child: Padding(
              padding: EdgeInsets.only(left: widget.level * widget.offsetLeft),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  if (widget.level < widget.maxLevel)
                    IconButton(
                      iconSize: 16,
                      padding: const EdgeInsets.all(0.0),
                      icon: widget.data.expaned
                          ? const Icon(Icons.expand_more_outlined)
                          : const Icon(Icons.chevron_right_outlined),
                      onPressed: () {
                        widget.onTap(widget.data);

                        if (widget.lazy && widget.data.children.isEmpty) {
                          setState(() {
                            showLoading = true;
                          });
                          widget.load(widget.data, widget.level).then((value) {
                            if (value) {
                              widget.data.expaned =
                                  widget.data.children.isEmpty ? false : true;
                              widget.onLoad(widget.data);
                            }

                            onExpandOrCollapse();
                            showLoading = false;
                            setState(() {});
                          });
                        } else {
                          widget.data.expaned = !widget.data.expaned;
                          onExpandOrCollapse();
                          setState(() {});
                        }
                      },
                    ),
                  if (!(widget.level < widget.maxLevel)) Container(width: 32),
                  if (widget.showCheckBox)
                    Checkbox(
                      value: isChecked,
                      onChanged: (bool? value) {
                        isChecked = value!;
                        widget.onCheck(isChecked, widget.data);
                        setState(() {});
                      },
                    ),
                  if (widget.lazy && showLoading)
                    Container(
                      margin: const EdgeInsets.only(right: 6.0),
                      width: 12.0,
                      height: 12.0,
                      child: const CircularProgressIndicator(strokeWidth: 1.0),
                    ),
                  if (widget.showNodeIcon)
                    Container(
                      margin: const EdgeInsets.only(right: 4.0),
                      child: Icon(
                        widget.data.icon,
                        color: widget.nodeIconStyle.color,
                        size: widget.nodeIconStyle.size,
                      ),
                    ),
                  Expanded(
                    child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          child: Container(
                            height: 26,
                            color: transparentColor1,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.data.title,
                              style: widget.useTitleSelect &&
                                      TreeViewSelect.getInstance()
                                              .currentSelectNodeId ==
                                          widget.data.id
                                  ? widget.titleSelectedStyle
                                  : widget.titleStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          onTap: () => {
                            if (widget.useTitleSelect)
                              {
                                TreeViewSelect.getInstance()
                                    .currentSelectNodeId = widget.data.id,
                              },
                            widget.onNodeClick(widget.data, widget.parent)
                          },
                        )),
                  ),
                  if (widget.showActions)
                    buildActionsEle(context, widget.data, widget.level, hoverId)
                ],
              ),
            ),
          ),
        ),
        if (widget.data.expaned)
          Column(children: geneTreeNodes(widget.data.children))
      ],
    );
  }
}
