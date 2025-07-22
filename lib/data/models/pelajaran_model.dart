// lib/data/models/pelajaran_model.dart
import '../../domain/entities/pelajaran.dart';
import '../../core/utils/logger.dart';
import 'kuis_model.dart';

class PelajaranModel extends Pelajaran {
  const PelajaranModel({
    required super.idPelajaran,
    required super.namaPelajaran,
    required super.kuis,
  });

  factory PelajaranModel.fromJson(Map<String, dynamic> json) {
    try {
      return PelajaranModel(
        idPelajaran: json['idPelajaran']?.toString() ?? '',
        namaPelajaran: json['namaPelajaran']?.toString() ?? 'Unknown',
        kuis: (json['kuis'] as List<dynamic>?)
            ?.map((e) {
              try {
                return KuisModel.fromJson(e as Map<String, dynamic>);
              } catch (error) {
                AppLogger.warning('Error parsing kuis in PelajaranModel: $error');
                return null;
              }
            })
            .where((e) => e != null)
            .cast<KuisModel>()
            .toList() ?? [],
      );
    } catch (error) {
      AppLogger.error('Error parsing PelajaranModel: $error');
      AppLogger.debug('JSON data: $json');
      // Return default model jika ada error
      return PelajaranModel(
        idPelajaran: '',
        namaPelajaran: 'Invalid Pelajaran Data',
        kuis: [],
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'idPelajaran': idPelajaran,
      'namaPelajaran': namaPelajaran,
      'kuis': kuis.map((e) => (e as KuisModel).toJson()).toList(),
    };
  }

  factory PelajaranModel.fromEntity(Pelajaran pelajaran) {
    return PelajaranModel(
      idPelajaran: pelajaran.idPelajaran,
      namaPelajaran: pelajaran.namaPelajaran,
      kuis: pelajaran.kuis,
    );
  }
}
