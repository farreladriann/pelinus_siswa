// lib/data/models/kuis_model.dart
import '../../domain/entities/kuis.dart';

class KuisModel extends Kuis {
  const KuisModel({
    required super.idKuis,
    required super.nomorKuis,
    required super.soal,
    required super.opsiA,
    required super.opsiB,
    required super.opsiC,
    required super.opsiD,
    required super.opsiJawaban,
  });

  factory KuisModel.fromJson(Map<String, dynamic> json) {
    try {
      // Enhanced validation with detailed logging
      print('🔍 Parsing KuisModel from JSON: ${json.keys.toList()}');
      
      // Validate required fields
      final requiredFields = ['idKuis', 'nomorKuis', 'soal', 'opsiA', 'opsiB', 'opsiC', 'opsiD', 'opsiJawaban'];
      final missingFields = requiredFields.where((field) => 
        json[field] == null || json[field].toString().trim().isEmpty
      ).toList();
      
      if (missingFields.isNotEmpty) {
        print('⚠️ Missing or empty fields in KuisModel: $missingFields');
        print('📄 JSON data: $json');
      }
      
      // Safe parsing with fallbacks
      final idKuis = json['idKuis']?.toString().trim() ?? 
                    json['id']?.toString().trim() ?? 
                    '';
      
      final nomorKuisRaw = json['nomorKuis'] ?? json['nomor'] ?? json['number'] ?? 0;
      final nomorKuis = (nomorKuisRaw is int) 
          ? nomorKuisRaw 
          : int.tryParse(nomorKuisRaw.toString()) ?? 0;
      
      final soal = json['soal']?.toString().trim() ?? 
                   json['question']?.toString().trim() ?? 
                   json['pertanyaan']?.toString().trim() ?? 
                   '';
      
      final opsiA = json['opsiA']?.toString().trim() ?? 
                    json['optionA']?.toString().trim() ?? 
                    json['pilihan_a']?.toString().trim() ?? 
                    '';
      
      final opsiB = json['opsiB']?.toString().trim() ?? 
                    json['optionB']?.toString().trim() ?? 
                    json['pilihan_b']?.toString().trim() ?? 
                    '';
      
      final opsiC = json['opsiC']?.toString().trim() ?? 
                    json['optionC']?.toString().trim() ?? 
                    json['pilihan_c']?.toString().trim() ?? 
                    '';
      
      final opsiD = json['opsiD']?.toString().trim() ?? 
                    json['optionD']?.toString().trim() ?? 
                    json['pilihan_d']?.toString().trim() ?? 
                    '';
      
      final opsiJawaban = json['opsiJawaban']?.toString().trim() ?? 
                          json['answer']?.toString().trim() ?? 
                          json['jawaban']?.toString().trim() ?? 
                          json['correct_answer']?.toString().trim() ?? 
                          '';
      
      // Validate critical data
      if (idKuis.isEmpty) {
        print('❌ Critical: idKuis is empty for quiz');
      }
      
      if (soal.isEmpty) {
        print('❌ Critical: soal (question) is empty for quiz $idKuis');
      }
      
      if (opsiJawaban.isEmpty) {
        print('⚠️ Warning: opsiJawaban (correct answer) is empty for quiz $idKuis');
      }
      
      final kuisModel = KuisModel(
        idKuis: idKuis,
        nomorKuis: nomorKuis,
        soal: soal,
        opsiA: opsiA,
        opsiB: opsiB,
        opsiC: opsiC,
        opsiD: opsiD,
        opsiJawaban: opsiJawaban,
      );
      
      print('✅ Successfully parsed KuisModel: $idKuis - ${soal.length > 50 ? soal.substring(0, 50) + '...' : soal}');
      return kuisModel;
      
    } catch (error, stackTrace) {
      print('🚨 Error parsing KuisModel: $error');
      print('📄 JSON data: $json');
      print('🔍 Stack trace: $stackTrace');
      
      // Return a valid but marked-as-invalid model
      return KuisModel(
        idKuis: json['idKuis']?.toString() ?? 'error_${DateTime.now().millisecondsSinceEpoch}',
        nomorKuis: 0,
        soal: 'Error: Unable to parse quiz data',
        opsiA: 'A. Data error',
        opsiB: 'B. Data error',
        opsiC: 'C. Data error',
        opsiD: 'D. Data error',
        opsiJawaban: 'A',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'idKuis': idKuis,
      'nomorKuis': nomorKuis,
      'soal': soal,
      'opsiA': opsiA,
      'opsiB': opsiB,
      'opsiC': opsiC,
      'opsiD': opsiD,
      'opsiJawaban': opsiJawaban,
    };
  }

  factory KuisModel.fromEntity(Kuis kuis) {
    return KuisModel(
      idKuis: kuis.idKuis,
      nomorKuis: kuis.nomorKuis,
      soal: kuis.soal,
      opsiA: kuis.opsiA,
      opsiB: kuis.opsiB,
      opsiC: kuis.opsiC,
      opsiD: kuis.opsiD,
      opsiJawaban: kuis.opsiJawaban,
    );
  }
}
