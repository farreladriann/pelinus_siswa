// lib/domain/usecases/quiz_management.dart
import '../entities/quiz_result.dart';
import '../repositories/data_repository.dart';

class SaveQuizResult {
  final DataRepository repository;

  SaveQuizResult(this.repository);

  Future<void> call(QuizResult result) async {
    return await repository.saveQuizResult(result);
  }
}

class GetQuizResultsByPelajaran {
  final DataRepository repository;

  GetQuizResultsByPelajaran(this.repository);

  Future<List<QuizResult>> call(String idPelajaran) async {
    return await repository.getQuizResultsByPelajaran(idPelajaran);
  }
}

class GetQuizResult {
  final DataRepository repository;

  GetQuizResult(this.repository);

  Future<QuizResult?> call(String idKuis) async {
    return await repository.getQuizResult(idKuis);
  }
}

class ResetPelajaranProgress {
  final DataRepository repository;

  ResetPelajaranProgress(this.repository);

  Future<void> call(String idPelajaran) async {
    return await repository.resetPelajaranProgress(idPelajaran);
  }
}

class GetPelajaranProgress {
  final DataRepository repository;

  GetPelajaranProgress(this.repository);

  Future<PelajaranProgress?> call(String idPelajaran) async {
    return await repository.getPelajaranProgress(idPelajaran);
  }
}
