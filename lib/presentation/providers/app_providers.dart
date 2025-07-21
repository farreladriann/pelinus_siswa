// lib/presentation/providers/app_providers.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/network/network_info.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../data/datasources/remote/api_service.dart';
import '../../data/repositories/data_repository_impl.dart';
import '../../domain/repositories/data_repository.dart';
import '../../domain/usecases/get_cached_data.dart';
import '../../domain/usecases/sync_data.dart';
import '../../domain/usecases/get_pdf_file.dart';

// Network providers
final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

final networkInfoProvider = Provider<NetworkInfo>(
  (ref) => NetworkInfoImpl(ref.read(connectivityProvider)),
);

// Data source providers
final dioProvider = Provider<Dio>((ref) => Dio());

final apiServiceProvider = Provider<ApiService>(
  (ref) => ApiService(ref.read(dioProvider)),
);

final databaseHelperProvider = Provider<DatabaseHelper>(
  (ref) => DatabaseHelper(),
);

// Repository provider
final dataRepositoryProvider = Provider<DataRepository>((ref) {
  return DataRepositoryImpl(
    apiService: ref.read(apiServiceProvider),
    databaseHelper: ref.read(databaseHelperProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

// Use case providers
final getCachedDataProvider = Provider<GetCachedData>(
  (ref) => GetCachedData(ref.read(dataRepositoryProvider)),
);

final syncDataProvider = Provider<SyncData>(
  (ref) => SyncData(ref.read(dataRepositoryProvider)),
);

final getPdfFileProvider = Provider<GetPdfFile>(
  (ref) => GetPdfFile(ref.read(dataRepositoryProvider)),
);
