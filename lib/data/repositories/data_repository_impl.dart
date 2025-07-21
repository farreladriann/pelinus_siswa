// lib/data/repositories/data_repository_impl.dart
import 'dart:io';
import '../../domain/repositories/data_repository.dart';
import '../../domain/entities/kelas.dart';
import '../../domain/entities/pdf_file.dart';
import '../datasources/local/database_helper.dart';
import '../datasources/remote/api_service.dart';
import '../models/pdf_file_model.dart';
import '../../core/network/network_info.dart';
import '../../core/error/exceptions.dart';

class DataRepositoryImpl implements DataRepository {
  final ApiService apiService;
  final DatabaseHelper databaseHelper;
  final NetworkInfo networkInfo;

  DataRepositoryImpl({
    required this.apiService,
    required this.databaseHelper,
    required this.networkInfo,
  });

  @override
  Future<List<Kelas>> getCachedData() async {
    try {
      return await databaseHelper.getAllKelas();
    } catch (e) {
      throw CacheException('Failed to get cached data: ${e.toString()}');
    }
  }

  @override
  Future<void> syncData() async {
    if (!await networkInfo.isConnected) {
      throw NetworkException('No internet connection available');
    }

    try {
      // 1. Ambil data dari API
      final newKelasList = await apiService.getCachedData();
      
      // 2. Dapatkan semua ID pelajaran yang ada saat ini
      final currentPelajaranIds = await databaseHelper.getAllPelajaranIds();
      
      // 3. Simpan data baru ke database (akan mengganti semua data lama)
      await databaseHelper.saveAllData(newKelasList);
      
      // 4. Cari ID pelajaran baru yang perlu diunduh PDF-nya
      final newPelajaranIds = <String>[];
      for (var kelas in newKelasList) {
        for (var pelajaran in kelas.pelajaran) {
          newPelajaranIds.add(pelajaran.idPelajaran);
        }
      }
      
      // 5. Unduh PDF untuk pelajaran baru
      for (var kelas in newKelasList) {
        for (var pelajaran in kelas.pelajaran) {
          final pdfExists = await databaseHelper.getPdfFile(pelajaran.idPelajaran);
          
          if (pdfExists == null) {
            try {
              final pdfFile = await apiService.downloadPdf(
                pelajaran.idPelajaran,
                pelajaran.namaPelajaran,
              );
              await databaseHelper.insertPdfFile(PdfFileModel.fromEntity(pdfFile));
            } catch (e) {
              // Log error for PDF download failure
              // print('Failed to download PDF for ${pelajaran.namaPelajaran}: $e');
            }
          }
        }
      }
      
      // 6. Hapus PDF yang tidak lagi ada di data baru
      final removedPelajaranIds = currentPelajaranIds
          .where((id) => !newPelajaranIds.contains(id))
          .toList();
      
      for (var idPelajaran in removedPelajaranIds) {
        final pdfFile = await databaseHelper.getPdfFile(idPelajaran);
        if (pdfFile != null) {
          // Hapus file PDF dari storage
          final file = File(pdfFile.filePath);
          if (await file.exists()) {
            await file.delete();
          }
          // Hapus record dari database
          await databaseHelper.deletePdfFile(idPelajaran);
        }
      }
      
    } catch (e) {
      if (e is NetworkException || e is ServerException) {
        rethrow;
      }
      throw ServerException('Sync failed: ${e.toString()}');
    }
  }

  @override
  Future<PdfFile?> getPdfFile(String idPelajaran) async {
    try {
      return await databaseHelper.getPdfFile(idPelajaran);
    } catch (e) {
      throw CacheException('Failed to get PDF file: ${e.toString()}');
    }
  }

  @override
  Future<void> saveCachedData(List<Kelas> kelasList) async {
    try {
      await databaseHelper.saveAllData(kelasList);
    } catch (e) {
      throw CacheException('Failed to save cached data: ${e.toString()}');
    }
  }
}
