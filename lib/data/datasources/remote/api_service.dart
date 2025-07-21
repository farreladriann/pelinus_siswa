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
      print('🔄 Fetching data from API...');
      final response = await _dio.get(ApiConstants.cacheEndpoint);
      
      if (response.statusCode == 200) {
        final dynamic responseData = response.data;
        print('📥 Received response data type: ${responseData.runtimeType}');
        
        List<KelasModel> kelasList = [];
        
        if (responseData is Map<String, dynamic>) {
          // Handle response format: {kelasId: {kelasData}}
          print('📊 Processing Map format with ${responseData.length} entries');
          responseData.forEach((kelasId, kelasJson) {
            try {
              final kelasData = kelasJson as Map<String, dynamic>;
              
              // Add kelasId if missing in data
              if (kelasData['id'] == null) {
                kelasData['id'] = kelasId;
              }
              
              // Safe parsing with null checks
              final pelajaranData = kelasData['pelajaran'] as List<dynamic>? ?? [];
              List<PelajaranModel> pelajaranList = [];
              
              for (var pelajaranJson in pelajaranData) {
                try {
                  if (pelajaranJson is Map<String, dynamic>) {
                    // Enhanced parsing with validation
                    if (pelajaranJson['idPelajaran'] != null && 
                        pelajaranJson['namaPelajaran'] != null) {
                      
                      // Handle kuis data safely
                      final kuisData = pelajaranJson['kuis'] as List<dynamic>? ?? [];
                      pelajaranJson['kuis'] = kuisData;
                      
                      pelajaranList.add(PelajaranModel.fromJson(pelajaranJson));
                      print('✅ Parsed pelajaran: ${pelajaranJson['namaPelajaran']} with ${kuisData.length} kuis');
                    } else {
                      print('⚠️ Skipping pelajaran with missing required fields');
                    }
                  }
                } catch (e) {
                  print('❌ Error parsing pelajaran: $e');
                  print('📄 Problematic pelajaran data: $pelajaranJson');
                  // Skip invalid pelajaran, continue processing
                }
              }
              
              kelasList.add(KelasModel(
                id: kelasData['id']?.toString() ?? kelasId,
                nomorKelas: kelasData['nomorKelas']?.toString() ?? 'Unknown',
                pelajaran: pelajaranList,
              ));
              
              print('✅ Parsed kelas: ${kelasData['nomorKelas']} with ${pelajaranList.length} pelajaran');
              
            } catch (e) {
              print('❌ Error parsing kelas $kelasId: $e');
              print('📄 Problematic kelas data: $kelasJson');
              // Skip invalid kelas, continue processing
            }
          });
        } else if (responseData is List<dynamic>) {
          // Handle response format: [kelasData, kelasData, ...]
          print('📊 Processing List format with ${responseData.length} entries');
          for (var kelasJson in responseData) {
            try {
              if (kelasJson is Map<String, dynamic>) {
                kelasList.add(KelasModel.fromJson(kelasJson));
                print('✅ Parsed kelas from array: ${kelasJson['nomorKelas']}');
              }
            } catch (e) {
              print('❌ Error parsing kelas from array: $e');
              print('📄 Problematic kelas data: $kelasJson');
            }
          }
        } else {
          print('⚠️ Unexpected response format: ${responseData.runtimeType}');
          print('📄 Response data: $responseData');
        }
        
        print('✅ Successfully parsed ${kelasList.length} kelas from API');
        
        // Validate that we have data
        if (kelasList.isEmpty) {
          print('⚠️ Warning: No valid kelas data found in response');
        }
        
        return kelasList;
      } else {
        throw ServerException('Failed to load cache data: HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('🚨 DioException in getCachedData:');
      print('  Type: ${e.type}');
      print('  Message: ${e.message}');
      print('  Response: ${e.response?.data}');
      print('  Status Code: ${e.response?.statusCode}');
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ServerException('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw ServerException('No internet connection. Please check your network settings.');
      } else if (e.type == DioExceptionType.badResponse) {
        final statusCode = e.response?.statusCode ?? 'unknown';
        final responseData = e.response?.data?.toString() ?? 'no data';
        throw ServerException('Server error: HTTP $statusCode - $responseData');
      } else {
        throw ServerException('Network error: ${e.message ?? 'Unknown error'}');
      }
    } on FormatException catch (e) {
      print('🚨 FormatException in getCachedData: $e');
      throw ServerException('Data format error: Unable to parse server response');
    } on TypeError catch (e) {
      print('🚨 TypeError in getCachedData: $e');
      throw ServerException('Data type error: Server returned unexpected data structure');
    } catch (e, stackTrace) {
      print('🚨 Unexpected error in getCachedData: $e');
      print('🔍 Stack trace: $stackTrace');
      throw ServerException('Unexpected error occurred: ${e.toString()}');
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
