class HubLog {
  static bool isEnabled = false;

  HubLog._();

  static final HubLog instance = HubLog._();

  static HubLog get i => instance;

  void log(Object message) {
    if (isEnabled) print(message);
  }

  void info(Object message) {
    if (isEnabled) print(message);
  }
}
