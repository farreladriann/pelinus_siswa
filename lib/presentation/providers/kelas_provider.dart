// lib/presentation/providers/kelas_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/kelas.dart';
import '../../domain/usecases/get_cached_data.dart';
import '../../domain/usecases/sync_data.dart';
import '../../core/error/exceptions.dart';
import 'app_providers.dart';

// State classes
class KelasState {
  final List<Kelas> kelasList;
  final bool isLoading;
  final String? error;
  final bool isSyncing;

  KelasState({
    this.kelasList = const [],
    this.isLoading = false,
    this.error,
    this.isSyncing = false,
  });

  KelasState copyWith({
    List<Kelas>? kelasList,
    bool? isLoading,
    String? error,
    bool? isSyncing,
  }) {
    return KelasState(
      kelasList: kelasList ?? this.kelasList,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }
}

// Kelas Provider
class KelasNotifier extends StateNotifier<KelasState> {
  final GetCachedData getCachedData;
  final SyncData syncData;

  KelasNotifier({
    required this.getCachedData,
    required this.syncData,
  }) : super(KelasState());

  Future<void> loadCachedData() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final kelasList = await getCachedData();
      state = state.copyWith(
        kelasList: kelasList,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> performSync() async {
    state = state.copyWith(isSyncing: true, error: null);
    
    try {
      await syncData();
      // Reload data after sync
      final kelasList = await getCachedData();
      state = state.copyWith(
        kelasList: kelasList,
        isSyncing: false,
      );
    } catch (e) {
      String errorMessage;
      if (e is NetworkException) {
        errorMessage = 'Tidak ada koneksi internet';
      } else if (e is ServerException) {
        errorMessage = 'Terjadi kesalahan pada server';
      } else {
        errorMessage = 'Sinkronisasi gagal: ${e.toString()}';
      }
      
      state = state.copyWith(
        isSyncing: false,
        error: errorMessage,
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider definition
final kelasProvider = StateNotifierProvider<KelasNotifier, KelasState>((ref) {
  return KelasNotifier(
    getCachedData: ref.read(getCachedDataProvider),
    syncData: ref.read(syncDataProvider),
  );
});
