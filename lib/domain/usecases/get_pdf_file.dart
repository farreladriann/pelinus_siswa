// lib/domain/usecases/get_pdf_file.dart
// lib/domain/usecases/get_pdf_file.dart
import '../entities/pdf_file.dart';
import '../repositories/data_repository.dart';

class GetPdfFile {
  final DataRepository repository;

  GetPdfFile(this.repository);

  Future<PdfFile?> call(String idPelajaran) async {
    return await repository.getPdfFile(idPelajaran);
  }
}
