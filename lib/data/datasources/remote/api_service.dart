// lib/data/datasources/remote/api_service.dart
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import '../../models/kelas_model.dart';
import '../../models/pelajaran_model.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../domain/entities/pdf_file.dart';
import '../../models/pdf_file_model.dart';

class ApiService {
  final Dio _dio;

  ApiService(this._dio) {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.connectTimeout = Duration(milliseconds: ApiConstants.connectionTimeout);
    _dio.options.receiveTimeout = Duration(milliseconds: ApiConstants.receiveTimeout);
  }

  Future<List<KelasModel>> getCachedData() async {
    try {
      final response = await _dio.get(ApiConstants.cacheEndpoint);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> cacheData = response.data;
        
        List<KelasModel> kelasList = [];
        
        cacheData.forEach((kelasId, kelasJson) {
          final kelasData = kelasJson as Map<String, dynamic>;
          
          kelasList.add(KelasModel(
            id: kelasId,
            nomorKelas: kelasData['nomorKelas'] as String,
            pelajaran: (kelasData['pelajaran'] as List<dynamic>)
                .map((p) => PelajaranModel.fromJson(p as Map<String, dynamic>))
                .toList(),
          ));
        });
        
        return kelasList;
      } else {
        throw ServerException('Failed to load cache data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ServerException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw ServerException('No internet connection');
      } else {
        throw ServerException('Failed to load cache data: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  Future<PdfFile> downloadPdf(String idPelajaran, String namaPelajaran) async {
    try {
      final url = '${ApiConstants.pdfEndpoint}/$idPelajaran/pdf';
      
      // Dapatkan direktori untuk menyimpan file
      final directory = await getApplicationDocumentsDirectory();
      final pdfDir = Directory(path.join(directory.path, 'pdfs'));
      
      if (!await pdfDir.exists()) {
        await pdfDir.create(recursive: true);
      }
      
      final fileName = '${namaPelajaran}_$idPelajaran.pdf';
      final filePath = path.join(pdfDir.path, fileName);
      
      // Download file
      final response = await _dio.download(
        url,
        filePath,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
        ),
      );
      
      if (response.statusCode == 200) {
        return PdfFileModel(
          idPelajaran: idPelajaran,
          fileName: fileName,
          filePath: filePath,
          downloadedAt: DateTime.now(),
        );
      } else {
        throw ServerException('Failed to download PDF: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ServerException('Download timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw ServerException('No internet connection');
      } else {
        throw ServerException('Failed to download PDF: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error during PDF download: ${e.toString()}');
    }
  }
}
