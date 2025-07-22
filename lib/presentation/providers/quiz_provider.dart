// lib/presentation/providers/quiz_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/quiz_result.dart';
import '../../domain/usecases/quiz_management.dart';
import 'app_providers.dart';

// State classes
class QuizState {
  final Map<String, QuizResult> quizResults;
  final Map<String, PelajaranProgress> progressMap;
  final bool isLoading;
  final String? error;

  QuizState({
    this.quizResults = const {},
    this.progressMap = const {},
    this.isLoading = false,
    this.error,
  });

  QuizState copyWith({
    Map<String, QuizResult>? quizResults,
    Map<String, PelajaranProgress>? progressMap,
    bool? isLoading,
    String? error,
  }) {
    return QuizState(
      quizResults: quizResults ?? this.quizResults,
      progressMap: progressMap ?? this.progressMap,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Quiz Provider
class QuizNotifier extends StateNotifier<QuizState> {
  final SaveQuizResult saveQuizResult;
  final GetQuizResultsByPelajaran getQuizResultsByPelajaran;
  final GetQuizResult getQuizResult;
  final ResetPelajaranProgress resetPelajaranProgress;
  final GetPelajaranProgress getPelajaranProgress;

  QuizNotifier({
    required this.saveQuizResult,
    required this.getQuizResultsByPelajaran,
    required this.getQuizResult,
    required this.resetPelajaranProgress,
    required this.getPelajaranProgress,
  }) : super(QuizState());

  Future<void> loadPelajaranProgress(String idPelajaran) async {
    try {
      final progress = await getPelajaranProgress(idPelajaran);
      if (progress != null) {
        final updatedProgressMap = Map<String, PelajaranProgress>.from(state.progressMap);
        updatedProgressMap[idPelajaran] = progress;
        
        state = state.copyWith(progressMap: updatedProgressMap);
      }
    } catch (e) {
      AppLogger.error('Error loading progress for $idPelajaran: $e');
    }
  }

  Future<void> loadQuizResults(String idPelajaran) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final results = await getQuizResultsByPelajaran(idPelajaran);
      final updatedResults = Map<String, QuizResult>.from(state.quizResults);
      
      // Clear previous results for this pelajaran
      updatedResults.removeWhere((key, value) => value.idPelajaran == idPelajaran);
      
      // Add new results
      for (var result in results) {
        updatedResults[result.idKuis] = result;
      }
      
      state = state.copyWith(
        quizResults: updatedResults,
        isLoading: false,
      );
      
      // Also load progress
      await loadPelajaranProgress(idPelajaran);
      
    } catch (e) {
      AppLogger.error('Error loading quiz results: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load quiz results',
      );
    }
  }

  Future<void> answerQuiz({
    required String idPelajaran,
    required String idKuis,
    required String userAnswer,
    required String correctAnswer,
  }) async {
    try {
      final isCorrect = userAnswer.toLowerCase() == correctAnswer.toLowerCase();
      
      final result = QuizResult(
        id: '${idKuis}_${DateTime.now().millisecondsSinceEpoch}',
        idPelajaran: idPelajaran,
        idKuis: idKuis,
        userAnswer: userAnswer,
        isCorrect: isCorrect,
        answeredAt: DateTime.now(),
      );

      await saveQuizResult(result);
      
      // Update local state
      final updatedResults = Map<String, QuizResult>.from(state.quizResults);
      updatedResults[idKuis] = result;
      
      state = state.copyWith(quizResults: updatedResults);
      
      // Reload progress
      await loadPelajaranProgress(idPelajaran);
      
      AppLogger.info('Quiz answered: $idKuis, correct: $isCorrect');
      
    } catch (e) {
      AppLogger.error('Error saving quiz answer: $e');
      state = state.copyWith(error: 'Failed to save answer');
    }
  }

  Future<void> resetProgress(String idPelajaran) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await resetPelajaranProgress(idPelajaran);
      
      // Clear local state for this pelajaran
      final updatedResults = Map<String, QuizResult>.from(state.quizResults);
      updatedResults.removeWhere((key, value) => value.idPelajaran == idPelajaran);
      
      final updatedProgressMap = Map<String, PelajaranProgress>.from(state.progressMap);
      updatedProgressMap.remove(idPelajaran);
      
      state = state.copyWith(
        quizResults: updatedResults,
        progressMap: updatedProgressMap,
        isLoading: false,
      );
      
      // Reload progress
      await loadPelajaranProgress(idPelajaran);
      
      AppLogger.info('Progress reset for pelajaran: $idPelajaran');
      
    } catch (e) {
      AppLogger.error('Error resetting progress: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to reset progress',
      );
    }
  }

  QuizResult? getQuizResultById(String idKuis) {
    return state.quizResults[idKuis];
  }

  PelajaranProgress? getProgressForPelajaran(String idPelajaran) {
    return state.progressMap[idPelajaran];
  }

  bool isQuizAnswered(String idKuis) {
    return state.quizResults.containsKey(idKuis);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider instances
final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  final repository = ref.read(dataRepositoryProvider);
  
  return QuizNotifier(
    saveQuizResult: SaveQuizResult(repository),
    getQuizResultsByPelajaran: GetQuizResultsByPelajaran(repository),
    getQuizResult: GetQuizResult(repository),
    resetPelajaranProgress: ResetPelajaranProgress(repository),
    getPelajaranProgress: GetPelajaranProgress(repository),
  );
});
