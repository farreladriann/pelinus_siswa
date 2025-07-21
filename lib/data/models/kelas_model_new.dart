// lib/data/models/kelas_model.dart
import '../../domain/entities/kelas.dart';
import 'pelajaran_model.dart';

class KelasModel extends Kelas {
  const KelasModel({
    required super.id,
    required super.nomorKelas,
    required super.pelajaran,
  });

  factory KelasModel.fromJson(Map<String, dynamic> json) {
    return KelasModel(
      id: json['id'] as String,
      nomorKelas: json['nomorKelas'] as String,
      pelajaran: (json['pelajaran'] as List<dynamic>)
          .map((e) => PelajaranModel.fromJson(e as Map<String, dynamic>))
          .toList(),
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
