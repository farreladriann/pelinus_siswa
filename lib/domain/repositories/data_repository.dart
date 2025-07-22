// lib/domain/repositories/data_repository.dart
import '../entities/kelas.dart';
import '../entities/pdf_file.dart';
import '../entities/quiz_result.dart';

abstract class DataRepository {
  Future<List<Kelas>> getCachedData();
  Future<void> syncData();
  Future<PdfFile?> getPdfFile(String idPelajaran);
  Future<void> saveCachedData(List<Kelas> kelasList);
  
  // Quiz Management
  Future<void> saveQuizResult(QuizResult result);
  Future<List<QuizResult>> getQuizResultsByPelajaran(String idPelajaran);
  Future<QuizResult?> getQuizResult(String idKuis);
  Future<void> resetPelajaranProgress(String idPelajaran);
  Future<PelajaranProgress?> getPelajaranProgress(String idPelajaran);
}
