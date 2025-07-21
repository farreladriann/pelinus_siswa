import 'package:equatable/equatable.dart';
import 'pelajaran.dart';

class Kelas extends Equatable {
  final String id;
  final String nomorKelas;
  final List<Pelajaran> pelajaran;

  const Kelas({
    required this.id,
    required this.nomorKelas,
    required this.pelajaran,
  });

  @override
  List<Object> get props => [id, nomorKelas, pelajaran];
}