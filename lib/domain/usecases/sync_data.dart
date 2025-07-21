// lib/domain/usecases/sync_data.dart
import '../repositories/data_repository.dart';

class SyncData {
  final DataRepository repository;

  SyncData(this.repository);

  Future<void> call() async {
    await repository.syncData();
  }
}
