class FeatureFlags {
  static const String EMAIL_VERIFICATION = 'email_verification';
  static const String LOGIN_REMEMBER_ME = 'login_remember_me';
  static const String SOCIAL_LOGIN = 'social_login';
  static const String SIGNUP_REMEMBER_ME = 'signup_remember_me';
  static const String SOCIAL_SIGNUP = 'social_signup';
  static const String DISABLE_NEWS_SOURCES = 'disable_news_sources';
  static const String HOME_SCREEN_TRENDING = 'home_screen_trending';
  static const String HOME_SCREEN_NOTIFICATIONS = 'home_screen_notifications';
  static const String HOME_SCREEN_SEARCH = 'home_screen_search';
  static const String EXPLORE_SCREEN_POPULAR_TOPIC = 'explore_screen_popular_topic';

  static final List<String> _disabledFeatures = [
    EMAIL_VERIFICATION,
    SOCIAL_LOGIN,
    LOGIN_REMEMBER_ME,
    SOCIAL_SIGNUP,
    SIGNUP_REMEMBER_ME,
    DISABLE_NEWS_SOURCES,
    HOME_SCREEN_TRENDING,
    HOME_SCREEN_NOTIFICATIONS,
    HOME_SCREEN_SEARCH,
    EXPLORE_SCREEN_POPULAR_TOPIC,
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