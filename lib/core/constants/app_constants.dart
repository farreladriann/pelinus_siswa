class AppConstants {
  static const String appName = 'Pelinus Mengajar';
  static const String baseUrl = 'https://pelinus.vercel.app';
  static const String databaseName = 'pelinus_siswa.db';
  static const int databaseVersion = 4; // Updated to version 4 for quiz management fixes
  
  // Sync intervals
  static const Duration syncInterval = Duration(minutes: 30);
  
  // Table names
  static const String kelasTable = 'kelas';
  static const String pelajaranTable = 'pelajaran';
  static const String kuisTable = 'kuis';
  static const String pdfTable = 'pdf_files';
  static const String quizResultsTable = 'quiz_results';
  static const String progressTable = 'pelajaran_progress';
  
  // PDF storage
  static const String pdfDirectory = 'pdf_files';
}