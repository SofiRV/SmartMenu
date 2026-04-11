class ApiConfig {
  static const String baseUrl = "http://192.168.1.110:8000";
  static const String apiPrefix = "";

  static String url(String path) => "$baseUrl$apiPrefix$path";
}