import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:mikan_flutter/providers/base_model.dart';

class FirebaseModel extends BaseModel {
  late FirebaseAnalytics _analytics;

  late FirebaseAnalyticsObserver _observer;

  FirebaseAnalytics get analytics => _analytics;

  FirebaseAnalyticsObserver get observer => _observer;

  FirebaseModel() {
    _analytics = FirebaseAnalytics.instance;
    _observer = FirebaseAnalyticsObserver(analytics: _analytics);
  }
}
