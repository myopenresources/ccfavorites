import 'package:event_bus/event_bus.dart';

import '../common/type/tree_node_type.dart';

final EventBus eventBus = EventBus();

class TreeNodeClickEvent {
  TreeNodeType node;

  TreeNodeClickEvent(this.node);
}

class HomeLeftTreeRefreshEvent {
  bool refresh;

  HomeLeftTreeRefreshEvent(this.refresh);
}
