// lib/data/models/quiz_result_model.dart
import '../../domain/entities/quiz_result.dart';

class QuizResultModel extends QuizResult {
  const QuizResultModel({
    required super.id,
    required super.idPelajaran,
    required super.idKuis,
    required super.userAnswer,
    required super.isCorrect,
    required super.answeredAt,
  });

  factory QuizResultModel.fromJson(Map<String, dynamic> json) {
    return QuizResultModel(
      id: json['id']?.toString() ?? '',
      idPelajaran: json['idPelajaran']?.toString() ?? '',
      idKuis: json['idKuis']?.toString() ?? '',
      userAnswer: json['userAnswer']?.toString() ?? '',
      isCorrect: json['isCorrect'] == 1 || json['isCorrect'] == true,
      answeredAt: DateTime.parse(json['answeredAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idPelajaran': idPelajaran,
      'idKuis': idKuis,
      'userAnswer': userAnswer,
      'isCorrect': isCorrect ? 1 : 0,
      'answeredAt': answeredAt.toIso8601String(),
    };
  }

  factory QuizResultModel.fromEntity(QuizResult quizResult) {
    return QuizResultModel(
      id: quizResult.id,
      idPelajaran: quizResult.idPelajaran,
      idKuis: quizResult.idKuis,
      userAnswer: quizResult.userAnswer,
      isCorrect: quizResult.isCorrect,
      answeredAt: quizResult.answeredAt,
    );
  }
}

class PelajaranProgressModel extends PelajaranProgress {
  const PelajaranProgressModel({
    required super.idPelajaran,
    required super.totalKuis,
    required super.completedKuis,
    required super.correctAnswers,
    required super.score,
    super.lastAttemptAt,
    required super.isCompleted,
  });

  factory PelajaranProgressModel.fromJson(Map<String, dynamic> json) {
    return PelajaranProgressModel(
      idPelajaran: json['idPelajaran']?.toString() ?? '',
      totalKuis: json['totalKuis']?.toInt() ?? 0,
      completedKuis: json['completedKuis']?.toInt() ?? 0,
      correctAnswers: json['correctAnswers']?.toInt() ?? 0,
      score: (json['score']?.toDouble() ?? 0.0),
      lastAttemptAt: json['lastAttemptAt'] != null 
          ? DateTime.parse(json['lastAttemptAt']) 
          : null,
      isCompleted: json['isCompleted'] == 1 || json['isCompleted'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idPelajaran': idPelajaran,
      'totalKuis': totalKuis,
      'completedKuis': completedKuis,
      'correctAnswers': correctAnswers,
      'score': score,
      'lastAttemptAt': lastAttemptAt?.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory PelajaranProgressModel.fromEntity(PelajaranProgress progress) {
    return PelajaranProgressModel(
      idPelajaran: progress.idPelajaran,
      totalKuis: progress.totalKuis,
      completedKuis: progress.completedKuis,
      correctAnswers: progress.correctAnswers,
      score: progress.score,
      lastAttemptAt: progress.lastAttemptAt,
      isCompleted: progress.isCompleted,
    );
  }
}
