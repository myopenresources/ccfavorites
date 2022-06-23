import 'package:flutter/material.dart';

import '../type/tree_node_type.dart';

typedef WidgetActionsBuilder = Widget Function(BuildContext context,TreeNodeType node,int level,String hoverId);