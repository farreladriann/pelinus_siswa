// lib/data/datasources/local/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/kelas_model.dart';
import '../../models/pelajaran_model.dart';
import '../../models/kuis_model.dart';
import '../../models/pdf_file_model.dart';
import '../../../domain/entities/kelas.dart';
import '../../../domain/entities/pdf_file.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'pelinus_siswa.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
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
      await txn.delete('kuis');
      await txn.delete('pelajaran');
      await txn.delete('kelas');
    });
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
    final db = await database;
    await db.transaction((txn) async {
      // Hapus semua data lama
      await txn.delete('kuis');
      await txn.delete('pelajaran');
      await txn.delete('kelas');
      
      // Simpan data baru
      for (var kelas in kelasList) {
        final kelasModel = KelasModel.fromEntity(kelas);
        await txn.insert(
          'kelas',
          {
            'id': kelasModel.id,
            'nomorKelas': kelasModel.nomorKelas,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        
        for (var pelajaran in kelas.pelajaran) {
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
          
          for (var kuis in pelajaran.kuis) {
            final kuisModel = KuisModel.fromEntity(kuis);
            await txn.insert(
              'kuis',
              kuisModel.toJson(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
      }
    });
  }
}
