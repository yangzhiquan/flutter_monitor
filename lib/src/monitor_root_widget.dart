import 'package:flutter/material.dart';
import 'handler/app_event_handler.dart';

/// 包装App的Widget树的根节点; 收集rebuild事、滚动事件;
class MonitorRootWidget extends StatelessWidget {
  final Widget child;
  final AppEventHandler handler;

  const MonitorRootWidget(
      {Key? key, required this.child, required this.handler})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    handler.onRebuild(context);
    return NotificationListener<ScrollNotification>(
        onNotification: handler.onScroll,
        child: RepaintBoundary(
          key: handler.repaintKey,
          child: child,
        ));
  }
}
