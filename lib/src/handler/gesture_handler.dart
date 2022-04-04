part of 'app_event_handler.dart';

///
extension GestureHandler on AppEventHandler {
  // 处理各种类型的手势winner
  void _handleGestureEvent(GestureEventResult gestureEvent) {
    runZonedGuarded(() {
      if (gestureEvent.gesture is TapGestureRecognizer) {
        _handleTapGestureEvent(gestureEvent);
      } else if (gestureEvent.gesture is LongPressGestureRecognizer) {
        _handleLongPressGestureEvent(gestureEvent);
      } else if (gestureEvent.gesture is HorizontalDragGestureRecognizer) {
        _handleHorizontalDragGestureEvent(gestureEvent);
      }
    }, (Object exception, StackTrace stackTrace) {
      debugPrint('monitor $stackTrace');
    });
  }

  void _handleTapGestureEvent(GestureEventResult result) {
    // Tap手势必须是up的类型才需要记录处理
    if (result.event is! PointerUpEvent) {
      return;
    }

    // 手势得是possible 或者是 winArena
    final TapGestureRecognizer gesture = result.gesture as TapGestureRecognizer;
    if ((gesture.state != GestureRecognizerState.possible) &&
        (!result.isWinArena)) {
      return;
    }

    final RenderObject renderObj = result.hitTestTarget! as RenderObject;
    final Element? element =
        (_rootContext as Element).gestureElementForRenderObject(renderObj);
    if (element == null) {
      // Log.e(this, NoFindWidgetErr);
      return;
    }
    _notifyListeners(EventInfo(element, eventType: EventInfoType.tap));
  }

  void _handleLongPressGestureEvent(GestureEventResult result) {
    /// 长按手势只要是winner，就是确定的.
    if (result.isWinArena) {
      final RenderObject renderObj = result.hitTestTarget! as RenderObject;
      final Element? element =
          (_rootContext as Element).gestureElementForRenderObject(renderObj);
      if (element == null) {
        // Log.e(this, NoFindWidgetErr);
        return;
      }
      _notifyListeners(EventInfo(element, eventType: EventInfoType.longPress));
    }
  }

  /// 滑动手势的临时变量..
  // late WidgetTarget _currentSlideTarget;
  // double _currentSlideOffset = 0;
  void _handleHorizontalDragGestureEvent(GestureEventResult ge) {
    if (ge.event is PointerUpEvent) {
      // 侧滑结束
      // if (_currentSlideOffset.abs() > 30 && _currentSlideTarget != null) {
      // runZonedGuarded(() {
      //   _currentSlideTarget.routeName = topRouteName;
      //   reportEvent(EventBuilder.horizontalDrag(
      //       _currentSlideTarget, _currentSlideOffset));
      // }, (exception, stackTrace) {
      //   Log.e(this, '$exception');
      // });
      // }
    } else {
      // 侧滑中
      if (ge.isWinArena) {
        // _currentSlideOffset = ge.event.delta.dx;

        // // 侧滑手势开始时获取title最准确，因为侧滑按钮出来会找不到item信息
        // var element = (_rootContext as Element).gestureElementForRenderObject(
        //     ge.hitTestTarget as RenderObject);
        // if (element != null) {
        //   _currentSlideTarget = _makeWidgetTargetByElement(element);
        //   _currentSlideTarget.userData =
        //       userDataFinder.getFromWidget(element.widget);
        // }
      } else {
        // _currentSlideOffset += ge.event.delta.dx;
      }
    }
  }
}
