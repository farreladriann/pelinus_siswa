// lib/presentation/providers/kelas_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/kelas.dart';
import '../../domain/usecases/get_cached_data.dart';
import '../../domain/usecases/sync_data.dart';
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
      AppLogger.info('Loading cached data...');
      final kelasList = await getCachedData();
      AppLogger.info('Successfully loaded ${kelasList.length} kelas from cache');
      
      state = state.copyWith(
        kelasList: kelasList,
        isLoading: false,
      );
    } catch (e) {
      AppLogger.warning('Error loading cached data: $e');
      
      // Silent error - tidak menampilkan error di UI
      state = state.copyWith(
        isLoading: false,
        kelasList: [], // Keep empty list instead of showing error
      );
    }
  }

  Future<void> performSync() async {
    state = state.copyWith(isSyncing: true, error: null);
    
    try {
      AppLogger.info('Starting data synchronization...');
      await syncData();
      AppLogger.info('Sync completed, reloading data...');
      
      // Reload data after sync
      final kelasList = await getCachedData();
      AppLogger.info('Sync successful: ${kelasList.length} kelas loaded');
      
      state = state.copyWith(
        kelasList: kelasList,
        isSyncing: false,
      );
    } catch (e) {
      AppLogger.warning('Sync error: $e');
      
      // Silent error - reload cached data instead of showing error
      try {
        final kelasList = await getCachedData();
        AppLogger.info('Fallback to cached data: ${kelasList.length} kelas loaded');
        state = state.copyWith(
          kelasList: kelasList,
          isSyncing: false,
        );
      } catch (cacheError) {
        AppLogger.error('Cache error: $cacheError');
        state = state.copyWith(
          isSyncing: false,
          kelasList: [], // Keep empty list instead of showing error
        );
      }
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
