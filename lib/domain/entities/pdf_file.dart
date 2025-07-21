// lib/domain/entities/pdf_file.dart
import 'package:equatable/equatable.dart';

class PdfFile extends Equatable {
  final String idPelajaran;
  final String fileName;
  final String filePath;
  final DateTime downloadedAt;

  const PdfFile({
    required this.idPelajaran,
    required this.fileName,
    required this.filePath,
    required this.downloadedAt,
  });

  @override
  List<Object> get props => [idPelajaran, fileName, filePath, downloadedAt];
}
