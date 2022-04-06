import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'handler/app_event_handler.dart';
import 'model/handler_model.dart';
import 'monitor_gesture_arena_manager.dart';
import 'monitor_root_widget.dart';

/// 更换runApp入口，使用自定义子类重载WidgetsFlutterBinding，用于记录事件派发
void runAndObserveApp(Widget app,
        {Function(MonitorWidgetsFlutterBinding monitor)? beforeAttach,
        Function(EventInfo event)? eventListener}) =>
    MonitorWidgetsFlutterBinding._run(app, beforeAttach: beforeAttach);

/// MonitorWidgetsFlutterBinding
/// 记录应用事件
class MonitorWidgetsFlutterBinding extends WidgetsFlutterBinding {
  // 开放给外层其他需要包装根节点的需求使用
  Function(MonitorWidgetsFlutterBinding monitor)? _beforeAttach;

  // 这个函数必须要在WidgetsFlutterBinding的ensureInitialized之前执行，确保其他代码没有预先调用了它
  static WidgetsBinding ensureInitialized() {
    if (WidgetsBinding.instance == null) {
      MonitorWidgetsFlutterBinding();
    }
    return WidgetsBinding.instance!;
  }

  @override
  void initInstances() {
    super.initInstances();
    (gestureArena as MonitorGestureArenaManager).eventHandler = _handler;
  }

  // 重载该函数获取rootWidget
  @override
  void attachRootWidget(Widget rootWidget) {
    if (_beforeAttach != null) {
      _beforeAttach!(this);
    }
    rootWidget = MonitorRootWidget(
      child: rootWidget,
      handler: _handler,
    );
    super.attachRootWidget(rootWidget);
  }

  // 重载手势竞争管理类，用于记录手势事件
  @override
  final GestureArenaManager gestureArena = MonitorGestureArenaManager();

  // 从这里开始包装hitTestResult.
  @override
  void dispatchEvent(PointerEvent event, HitTestResult? hitTestResult) {
    final monitoredResult = (gestureArena as MonitorGestureArenaManager)
        .wrapHitTestResult(event, hitTestResult);
    super.dispatchEvent(event, monitoredResult);
  }

  /// 更换runApp入口，使用自定义子类重载WidgetsFlutterBinding，用于记录事件派发
  static void _run(Widget app,
      {Function(MonitorWidgetsFlutterBinding monitor)? beforeAttach}) {
    MonitorWidgetsFlutterBinding.ensureInitialized()
        as MonitorWidgetsFlutterBinding
      .._beforeAttach = beforeAttach
      ..scheduleAttachRootWidget(app)
      ..scheduleWarmUpFrame();
  }

  /// 事件收集、处理
  final AppEventHandler _handler = AppEventHandler();

  /// 添加订阅者
  void addListener(EventListener listener) => _handler.addListener(listener);

  ///
  void removeListener(EventListener listener) =>
      _handler.removeListener(listener);
}
