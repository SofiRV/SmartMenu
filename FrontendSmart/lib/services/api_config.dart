class ApiConfig {
  static const String baseUrl = "https://web-production-45a3b.up.railway.app";
  static const String apiPrefix = "/userApi/v1";

  /// path ejemplo: "/account" o "/account/123"
  static String url(String path) => "$baseUrl$apiPrefix$path";
}