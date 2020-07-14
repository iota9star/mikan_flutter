import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:mikan_flutter/providers/models/base_model.dart';

class FirebaseModel extends BaseModel {
  FirebaseAnalytics _analytics;

  FirebaseAnalyticsObserver _observer;

  FirebaseAnalytics get analytics => _analytics;

  FirebaseAnalyticsObserver get observer => _observer;

  FirebaseModel() {
    _analytics = FirebaseAnalytics();
    _observer = FirebaseAnalyticsObserver(analytics: _analytics);
  }
}
