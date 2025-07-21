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
      print('🔄 Loading cached data...');
      final kelasList = await getCachedData();
      print('✅ Successfully loaded ${kelasList.length} kelas from cache');
      
      state = state.copyWith(
        kelasList: kelasList,
        isLoading: false,
      );
    } catch (e) {
      print('❌ Error loading cached data: $e');
      
      String userFriendlyError;
      if (e is ServerException) {
        userFriendlyError = 'Gagal memuat data: ${e.message}';
      } else if (e is NetworkException) {
        userFriendlyError = 'Tidak ada koneksi internet. Periksa jaringan Anda.';
      } else if (e.toString().contains('database')) {
        userFriendlyError = 'Terjadi kesalahan pada penyimpanan data lokal';
      } else {
        userFriendlyError = 'Gagal memuat data: ${e.toString()}';
      }
      
      state = state.copyWith(
        isLoading: false,
        error: userFriendlyError,
      );
    }
  }

  Future<void> performSync() async {
    state = state.copyWith(isSyncing: true, error: null);
    
    try {
      print('🔄 Starting data synchronization...');
      await syncData();
      print('🔄 Sync completed, reloading data...');
      
      // Reload data after sync
      final kelasList = await getCachedData();
      print('✅ Sync successful: ${kelasList.length} kelas loaded');
      
      state = state.copyWith(
        kelasList: kelasList,
        isSyncing: false,
      );
    } catch (e) {
      print('❌ Sync error: $e');
      
      String errorMessage;
      if (e is NetworkException) {
        errorMessage = 'Tidak ada koneksi internet. Pastikan Anda terhubung ke jaringan.';
      } else if (e is ServerException) {
        final serverError = e.message;
        if (serverError.contains('timeout')) {
          errorMessage = 'Koneksi ke server terputus. Coba lagi dalam beberapa saat.';
        } else if (serverError.contains('parse') || serverError.contains('format')) {
          errorMessage = 'Data dari server tidak valid. Silakan laporkan masalah ini.';
        } else if (serverError.contains('HTTP 5')) {
          errorMessage = 'Server sedang bermasalah. Coba lagi nanti.';
        } else if (serverError.contains('HTTP 4')) {
          errorMessage = 'Permintaan tidak valid. Periksa versi aplikasi Anda.';
        } else {
          errorMessage = 'Terjadi kesalahan pada server: $serverError';
        }
      } else if (e.toString().contains('database') || e.toString().contains('save')) {
        errorMessage = 'Gagal menyimpan data ke penyimpanan lokal. Pastikan ada ruang penyimpanan yang cukup.';
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
