import 'package:flutter/material.dart';

/// 事件类型
enum EventInfoType {
  tap,
  longPress,
  drag,
}

/// 定义上报所需要的字段信息
class EventInfo {
  ///
  EventInfo(this._element, {required this.eventType});

  /// 事件类型
  final EventInfoType eventType;

  /// 当前页面路径
  String? routeName;

  /// 上报的对象，用它收集一些上报组件关心的内容：title, routeName等等.
  final Element _element;

  ///
  Widget get widget => _element.widget;

  /// 自定义信息
  Map<String, dynamic>? userData;

  ///
  Map<String, dynamic>? toMap() {
    return null;
  }
}

/// element节点
class ElementNode {
  ///
  ElementNode(this.element, {this.parent});

  ///
  ElementNode? parent;

  ///
  Element element;
}

/// 事件订阅者
abstract class EventListener {
  ///
  void handleEvent(EventInfo event);
}
