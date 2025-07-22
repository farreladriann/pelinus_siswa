// lib/data/models/kelas_model.dart
import '../../domain/entities/kelas.dart';
import 'pelajaran_model.dart';
import '../../core/utils/logger.dart';

class KelasModel extends Kelas {
  const KelasModel({
    required super.id,
    required super.nomorKelas,
    required super.pelajaran,
  });

  factory KelasModel.fromJson(Map<String, dynamic> json) {
    return KelasModel(
      id: json['id']?.toString() ?? '',
      nomorKelas: json['nomorKelas']?.toString() ?? 'Unknown',
      pelajaran: (json['pelajaran'] as List<dynamic>?)
          ?.map((e) {
            try {
              return PelajaranModel.fromJson(e as Map<String, dynamic>);
            } catch (error) {
              AppLogger.error('Error parsing pelajaran in KelasModel', error);
              return null;
            }
          })
          .where((e) => e != null)
          .cast<PelajaranModel>()
          .toList() ?? [],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomorKelas': nomorKelas,
      'pelajaran': pelajaran.map((e) => (e as PelajaranModel).toJson()).toList(),
    };
  }

  factory KelasModel.fromEntity(Kelas kelas) {
    return KelasModel(
      id: kelas.id,
      nomorKelas: kelas.nomorKelas,
      pelajaran: kelas.pelajaran,
    );
  }
}
