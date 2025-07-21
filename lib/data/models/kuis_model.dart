// lib/data/models/kuis_model.dart
import '../../domain/entities/kuis.dart';

class KuisModel extends Kuis {
  const KuisModel({
    required super.idKuis,
    required super.nomorKuis,
    required super.soal,
    required super.opsiA,
    required super.opsiB,
    required super.opsiC,
    required super.opsiD,
    required super.opsiJawaban,
  });

  factory KuisModel.fromJson(Map<String, dynamic> json) {
    return KuisModel(
      idKuis: json['idKuis'] as String,
      nomorKuis: json['nomorKuis'] as int,
      soal: json['soal'] as String,
      opsiA: json['opsiA'] as String,
      opsiB: json['opsiB'] as String,
      opsiC: json['opsiC'] as String,
      opsiD: json['opsiD'] as String,
      opsiJawaban: json['opsiJawaban'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idKuis': idKuis,
      'nomorKuis': nomorKuis,
      'soal': soal,
      'opsiA': opsiA,
      'opsiB': opsiB,
      'opsiC': opsiC,
      'opsiD': opsiD,
      'opsiJawaban': opsiJawaban,
    };
  }

  factory KuisModel.fromEntity(Kuis kuis) {
    return KuisModel(
      idKuis: kuis.idKuis,
      nomorKuis: kuis.nomorKuis,
      soal: kuis.soal,
      opsiA: kuis.opsiA,
      opsiB: kuis.opsiB,
      opsiC: kuis.opsiC,
      opsiD: kuis.opsiD,
      opsiJawaban: kuis.opsiJawaban,
    );
  }
}
