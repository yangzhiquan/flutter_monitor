import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_monitor/src/model/handler_model.dart';

import '../model/hit_test_wrapper.dart';

part 'gesture_handler.dart';
part 'input_handler.dart';
part 'lifecycle_handler.dart';
part 'navigation_handler.dart';
part 'scroll_handler.dart';

/// 事件记录/处理协议类
abstract class EventHandler {
  /// 处理手势
  void handleGestureEvent(GestureEventResult result);

  /// 处理应用生命周期
  /// 处理滚动
  /// 处理输入...
}

/// 收集到的应用事件由它管理，分给具体地事件订阅者；它也提供一些通用的工具方法；
class AppEventHandler extends EventHandler {
  final Set<EventListener> _listeners = <EventListener>{};

  final GlobalObjectKey repaintKey = const GlobalObjectKey("WidgetRepaintKey");
  BuildContext? _rootContext;

  ///
  void onRebuild(BuildContext context) {
    _rootContext = context;
    debugPrint("onRebuild");
  }

  ///
  bool onScroll(ScrollNotification notification) {
    debugPrint("onScroll");
    return true;
  }

  ///
  void addListener(EventListener listener) => _listeners.add(listener);

  ///
  void removeListener(EventListener listener) => _listeners.remove(listener);

  // 处理当前响应的手势
  @override
  void handleGestureEvent(GestureEventResult result) {
    if (_rootContext == null) {
      return;
    }
    _handleGestureEvent(result);
  }

  // Element get topPageElement => ;
  // String get topRouteName => ;

  /// 通知订阅者
  void _notifyListeners(EventInfo info) {
    for (final EventListener listener in _listeners) {
      listener.handleEvent(info);
    }
  }
}

///
/// 扩展查找能力
extension ElementFinder on Element {
  /// 根据renderObject匹配element树
  Element? gestureElementForRenderObject(RenderObject renderObject) {
    final List<Element> path = pathToObject(renderObject);

    //   element = _findFirstWidget<XXXGestureDetector>(path); // 需要监控的widget类型
    // if (element == null) {
    // 如果指定的widget类型没有找到，那就默认找GestureDetector类型的Widget
    final Element? element = _findFirstWidget<GestureDetector>(path);
    // }
    return element;
  }

  /// 查找从节点到某个RenderObject的路径
  List<Element> pathToObject(RenderObject renderObject,
      {bool hasTobeVisible = true}) {
    ElementNode? targetNode = traversal((ElementNode node) {
      return node.element.renderObject != renderObject;
    }, hasTobeVisible: hasTobeVisible);

    // 通过父节点串联出路径
    final List<Element> path = <Element>[];
    while (targetNode != null) {
      path.insert(0, targetNode.element);
      targetNode = targetNode.parent;
    }
    return path;
  }

  /// 遍历
  ElementNode? traversal(bool Function(ElementNode node) visitor,
      {bool hasTobeVisible = true}) {
    ElementNode? result;
    ElementNode curNode;
    final List<Element> elements = <Element>[];
    final Queue<ElementNode> nodeQueues = Queue<ElementNode>()
      ..addLast(ElementNode(this));

    while (nodeQueues.isNotEmpty) {
      curNode = nodeQueues.removeFirst();
      if (curNode != null && curNode.element != null && visitor(curNode)) {
        elements.clear();
        if (hasTobeVisible) {
          curNode.element.debugVisitOnstageChildren((e) {
            elements.add(e);
          });
        } else {
          curNode.element.visitChildElements((e) {
            elements.add(e);
          });
        }

        // 从顶层到底层
        for (int i = elements.length - 1; i >= 0; --i) {
          nodeQueues.addFirst(ElementNode(elements[i], parent: curNode));
        }
      } else {
        result = curNode;
        break;
      }
    }
    return result;
  }

  /// utils
  Element? _findFirstWidget<T>(List<Element> path) {
    // element树的遍历得从顶到底
    for (int i = path.length - 1; i >= 0; --i) {
      final Element element = path[i];
      if (element.widget is T) {
        return element;
      }
    }
    return null;
  }
}
