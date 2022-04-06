import 'package:flutter/gestures.dart';
import 'handler/app_event_handler.dart';
import 'model/hit_test_wrapper.dart';

/// 重载手势竞争管理类的add，拦截加入的成员，包装成自定义的成员对象，记录事件、target、winner
class MonitorGestureArenaManager extends GestureArenaManager {
  PointerEvent? _currentEvent;
  HitTestTarget? _currentHitTestTarget;
  GestureArenaMemberWrapper? _arenaWinner;

  EventHandler? eventHandler;

  HitTestResult? wrapHitTestResult(
      PointerEvent event, HitTestResult? hitTestResult) {
    _currentEvent = event;

    // 这里把每个阶段的winner事件都通知外部（整个down-up过程 最终胜出的手势才会执行一次AcceptGesture
    if (_arenaWinner != null) {
      _recordGestureEvent(_arenaWinner!, false);
      // Up后把_arenaWinner置空
      if (event is PointerUpEvent) {
        _arenaWinner = null;
      }
    }

    if (hitTestResult != null) {
      return HitTestResultWrapper(hitTestResult,
          onHandleEvent: (event, target) {
        _currentHitTestTarget = target;
      });
    }
    return hitTestResult;
  }

  /// 上报事件结果.
  void _recordGestureEvent(GestureArenaMemberWrapper member, bool isWinArena) {
    final eventResult = GestureEventResult(isWinArena, _currentEvent,
        (member.innerMember as GestureRecognizer), member.hitTestTarget);
    eventHandler?.handleGestureEvent(eventResult);
  }

  @override
  GestureArenaEntry add(int pointer, GestureArenaMember member) {
    return super.add(
        pointer,
        GestureArenaMemberWrapper(member, hitTestTarget: _currentHitTestTarget,
            onAcceptGesture: (GestureArenaMemberWrapper member) {
          if (!(_currentEvent != null && _currentEvent is PointerUpEvent)) {
            _arenaWinner = member;
          }
          _recordGestureEvent(member, true);
        }));
  }
}
