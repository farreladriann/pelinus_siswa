// lib/data/models/pelajaran_model.dart
import '../../domain/entities/pelajaran.dart';
import 'kuis_model.dart';

class PelajaranModel extends Pelajaran {
  const PelajaranModel({
    required super.idPelajaran,
    required super.namaPelajaran,
    required super.kuis,
  });

  factory PelajaranModel.fromJson(Map<String, dynamic> json) {
    return PelajaranModel(
      idPelajaran: json['idPelajaran'] as String,
      namaPelajaran: json['namaPelajaran'] as String,
      kuis: (json['kuis'] as List<dynamic>)
          .map((e) => KuisModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
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
