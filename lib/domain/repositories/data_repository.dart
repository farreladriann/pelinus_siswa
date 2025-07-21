// lib/domain/repositories/data_repository.dart
import '../entities/kelas.dart';
import '../entities/pdf_file.dart';

abstract class DataRepository {
  Future<List<Kelas>> getCachedData();
  Future<void> syncData();
  Future<PdfFile?> getPdfFile(String idPelajaran);
  Future<void> saveCachedData(List<Kelas> kelasList);
}
