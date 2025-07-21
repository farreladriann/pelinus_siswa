// lib/domain/usecases/get_cached_data.dart
import '../entities/kelas.dart';
import '../repositories/data_repository.dart';

class GetCachedData {
  final DataRepository repository;

  GetCachedData(this.repository);

  Future<List<Kelas>> call() async {
    return await repository.getCachedData();
  }
}
