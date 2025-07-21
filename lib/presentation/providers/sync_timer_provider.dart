// lib/presentation/providers/sync_timer_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import 'kelas_provider.dart';

// Sync Timer State
class SyncTimerState {
  final Timer? timer;
  final DateTime? lastSync;
  final bool isAutoSyncEnabled;

  SyncTimerState({
    this.timer,
    this.lastSync,
    this.isAutoSyncEnabled = true,
  });

  SyncTimerState copyWith({
    Timer? timer,
    DateTime? lastSync,
    bool? isAutoSyncEnabled,
  }) {
    return SyncTimerState(
      timer: timer ?? this.timer,
      lastSync: lastSync ?? this.lastSync,
      isAutoSyncEnabled: isAutoSyncEnabled ?? this.isAutoSyncEnabled,
    );
  }
}

// Sync Timer Notifier
class SyncTimerNotifier extends StateNotifier<SyncTimerState> {
  final KelasNotifier kelasNotifier;

  SyncTimerNotifier({
    required this.kelasNotifier,
  }) : super(SyncTimerState());

  void startAutoSync() {
    if (state.timer != null) {
      state.timer!.cancel();
    }

    final timer = Timer.periodic(
      Duration(minutes: ApiConstants.syncIntervalMinutes),
      (timer) async {
        if (state.isAutoSyncEnabled) {
          await kelasNotifier.performSync();
          state = state.copyWith(lastSync: DateTime.now());
        }
      },
    );

    state = state.copyWith(timer: timer);
  }

  void stopAutoSync() {
    if (state.timer != null) {
      state.timer!.cancel();
      state = state.copyWith(timer: null);
    }
  }

  void setAutoSyncEnabled(bool enabled) {
    state = state.copyWith(isAutoSyncEnabled: enabled);
    
    if (enabled && state.timer == null) {
      startAutoSync();
    } else if (!enabled && state.timer != null) {
      stopAutoSync();
    }
  }

  void performInitialSync() async {
    await kelasNotifier.performSync();
    state = state.copyWith(lastSync: DateTime.now());
  }

  @override
  void dispose() {
    if (state.timer != null) {
      state.timer!.cancel();
    }
    super.dispose();
  }
}

// Provider definition
final syncTimerProvider = StateNotifierProvider<SyncTimerNotifier, SyncTimerState>((ref) {
  final kelasNotifier = ref.read(kelasProvider.notifier);
  return SyncTimerNotifier(kelasNotifier: kelasNotifier);
});
