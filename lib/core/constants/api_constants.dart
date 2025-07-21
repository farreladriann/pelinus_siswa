class ApiConstants {
  static const String baseUrl = 'https://pelinus.vercel.app';
  static const String cacheEndpoint = '/cache';
  static const String pdfEndpoint = '/pelajaran';
  
  static const int connectionTimeout = 10000; // 15 seconds - optimal for UX
  static const int receiveTimeout = 30000; // 30 seconds - for large data
  static const int syncIntervalMinutes = 30;
}