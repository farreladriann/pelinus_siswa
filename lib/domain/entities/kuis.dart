// lib/domain/entities/kuis.dart
import 'package:equatable/equatable.dart';

class Kuis extends Equatable {
  final String idKuis;
  final int nomorKuis;
  final String soal;
  final String opsiA;
  final String opsiB;
  final String opsiC;
  final String opsiD;
  final String opsiJawaban;

  const Kuis({
    required this.idKuis,
    required this.nomorKuis,
    required this.soal,
    required this.opsiA,
    required this.opsiB,
    required this.opsiC,
    required this.opsiD,
    required this.opsiJawaban,
  });

  @override
  List<Object> get props => [
    idKuis, nomorKuis, soal, opsiA, opsiB, opsiC, opsiD, opsiJawaban
  ];
}