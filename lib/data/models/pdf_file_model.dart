// lib/data/models/pdf_file_model.dart
import '../../domain/entities/pdf_file.dart';

class PdfFileModel extends PdfFile {
  const PdfFileModel({
    required super.idPelajaran,
    required super.fileName,
    required super.filePath,
    required super.downloadedAt,
  });

  factory PdfFileModel.fromJson(Map<String, dynamic> json) {
    return PdfFileModel(
      idPelajaran: json['idPelajaran'] as String,
      fileName: json['fileName'] as String,
      filePath: json['filePath'] as String,
      downloadedAt: DateTime.parse(json['downloadedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idPelajaran': idPelajaran,
      'fileName': fileName,
      'filePath': filePath,
      'downloadedAt': downloadedAt.toIso8601String(),
    };
  }

  factory PdfFileModel.fromEntity(PdfFile pdfFile) {
    return PdfFileModel(
      idPelajaran: pdfFile.idPelajaran,
      fileName: pdfFile.fileName,
      filePath: pdfFile.filePath,
      downloadedAt: pdfFile.downloadedAt,
    );
  }
}
