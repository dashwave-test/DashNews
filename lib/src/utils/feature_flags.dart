import 'package:flutter/foundation.dart';

class FeatureFlags extends ChangeNotifier {
  final Set<String> _disabledFeatures = {};

  bool isFeatureEnabled(String featureName) {
    return !_disabledFeatures.contains(featureName);
  }

  void disableFeature(String featureName) {
    _disabledFeatures.add(featureName);
    notifyListeners();
  }

  void enableFeature(String featureName) {
    _disabledFeatures.remove(featureName);
    notifyListeners();
  }
}