import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../common/const/color_const.dart';
import '../common/const/style_const.dart';
import '../common/type/tree_node_type.dart';
import '../common/type_def/type_def.dart';
import './tree_view_node.dart';
import 'empty.dart';

class TreeViewSelect {
  TreeViewSelect.privateConstructor();

  static final instance = TreeViewSelect.privateConstructor();

  factory TreeViewSelect.getInstance() => instance;

  String currentSelectNodeId = '';
}

GlobalKey<TreeViewState> treeViewGlobalKey = GlobalKey();

class TreeView extends StatefulWidget {
  final List<TreeNodeType> data;

  final bool lazy;
  final Widget icon;
  final double offsetLeft;
  final bool showActions;
  final bool showCheckBox;
  final int maxLevel;
  final WidgetActionsBuilder? actionsBuilder;
  final bool showNodeIcon;
  final TreeNodeIconStyleType nodeIconStyle;
  final TextStyle titleStyle;
  final TextStyle titleSelectedStyle;
  final double emptyTop;
  final Color hoverColor;
  final bool useTitleSelect;

  final Function(TreeNodeType node)? onTap;
  final void Function(TreeNodeType node)? onLoad;
  final void Function(TreeNodeType node)? onExpand;
  final void Function(TreeNodeType node)? onCollapse;
  final void Function(bool checked, TreeNodeType node)? onCheck;
  final Future<List<TreeNodeType>> Function(TreeNodeType parent, int level)?
      load;

  final void Function(TreeNodeType node, TreeNodeType parent)? onNodeClick;

  final Future<List<TreeNodeType>> Function()? initData;

  const TreeView({
    Key? key,
    required this.data,
    required this.maxLevel,
    required this.emptyTop,
    this.initData,
    this.onTap,
    this.onCheck,
    this.onLoad,
    this.onExpand,
    this.onCollapse,
    this.load,
    this.lazy = false,
    this.offsetLeft = 20.0,
    this.showActions = false,
    this.showCheckBox = false,
    this.showNodeIcon = false,
    this.nodeIconStyle =
        const TreeNodeIconStyleType(size: 20.0, color: grayColor),
    this.titleStyle = treeNodeTitleStyle,
    this.titleSelectedStyle = treeNodeTitleSelectedStyle,
    this.useTitleSelect = true,
    this.hoverColor = hoverColor1,
    this.actionsBuilder,
    this.onNodeClick,
    this.icon = const Icon(Icons.expand_more, size: 16.0),
  }) : super(key: key);

  @override
  State<TreeView> createState() => TreeViewState();
}

class TreeViewState extends State<TreeView> {
  late TreeNodeType root;
  List<TreeNodeType> renderList = [];

  Future<bool> load(TreeNodeType node, int level) async {
    try {
      final data = await widget.load!(node, level);
      node.children = data;
      setState(() {});
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  void initData() {
    String rootId = const Uuid().v5(Uuid.NAMESPACE_URL, '_tree_root_id_');
    if (null != widget.initData) {
      widget.initData!().then((value) => {
            renderList = value,
            root = TreeNodeType(
              id: rootId,
              icon: Icons.folder_open_rounded,
              title: '',
              extra: null,
              checked: false,
              expaned: false,
              children: renderList,
            ),
            setState(() {}),
          });
    } else {
      renderList = widget.data;
      root = TreeNodeType(
        id: rootId,
        icon: Icons.folder_open_rounded,
        title: '',
        extra: null,
        checked: false,
        expaned: false,
        children: renderList,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    initData();
  }

  void refresh() {
    initData();
  }

  void findCurrentNode(List<TreeNodeType> list, String nodeId, Function cb) {
    for (var element in list) {
      if (element.id == nodeId) {
        cb(element);
        return;
      }

      if (element.children.isNotEmpty) {
        findCurrentNode(element.children, nodeId, cb);
      }
    }
  }

  void findParentNode(TreeNodeType node, String nodeId, Function cb) {
    for (var element in node.children) {
      if (element.id == nodeId) {
        cb(node, element);
        return;
      }

      if (element.children.isNotEmpty) {
        findParentNode(element, nodeId, cb);
      }
    }
  }

  void addNodeChild(
      String currentNodeId, TreeNodeType appendNode, Function cb) {
    findCurrentNode(renderList, currentNodeId, (TreeNodeType findNode) {
      if (findNode.children.isNotEmpty) {
        setState(() {
          findNode.children.add(appendNode);
        });
        cb();
      }
    });
  }

  void addRootChild(TreeNodeType appendNode, Function cb) {
    setState(() {
      renderList.add(appendNode);
    });
  }

  void deleteNodeChild(String currentNodeId, Function cb) {
    findParentNode(root, currentNodeId,
        (TreeNodeType node, TreeNodeType removeNode) {
      node.children.remove(removeNode);
      setState(() {
        if (node.children.isEmpty) {
          node.expaned = false;
        }
      });
      cb(node);
      return;
    });
  }

  void renameNode(String currentNodeId, String newTitle, Function cb) {
    findCurrentNode(renderList, currentNodeId, (TreeNodeType findNode) {
      setState(() {
        findNode.extra['path'] =
            findNode.extra['path'].replaceFirst(findNode.title, newTitle);
        findNode.id =
            const Uuid().v5(Uuid.NAMESPACE_URL, findNode.extra['path']);
        findNode.title = newTitle;
      });
      cb();
    });
  }

  void treeNodeTitleClick(TreeNodeType node, TreeNodeType parent) {
    setState(() {});
    if (null != widget.onNodeClick) {
      widget.onNodeClick!(node, parent);
    }
  }

  List<Widget> buildTreeNodeList(context) {
    List<Widget> list = [];
    for (var element in renderList) {
      list.add(TreeViewNode(
        level: 0,
        maxLevel: widget.maxLevel,
        load: load,
        parent: root,
        data: element,
        icon: widget.icon,
        lazy: widget.lazy,
        offsetLeft: widget.offsetLeft,
        showCheckBox: widget.showCheckBox,
        showActions: widget.showActions,
        showNodeIcon: widget.showNodeIcon,
        nodeIconStyle: widget.nodeIconStyle,
        titleStyle: widget.titleStyle,
        titleSelectedStyle: widget.titleSelectedStyle,
        useTitleSelect: widget.useTitleSelect,
        hoverColor: widget.hoverColor,
        onTap: widget.onTap ?? (n) {},
        onLoad: widget.onLoad ?? (n) {},
        onCheck: widget.onCheck ?? (b, n) {},
        onExpand: widget.onExpand ?? (n) {},
        onCollapse: widget.onCollapse ?? (n) {},
        onNodeClick: treeNodeTitleClick,
        actionsBuilder: widget.actionsBuilder,
      ));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (renderList.isNotEmpty) ...buildTreeNodeList(context),
        if (renderList.isEmpty)
          Container(
            height: 400,
            margin: EdgeInsets.only(
              top: widget.emptyTop,
            ),
            child: const Empty(),
          )
      ],
    );
  }
}
