// lib/domain/entities/pelajaran.dart
import 'package:equatable/equatable.dart';
import 'kuis.dart';

class Pelajaran extends Equatable {
  final String idPelajaran;
  final String namaPelajaran;
  final List<Kuis> kuis;

  const Pelajaran({
    required this.idPelajaran,
    required this.namaPelajaran,
    required this.kuis,
  });

  @override
  List<Object> get props => [idPelajaran, namaPelajaran, kuis];
}
