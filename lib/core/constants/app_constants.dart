class AppConstants {
  static const String appName = 'Pelinus Mengajar';
  static const String baseUrl = 'https://pelinus.vercel.app';
  static const String databaseName = 'pelinus_siswa.db';
  static const int databaseVersion = 1;
  
  // Sync intervals
  static const Duration syncInterval = Duration(minutes: 30);
  
  // Table names
  static const String kelasTable = 'kelas';
  static const String pelajaranTable = 'pelajaran';
  static const String kuisTable = 'kuis';
  static const String pdfTable = 'pdf_files';
  
  // PDF storage
  static const String pdfDirectory = 'pdf_files';
}