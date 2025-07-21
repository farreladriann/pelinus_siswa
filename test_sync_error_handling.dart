// Test script to verify enhanced error handling
import 'lib/data/models/kuis_model.dart';

void main() {
  print('🧪 Testing Enhanced Error Handling for Pelinus Mengajar');
  print('=' * 60);
  
  // Test 1: Valid KuisModel parsing
  testValidKuisModel();
  
  // Test 2: Invalid KuisModel parsing
  testInvalidKuisModel();
  
  // Test 3: KuisModel with missing fields
  testKuisModelMissingFields();
  
  // Test 4: KuisModel with alternative field names
  testKuisModelAlternativeFields();
  
  print('🎉 All tests completed!');
}

void testValidKuisModel() {
  print('\n🧪 Test 1: Valid KuisModel parsing');
  try {
    final validJson = {
      'idKuis': 'quiz_001',
      'nomorKuis': 1,
      'soal': 'What is the capital of Indonesia?',
      'opsiA': 'Jakarta',
      'opsiB': 'Bandung',
      'opsiC': 'Surabaya',
      'opsiD': 'Medan',
      'opsiJawaban': 'A'
    };
    
    final kuis = KuisModel.fromJson(validJson);
    print('✅ Successfully parsed valid kuis: ${kuis.idKuis}');
    print('   Question: ${kuis.soal}');
    print('   Answer: ${kuis.opsiJawaban}');
  } catch (e) {
    print('❌ Unexpected error: $e');
  }
}

void testInvalidKuisModel() {
  print('\n🧪 Test 2: Invalid KuisModel parsing');
  try {
    final invalidJson = {
      'invalidField': 'invalid value',
      'anotherField': 123
    };
    
    final kuis = KuisModel.fromJson(invalidJson);
    print('✅ Gracefully handled invalid data:');
    print('   ID: ${kuis.idKuis}');
    print('   Question: ${kuis.soal}');
    print('   Shows error message: ${kuis.soal.contains('Error')}');
  } catch (e) {
    print('❌ Should not throw exception: $e');
  }
}

void testKuisModelMissingFields() {
  print('\n🧪 Test 3: KuisModel with missing fields');
  try {
    final partialJson = {
      'idKuis': 'quiz_002',
      'soal': 'Incomplete question',
      // Missing other required fields
    };
    
    final kuis = KuisModel.fromJson(partialJson);
    print('✅ Handled missing fields:');
    print('   ID: ${kuis.idKuis}');
    print('   Question: ${kuis.soal}');
    print('   Options: A=${kuis.opsiA}, B=${kuis.opsiB}');
  } catch (e) {
    print('❌ Should handle missing fields gracefully: $e');
  }
}

void testKuisModelAlternativeFields() {
  print('\n🧪 Test 4: KuisModel with alternative field names');
  try {
    final altJson = {
      'id': 'quiz_003',
      'nomor': '2',
      'question': 'Alternative field test?',
      'optionA': 'Yes',
      'optionB': 'No',
      'pilihan_c': 'Maybe',
      'pilihan_d': 'Unknown',
      'correct_answer': 'A'
    };
    
    final kuis = KuisModel.fromJson(altJson);
    print('✅ Handled alternative field names:');
    print('   ID: ${kuis.idKuis}');
    print('   Number: ${kuis.nomorKuis}');
    print('   Question: ${kuis.soal}');
    print('   Answer: ${kuis.opsiJawaban}');
  } catch (e) {
    print('❌ Should handle alternative fields: $e');
  }
}
