class FeatureFlags {
  static const String EMAIL_VERIFICATION = 'email_verification';
  static const String LOGIN_REMEMBER_ME = 'login_remember_me';
  static const String SOCIAL_LOGIN = 'social_login';
  static const String SIGNUP_REMEMBER_ME = 'signup_remember_me';
  static const String SOCIAL_SIGNUP = 'social_signup';

  static final List<String> _disabledFeatures = [
    EMAIL_VERIFICATION,
    SOCIAL_LOGIN,
    LOGIN_REMEMBER_ME,
    SOCIAL_SIGNUP,
    SIGNUP_REMEMBER_ME,
  ];

  static void disableFeature(String feature) {
    if (!_disabledFeatures.contains(feature)) {
      _disabledFeatures.add(feature);
    }
  }

  static void enableFeature(String feature) {
    _disabledFeatures.remove(feature);
  }

  static bool isFeatureDisabled(String feature) {
    return _disabledFeatures.contains(feature);
  }

  static bool isFeatureEnabled(String feature) {
    return !isFeatureDisabled(feature);
  }
}