class SupabaseConfig {
  SupabaseConfig._();

  // A senha do usuário é flutter_user_pass
  static const url = "https://bwbwvejfmmyuzlijtdkl.supabase.co";
  static const publishableKey = "sb_publishable_ML9-hljmitTqXYNyDj0fQA__PDVtb_D";
  static const favoritesTable = 'favorite_products';

  static bool get isConfigured {
    return url.trim().isNotEmpty && publishableKey.trim().isNotEmpty;
  }
}
