import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

/// 收集点击事件各种信息的最终结果
class GestureEventResult {
  final PointerEvent? event;

  final GestureRecognizer gesture;

  final HitTestTarget? hitTestTarget;

  // 是否已经确定是获胜者
  final bool isWinArena;

  GestureEventResult(
      this.isWinArena, this.event, this.gesture, this.hitTestTarget);
}

/// 重载HitTestTarget的handleEvent，
class _HitTestTargetHook implements HitTestTarget {
  final HitTestTarget target;

  _HitTestTargetHook(this.target);

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    if (entry is HitTestEntryWrapper) {
      //这个entry是被我们包装过的对象
      if (entry.onHandleEvent != null) {
        entry.onHandleEvent!(event, target);
      }
      //handleEvent应该传入原始真实的entry对象
      target.handleEvent(event, entry.entry);
    } else {
      //这个entry不是被我们包装过的对象，透传调用即可
      target.handleEvent(event, entry);
    }
  }
}

/// 重载HitTestEntry的target, 用于hook target 的 handleEvent
class HitTestEntryWrapper extends HitTestEntry {
  final HitTestEntry entry;

  final Function(PointerEvent, HitTestTarget)? onHandleEvent;

  HitTestEntryWrapper(this.entry, this.onHandleEvent)
      : super(_HitTestTargetHook(entry.target));

  @override
  Matrix4? get transform => entry.transform;
}

/// 包装HitTestResult，用于传递点击处理onHandleEvent 给每个Entry
class HitTestResultWrapper extends HitTestResult {
  final HitTestResult result;

  final Function(PointerEvent, HitTestTarget) onHandleEvent;

  HitTestResultWrapper(this.result, {required this.onHandleEvent}) : super();

  @override
  Iterable<HitTestEntry> get path {
    return result.path.map((e) => HitTestEntryWrapper(e, onHandleEvent));
  }
}

/// 包装手势竞技者，用于hook acceptGesture事件
class GestureArenaMemberWrapper implements GestureArenaMember {
  final GestureArenaMember innerMember;

  final HitTestTarget? hitTestTarget;

  final Function(GestureArenaMemberWrapper) onAcceptGesture;

  GestureArenaMemberWrapper(this.innerMember,
      {required this.hitTestTarget,
      required this.onAcceptGesture,
      HitTestTarget? currentHitTestTarget});

  @override
  void acceptGesture(int pointer) {
    if (innerMember is GestureRecognizer) {
      onAcceptGesture(this);
    }
    innerMember.acceptGesture(pointer);
  }

  @override
  void rejectGesture(int pointer) => innerMember.rejectGesture(pointer);
}
