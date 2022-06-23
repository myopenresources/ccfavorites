import 'package:flutter/material.dart';


class TreeNodeType {

  String id;
  String title;
  IconData icon;
  bool expaned;
  bool checked;
  dynamic extra;
  List<TreeNodeType> children;

  TreeNodeType({
    required this.id,
    required this.title,
    required this.expaned,
    required this.checked,
    required this.children,
    required this.icon,
    this.extra,
  });
}

class TreeNodeIconStyleType {
  final double size;
  final Color color;

  const TreeNodeIconStyleType({required this.size, required this.color});
}
