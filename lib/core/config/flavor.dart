enum AppFlavor {
  supabase;

  static AppFlavor fromString(String? value) {
    return AppFlavor.supabase;
  }
}

abstract final class FlavorConfig {
  static late AppFlavor current;

  static bool get isSupabase => current == AppFlavor.supabase;
}
