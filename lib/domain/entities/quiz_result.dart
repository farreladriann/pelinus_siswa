// lib/domain/entities/quiz_result.dart
import 'package:equatable/equatable.dart';

class QuizResult extends Equatable {
  final String id;
  final String idPelajaran;
  final String idKuis;
  final String userAnswer;
  final bool isCorrect;
  final DateTime answeredAt;

  const QuizResult({
    required this.id,
    required this.idPelajaran,
    required this.idKuis,
    required this.userAnswer,
    required this.isCorrect,
    required this.answeredAt,
  });

  @override
  List<Object> get props => [
    id, idPelajaran, idKuis, userAnswer, isCorrect, answeredAt
  ];
}

class PelajaranProgress extends Equatable {
  final String idPelajaran;
  final int totalKuis;
  final int completedKuis;
  final int correctAnswers;
  final double score;
  final DateTime? lastAttemptAt;
  final bool isCompleted;

  const PelajaranProgress({
    required this.idPelajaran,
    required this.totalKuis,
    required this.completedKuis,
    required this.correctAnswers,
    required this.score,
    this.lastAttemptAt,
    required this.isCompleted,
  });

  @override
  List<Object?> get props => [
    idPelajaran, totalKuis, completedKuis, correctAnswers, 
    score, lastAttemptAt, isCompleted
  ];
}
