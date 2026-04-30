enum AppFlavor {
  mock,
  supabase;

  static AppFlavor fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'supabase':
        return AppFlavor.supabase;
      case 'mock':
      default:
        return AppFlavor.mock;
    }
  }
}

abstract final class FlavorConfig {
  static late AppFlavor current;

  static bool get isMock => current == AppFlavor.mock;
  static bool get isSupabase => current == AppFlavor.supabase;
}
