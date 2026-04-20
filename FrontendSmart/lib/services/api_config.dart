class ApiConfig {
  static const String baseUrl = "http://192.168.1.108:8000";
  static const String apiPrefix = "/userApi/v1";

  static String url(String path) => "$baseUrl$apiPrefix$path";
}