// lib/data/datasources/local/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/kelas_model.dart';
import '../../models/pelajaran_model.dart';
import '../../models/kuis_model.dart';
import '../../models/pdf_file_model.dart';
import '../../models/quiz_result_model.dart';
import '../../../domain/entities/kelas.dart';
import '../../../domain/entities/pdf_file.dart';
import '../../../domain/entities/quiz_result.dart';
import '../../../core/utils/logger.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    
    try {
      _database = await _initDatabase();
      return _database!;
    } catch (e) {
      AppLogger.error('Database initialization failed', e);
      
      // If database fails to initialize, try to reset it
      if (e.toString().contains('table') && e.toString().contains('already exists')) {
        AppLogger.info('Attempting to reset corrupted database...');
        await resetDatabase();
        _database = await _initDatabase();
        return _database!;
      }
      
      rethrow;
    }
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'pelinus_siswa.db');
    return await openDatabase(
      path,
      version: 4, // Incremented version to fix migration issues
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabel Kelas
    await db.execute('''
      CREATE TABLE kelas (
        id TEXT PRIMARY KEY,
        nomorKelas TEXT NOT NULL
      )
    ''');

    // Tabel Pelajaran
    await db.execute('''
      CREATE TABLE pelajaran (
        idPelajaran TEXT PRIMARY KEY,
        namaPelajaran TEXT NOT NULL,
        kelasId TEXT NOT NULL,
        FOREIGN KEY (kelasId) REFERENCES kelas (id)
      )
    ''');

    // Tabel Kuis
    await db.execute('''
      CREATE TABLE kuis (
        idKuis TEXT PRIMARY KEY,
        nomorKuis INTEGER NOT NULL,
        soal TEXT NOT NULL,
        opsiA TEXT NOT NULL,
        opsiB TEXT NOT NULL,
        opsiC TEXT NOT NULL,
        opsiD TEXT NOT NULL,
        opsiJawaban TEXT NOT NULL,
        idPelajaran TEXT NOT NULL,
        FOREIGN KEY (idPelajaran) REFERENCES pelajaran (idPelajaran)
      )
    ''');

    // Tabel PDF Files
    await db.execute('''
      CREATE TABLE pdf_files (
        idPelajaran TEXT PRIMARY KEY,
        fileName TEXT NOT NULL,
        filePath TEXT NOT NULL,
        downloadedAt TEXT NOT NULL
      )
    ''');

    // Tabel Quiz Results
    await db.execute('''
      CREATE TABLE quiz_results (
        id TEXT PRIMARY KEY,
        idPelajaran TEXT NOT NULL,
        idKuis TEXT NOT NULL,
        userAnswer TEXT NOT NULL,
        isCorrect INTEGER NOT NULL,
        answeredAt TEXT NOT NULL,
        FOREIGN KEY (idPelajaran) REFERENCES pelajaran (idPelajaran),
        FOREIGN KEY (idKuis) REFERENCES kuis (idKuis)
      )
    ''');

    // Tabel Pelajaran Progress
    await db.execute('''
      CREATE TABLE pelajaran_progress (
        idPelajaran TEXT PRIMARY KEY,
        totalKuis INTEGER NOT NULL,
        completedKuis INTEGER NOT NULL,
        correctAnswers INTEGER NOT NULL,
        score REAL NOT NULL,
        lastAttemptAt TEXT,
        isCompleted INTEGER NOT NULL,
        FOREIGN KEY (idPelajaran) REFERENCES pelajaran (idPelajaran)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    AppLogger.database('UPGRADE', 'Database upgrade: $oldVersion -> $newVersion');
    
    if (oldVersion < 2) {
      // Add new tables for quiz results and progress (use IF NOT EXISTS to avoid conflicts)
      AppLogger.database('UPGRADE', 'Adding quiz_results table...');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS quiz_results (
          id TEXT PRIMARY KEY,
          idPelajaran TEXT NOT NULL,
          idKuis TEXT NOT NULL,
          userAnswer TEXT NOT NULL,
          isCorrect INTEGER NOT NULL,
          answeredAt TEXT NOT NULL,
          FOREIGN KEY (idPelajaran) REFERENCES pelajaran (idPelajaran),
          FOREIGN KEY (idKuis) REFERENCES kuis (idKuis)
        )
      ''');

      AppLogger.database('UPGRADE', 'Adding pelajaran_progress table...');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS pelajaran_progress (
          idPelajaran TEXT PRIMARY KEY,
          totalKuis INTEGER NOT NULL,
          completedKuis INTEGER NOT NULL,
          correctAnswers INTEGER NOT NULL,
          score REAL NOT NULL,
          lastAttemptAt TEXT,
          isCompleted INTEGER NOT NULL,
          FOREIGN KEY (idPelajaran) REFERENCES pelajaran (idPelajaran)
        )
      ''');
    }
    
    if (oldVersion < 3) {
      // Version 3 fixes - ensure tables exist with IF NOT EXISTS
      AppLogger.database('UPGRADE', 'Ensuring quiz tables exist for version 3...');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS quiz_results (
          id TEXT PRIMARY KEY,
          idPelajaran TEXT NOT NULL,
          idKuis TEXT NOT NULL,
          userAnswer TEXT NOT NULL,
          isCorrect INTEGER NOT NULL,
          answeredAt TEXT NOT NULL,
          FOREIGN KEY (idPelajaran) REFERENCES pelajaran (idPelajaran),
          FOREIGN KEY (idKuis) REFERENCES kuis (idKuis)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS pelajaran_progress (
          idPelajaran TEXT PRIMARY KEY,
          totalKuis INTEGER NOT NULL,
          completedKuis INTEGER NOT NULL,
          correctAnswers INTEGER NOT NULL,
          score REAL NOT NULL,
          lastAttemptAt TEXT,
          isCompleted INTEGER NOT NULL,
          FOREIGN KEY (idPelajaran) REFERENCES pelajaran (idPelajaran)
        )
      ''');
    }
    
    if (oldVersion < 4) {
      // Version 4 - Clean up orphaned quiz results after sync
      AppLogger.database('UPGRADE', 'Adding cleanup for orphaned quiz results...');
      
      // This will be implemented in the saveAllData method
      // No schema changes needed, just logic improvements
    }
    
    AppLogger.database('UPGRADE', 'Database upgrade completed');
  }

  // Metode untuk Kelas
  Future<void> insertKelas(KelasModel kelas) async {
    final db = await database;
    await db.insert(
      'kelas',
      {
        'id': kelas.id,
        'nomorKelas': kelas.nomorKelas,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertPelajaran(PelajaranModel pelajaran, String kelasId) async {
    final db = await database;
    await db.insert(
      'pelajaran',
      {
        'idPelajaran': pelajaran.idPelajaran,
        'namaPelajaran': pelajaran.namaPelajaran,
        'kelasId': kelasId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertKuis(KuisModel kuis) async {
    final db = await database;
    await db.insert(
      'kuis',
      kuis.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertPdfFile(PdfFileModel pdfFile) async {
    final db = await database;
    await db.insert(
      'pdf_files',
      pdfFile.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Kelas>> getAllKelas() async {
    final db = await database;
    
    // Ambil semua kelas
    final kelasResults = await db.query('kelas');
    
    List<Kelas> kelasList = [];
    
    for (var kelasMap in kelasResults) {
      // Ambil pelajaran untuk kelas ini
      final pelajaranResults = await db.query(
        'pelajaran',
        where: 'kelasId = ?',
        whereArgs: [kelasMap['id']],
      );
      
      List<PelajaranModel> pelajaranList = [];
      
      for (var pelajaranMap in pelajaranResults) {
        // Ambil kuis untuk pelajaran ini
        final kuisResults = await db.query(
          'kuis',
          where: 'idPelajaran = ?',
          whereArgs: [pelajaranMap['idPelajaran']],
        );
        
        List<KuisModel> kuisList = kuisResults
            .map((kuisMap) => KuisModel.fromJson(kuisMap))
            .toList();
        
        pelajaranList.add(PelajaranModel(
          idPelajaran: pelajaranMap['idPelajaran'] as String,
          namaPelajaran: pelajaranMap['namaPelajaran'] as String,
          kuis: kuisList,
        ));
      }
      
      kelasList.add(KelasModel(
        id: kelasMap['id'] as String,
        nomorKelas: kelasMap['nomorKelas'] as String,
        pelajaran: pelajaranList,
      ));
    }
    
    return kelasList;
  }

  Future<PdfFile?> getPdfFile(String idPelajaran) async {
    final db = await database;
    final results = await db.query(
      'pdf_files',
      where: 'idPelajaran = ?',
      whereArgs: [idPelajaran],
    );
    
    if (results.isNotEmpty) {
      return PdfFileModel.fromJson(results.first);
    }
    return null;
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      // Clear all tables in correct order (respecting foreign keys)
      await txn.delete('quiz_results');
      await txn.delete('pelajaran_progress');
      await txn.delete('kuis');
      await txn.delete('pelajaran');
      await txn.delete('kelas');
      await txn.delete('pdf_files');
    });
    AppLogger.database('CLEAR', 'All data cleared from database');
  }

  // Method to completely reset database (for troubleshooting)
  Future<void> resetDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'pelinus_siswa.db');
      
      // Close current database connection
      if (_database != null) {
        await _database!.close();
        _database = null;
      }
      
      // Delete the database file
      await deleteDatabase(path);
      AppLogger.database('RESET', 'Database file deleted and will be recreated');
      
      // The database will be recreated on next access
    } catch (e) {
      AppLogger.error('Error resetting database', e);
      rethrow;
    }
  }

  Future<void> deletePdfFile(String idPelajaran) async {
    final db = await database;
    await db.delete(
      'pdf_files',
      where: 'idPelajaran = ?',
      whereArgs: [idPelajaran],
    );
  }

  Future<List<String>> getAllPelajaranIds() async {
    final db = await database;
    final results = await db.query('pelajaran', columns: ['idPelajaran']);
    return results.map((row) => row['idPelajaran'] as String).toList();
  }

  Future<void> saveAllData(List<Kelas> kelasList) async {
    try {
      AppLogger.sync('Starting saveAllData with ${kelasList.length} kelas');
      final db = await database;
      
      await db.transaction((txn) async {
        AppLogger.database('TRANSACTION', 'Transaction started - clearing old data');
        
        // Hapus semua data lama dengan error handling (except quiz results and progress)
        try {
          await txn.delete('kuis');
          await txn.delete('pelajaran');
          await txn.delete('kelas');
          AppLogger.database('CLEAR', 'Successfully cleared old data');
        } catch (clearError) {
          AppLogger.error('Error clearing old data', clearError);
          throw Exception('Failed to clear old data: $clearError');
        }
        
        int kelasCount = 0, pelajaranCount = 0, kuisCount = 0;
        int kelasErrors = 0, pelajaranErrors = 0, kuisErrors = 0;
        
        // Simpan data baru
        for (var kelas in kelasList) {
          try {
            AppLogger.database('KELAS', 'Processing kelas: ${kelas.id} - ${kelas.nomorKelas}');
            final kelasModel = KelasModel.fromEntity(kelas);
            
            await txn.insert(
              'kelas',
              {
                'id': kelasModel.id,
                'nomorKelas': kelasModel.nomorKelas,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            kelasCount++;
            
            for (var pelajaran in kelas.pelajaran) {
              try {
                AppLogger.database('PELAJARAN', 'Processing pelajaran: ${pelajaran.idPelajaran} - ${pelajaran.namaPelajaran}');
                final pelajaranModel = PelajaranModel.fromEntity(pelajaran);
                
                await txn.insert(
                  'pelajaran',
                  {
                    'idPelajaran': pelajaranModel.idPelajaran,
                    'namaPelajaran': pelajaranModel.namaPelajaran,
                    'kelasId': kelas.id,
                  },
                  conflictAlgorithm: ConflictAlgorithm.replace,
                );
                pelajaranCount++;
                
                for (var kuis in pelajaran.kuis) {
                  try {
                    if (kuis.idKuis.isEmpty || kuis.soal.isEmpty) {
                      AppLogger.warning('Skipping invalid kuis: id=${kuis.idKuis}, soal=${kuis.soal.length} chars');
                      kuisErrors++;
                      continue;
                    }
                    
                    final kuisModel = KuisModel.fromEntity(kuis);
                    final kuisData = kuisModel.toJson();
                    kuisData['idPelajaran'] = pelajaran.idPelajaran; // Use correct column name
                    
                    await txn.insert(
                      'kuis',
                      kuisData,
                      conflictAlgorithm: ConflictAlgorithm.replace,
                    );
                    kuisCount++;
                    
                  } catch (kuisError) {
                    kuisErrors++;
                    AppLogger.error('Error saving kuis ${kuis.idKuis}', kuisError);
                    AppLogger.debug('Kuis data: soal=${kuis.soal.length} chars, opsiA=${kuis.opsiA.length} chars');
                    // Continue dengan kuis lainnya
                  }
                }
                
                AppLogger.database('KUIS', 'Processed ${pelajaran.kuis.length} kuis for ${pelajaran.namaPelajaran}');
                
                // Update or create progress for this pelajaran
                await _updatePelajaranProgress(txn, pelajaran.idPelajaran, pelajaran.kuis.length);
                
              } catch (pelajaranError) {
                pelajaranErrors++;
                AppLogger.error('Error saving pelajaran ${pelajaran.idPelajaran}', pelajaranError);
                AppLogger.debug('Pelajaran data: nama=${pelajaran.namaPelajaran}, kuis count=${pelajaran.kuis.length}');
                // Continue dengan pelajaran lainnya
              }
            }
            
            AppLogger.database('KELAS', 'Processed ${kelas.pelajaran.length} pelajaran for kelas ${kelas.nomorKelas}');
            
          } catch (kelasError) {
            kelasErrors++;
            AppLogger.error('Error saving kelas ${kelas.id}', kelasError);
            AppLogger.debug('Kelas data: nomorKelas=${kelas.nomorKelas}, pelajaran count=${kelas.pelajaran.length}');
            // Continue dengan kelas lainnya
          }
        }
        
        AppLogger.database('TRANSACTION', 'Transaction completed:');
        AppLogger.database('STATS', 'Kelas saved: $kelasCount (errors: $kelasErrors)');
        AppLogger.database('STATS', 'Pelajaran saved: $pelajaranCount (errors: $pelajaranErrors)');
        AppLogger.database('STATS', 'Kuis saved: $kuisCount (errors: $kuisErrors)');
        
        if (kelasErrors > 0 || pelajaranErrors > 0 || kuisErrors > 0) {
          AppLogger.warning('Some data had errors but transaction completed');
        }
        
      });
      
      AppLogger.sync('Successfully completed saveAllData operation');
      
      // Clean up orphaned quiz results after data sync
      await _cleanupOrphanedQuizResults();
      
    } catch (error, stackTrace) {
      AppLogger.error('Critical error in saveAllData', error, stackTrace);
      throw Exception('Failed to save data to database: $error');
    }
  }

  Future<void> _updatePelajaranProgress(Transaction txn, String idPelajaran, int totalKuis) async {
    try {
      // Check if progress already exists
      final existing = await txn.query(
        'pelajaran_progress',
        where: 'idPelajaran = ?',
        whereArgs: [idPelajaran],
      );

      if (existing.isNotEmpty) {
        // Update existing progress with new total kuis count
        await txn.update(
          'pelajaran_progress',
          {'totalKuis': totalKuis},
          where: 'idPelajaran = ?',
          whereArgs: [idPelajaran],
        );
      } else {
        // Create new progress record
        await txn.insert(
          'pelajaran_progress',
          {
            'idPelajaran': idPelajaran,
            'totalKuis': totalKuis,
            'completedKuis': 0,
            'correctAnswers': 0,
            'score': 0.0,
            'lastAttemptAt': null,
            'isCompleted': 0,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (e) {
      AppLogger.error('Error updating progress for $idPelajaran', e);
    }
  }

  // Method to clean up orphaned quiz results after sync
  Future<void> _cleanupOrphanedQuizResults() async {
    try {
      AppLogger.database('CLEANUP', 'Cleaning up orphaned quiz results...');
      final db = await database;
      
      await db.transaction((txn) async {
        // Delete quiz results where the kuis no longer exists
        final deletedResults = await txn.rawDelete('''
          DELETE FROM quiz_results 
          WHERE idKuis NOT IN (SELECT idKuis FROM kuis)
        ''');
        
        // Delete progress for pelajaran that no longer exist
        final deletedProgress = await txn.rawDelete('''
          DELETE FROM pelajaran_progress 
          WHERE idPelajaran NOT IN (SELECT idPelajaran FROM pelajaran)
        ''');
        
        AppLogger.database('CLEANUP', 'Cleaned up $deletedResults orphaned quiz results');
        AppLogger.database('CLEANUP', 'Cleaned up $deletedProgress orphaned progress records');
        
        // Recalculate progress for all remaining pelajaran
        final allPelajaran = await txn.query('pelajaran', columns: ['idPelajaran']);
        for (var row in allPelajaran) {
          final idPelajaran = row['idPelajaran'] as String;
          await _recalculateProgressInTransaction(txn, idPelajaran);
        }
        
        AppLogger.database('CLEANUP', 'Orphaned data cleanup completed');
      });
      
    } catch (e) {
      AppLogger.error('Error during orphaned data cleanup', e);
      // Don't rethrow to avoid breaking the sync process
    }
  }

  // Helper method to recalculate progress within a transaction
  Future<void> _recalculateProgressInTransaction(Transaction txn, String idPelajaran) async {
    try {
      // Get total kuis count
      final totalKuisResult = await txn.rawQuery(
        'SELECT COUNT(*) as count FROM kuis WHERE idPelajaran = ?',
        [idPelajaran],
      );
      final totalKuis = totalKuisResult.first['count'] as int;

      // Get quiz results for this pelajaran
      final results = await txn.query(
        'quiz_results',
        where: 'idPelajaran = ?',
        whereArgs: [idPelajaran],
      );

      // Calculate statistics
      final completedKuis = results.length;
      final correctAnswers = results.where((r) => r['isCorrect'] == 1).length;
      final score = totalKuis > 0 ? (correctAnswers / totalKuis) * 100 : 0.0;
      final isCompleted = completedKuis >= totalKuis;
      final lastAttemptAt = results.isNotEmpty 
          ? results.map((r) => DateTime.parse(r['answeredAt'] as String))
              .reduce((a, b) => a.isAfter(b) ? a : b)
          : null;

      // Update progress
      await txn.insert(
        'pelajaran_progress',
        {
          'idPelajaran': idPelajaran,
          'totalKuis': totalKuis,
          'completedKuis': completedKuis,
          'correctAnswers': correctAnswers,
          'score': score,
          'lastAttemptAt': lastAttemptAt?.toIso8601String(),
          'isCompleted': isCompleted ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
    } catch (e) {
      AppLogger.error('Error recalculating progress for $idPelajaran', e);
      // Continue with other pelajaran
    }
  }

  // Quiz Results methods
  Future<void> saveQuizResult(QuizResult result) async {
    try {
      final db = await database;
      final resultModel = QuizResultModel.fromEntity(result);
      
      await db.insert(
        'quiz_results',
        resultModel.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Update progress after saving result
      await _recalculateProgress(result.idPelajaran);
      AppLogger.database('QUIZ', 'Quiz result saved: ${result.idKuis}');
      
    } catch (e) {
      AppLogger.error('Error saving quiz result', e);
      rethrow;
    }
  }

  Future<List<QuizResult>> getQuizResultsByPelajaran(String idPelajaran) async {
    try {
      final db = await database;
      final results = await db.query(
        'quiz_results',
        where: 'idPelajaran = ?',
        whereArgs: [idPelajaran],
        orderBy: 'answeredAt DESC',
      );

      return results.map((json) => QuizResultModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error getting quiz results for $idPelajaran', e);
      return []; // Return empty list instead of crashing
    }
  }

  Future<QuizResult?> getQuizResult(String idKuis) async {
    try {
      final db = await database;
      final results = await db.query(
        'quiz_results',
        where: 'idKuis = ?',
        whereArgs: [idKuis],
        limit: 1,
      );

      if (results.isNotEmpty) {
        return QuizResultModel.fromJson(results.first);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting quiz result for $idKuis', e);
      return null;
    }
  }

  Future<void> resetPelajaranProgress(String idPelajaran) async {
    final db = await database;
    
    await db.transaction((txn) async {
      // Delete all quiz results for this pelajaran
      await txn.delete(
        'quiz_results',
        where: 'idPelajaran = ?',
        whereArgs: [idPelajaran],
      );

      // Reset progress
      await txn.update(
        'pelajaran_progress',
        {
          'completedKuis': 0,
          'correctAnswers': 0,
          'score': 0.0,
          'lastAttemptAt': null,
          'isCompleted': 0,
        },
        where: 'idPelajaran = ?',
        whereArgs: [idPelajaran],
      );
    });

    AppLogger.database('RESET', 'Progress reset for pelajaran: $idPelajaran');
  }

  Future<PelajaranProgress?> getPelajaranProgress(String idPelajaran) async {
    try {
      final db = await database;
      final results = await db.query(
        'pelajaran_progress',
        where: 'idPelajaran = ?',
        whereArgs: [idPelajaran],
        limit: 1,
      );

      if (results.isNotEmpty) {
        return PelajaranProgressModel.fromJson(results.first);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting pelajaran progress for $idPelajaran', e);
      return null;
    }
  }

  Future<void> _recalculateProgress(String idPelajaran) async {
    try {
      final db = await database;
      
      // Get total kuis count
      final totalKuisResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM kuis WHERE idPelajaran = ?',
        [idPelajaran],
      );
      final totalKuis = totalKuisResult.first['count'] as int;

      // Get quiz results for this pelajaran
      final results = await db.query(
        'quiz_results',
        where: 'idPelajaran = ?',
        whereArgs: [idPelajaran],
      );

      // Calculate statistics
      final completedKuis = results.length;
      final correctAnswers = results.where((r) => r['isCorrect'] == 1).length;
      final score = totalKuis > 0 ? (correctAnswers / totalKuis) * 100 : 0.0;
      final isCompleted = completedKuis >= totalKuis;
      final lastAttemptAt = results.isNotEmpty 
          ? results.map((r) => DateTime.parse(r['answeredAt'] as String))
              .reduce((a, b) => a.isAfter(b) ? a : b)
          : null;

      // Update progress
      await db.insert(
        'pelajaran_progress',
        {
          'idPelajaran': idPelajaran,
          'totalKuis': totalKuis,
          'completedKuis': completedKuis,
          'correctAnswers': correctAnswers,
          'score': score,
          'lastAttemptAt': lastAttemptAt?.toIso8601String(),
          'isCompleted': isCompleted ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      AppLogger.database('PROGRESS', 'Recalculated for $idPelajaran: $completedKuis/$totalKuis (${score.toStringAsFixed(1)}%)');
      
    } catch (e) {
      AppLogger.error('Error recalculating progress for $idPelajaran', e);
      // Don't rethrow to avoid breaking the quiz save operation
    }
  }
}
