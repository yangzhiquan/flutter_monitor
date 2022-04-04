

Flutter事件收集/订阅库.

## Usage


```dart

import 'package:flutter_monitor/flutter_monitor.dart';

void main() {
  // 1
  runAndObserveApp(const App());
  // 2
  (WidgetsBinding.instance as MonitorWidgetsFlutterBinding).addListener(DemoListener());
}

class DemoListener extends EventListener {
  @override
  void handleEvent(EventInfo event) {
    // 3
    debugPrint('$event');
  }
}

```

