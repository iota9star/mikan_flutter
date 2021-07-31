import 'dart:async';

import 'package:mikan_flutter/internal/screen.dart';
import 'package:mikan_flutter/providers/base_model.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensorsModel extends BaseModel {
  StreamSubscription<UserAccelerometerEvent>?
      _userAccelerometerEventsStreamSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeEventStreamSubscription;

  SensorsModel() {
    if (isMobile) {
      // _userAccelerometerEventsStreamSubscription =
      //     userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      //   print(event);
      // });
      // _gyroscopeEventStreamSubscription =
      //     gyroscopeEvents.listen((GyroscopeEvent event) {
      //   print(event);
      // });
    }
  }

  @override
  void dispose() {
    _userAccelerometerEventsStreamSubscription?.cancel();
    _gyroscopeEventStreamSubscription?.cancel();
    super.dispose();
  }
}
