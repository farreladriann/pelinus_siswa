// lib/presentation/pages/quiz_statistics_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/kelas.dart';
import '../../domain/entities/quiz_result.dart';
import '../providers/quiz_provider.dart';
import '../widgets/pelinus_app_bar.dart';
import '../widgets/quiz_progress_indicator.dart';

class QuizStatisticsPage extends ConsumerStatefulWidget {
  final List<Kelas> kelasList;

  const QuizStatisticsPage({
    super.key,
    required this.kelasList,
  });

  @override
  ConsumerState<QuizStatisticsPage> createState() => _QuizStatisticsPageState();
}

class _QuizStatisticsPageState extends ConsumerState<QuizStatisticsPage> {
  @override
  void initState() {
    super.initState();
    // Load progress for all pelajaran
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var kelas in widget.kelasList) {
        for (var pelajaran in kelas.pelajaran) {
          ref.read(quizProvider.notifier).loadPelajaranProgress(pelajaran.idPelajaran);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizProvider);
    
    return Scaffold(
      appBar: PelinusAppBar(
        title: 'Statistik Kuis',
        showSyncButton: false,
      ),
      body: Column(
        children: [
          // Overall statistics card
          _buildOverallStatistics(quizState),
          
          // Per-class statistics
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8),
              itemCount: widget.kelasList.length,
              itemBuilder: (context, index) {
                final kelas = widget.kelasList[index];
                return _buildKelasStatistics(kelas, quizState);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallStatistics(QuizState quizState) {
    final allProgress = quizState.progressMap.values.toList();
    
    if (allProgress.isEmpty) {
      return Container(
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.analytics_outlined, color: Colors.grey),
            SizedBox(width: 12),
            Text(
              'Belum ada data statistik',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    final totalPelajaran = allProgress.length;
    final completedPelajaran = allProgress.where((p) => p.isCompleted).length;
    final totalKuis = allProgress.fold<int>(0, (sum, p) => sum + p.totalKuis);
    final completedKuis = allProgress.fold<int>(0, (sum, p) => sum + p.completedKuis);
    final totalCorrect = allProgress.fold<int>(0, (sum, p) => sum + p.correctAnswers);
    final averageScore = allProgress.isNotEmpty 
        ? allProgress.fold<double>(0, (sum, p) => sum + p.score) / allProgress.length
        : 0.0;

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.purple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Statistik Keseluruhan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Mata Pelajaran',
                  '$completedPelajaran/$totalPelajaran',
                  'Selesai',
                  Colors.green,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Total Kuis',
                  '$completedKuis/$totalKuis',
                  'Dikerjakan',
                  Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Jawaban Benar',
                  '$totalCorrect',
                  'dari $completedKuis',
                  Colors.blue,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Rata-rata Skor',
                  '${averageScore.toStringAsFixed(1)}%',
                  'Keseluruhan',
                  Colors.purple,
                ),
              ),
            ],
          ),
          
          if (totalKuis > 0) ...[
            SizedBox(height: 16),
            LinearProgressIndicator(
              value: completedKuis / totalKuis,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              minHeight: 6,
            ),
            SizedBox(height: 4),
            Text(
              '${((completedKuis / totalKuis) * 100).toStringAsFixed(1)}% progress keseluruhan',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, String subtitle, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKelasStatistics(Kelas kelas, QuizState quizState) {
    final kelasProgress = kelas.pelajaran
        .map((p) => quizState.progressMap[p.idPelajaran])
        .where((p) => p != null)
        .cast<PelajaranProgress>()
        .toList();

    if (kelasProgress.isEmpty) {
      return Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kelas ${kelas.nomorKelas}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Belum ada progress',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final completedCount = kelasProgress.where((p) => p.isCompleted).length;
    final averageScore = kelasProgress.isNotEmpty 
        ? kelasProgress.fold<double>(0, (sum, p) => sum + p.score) / kelasProgress.length
        : 0.0;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        title: Text(
          'Kelas ${kelas.nomorKelas}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '$completedCount/${kelas.pelajaran.length} mata pelajaran selesai • Rata-rata: ${averageScore.toStringAsFixed(1)}%',
        ),
        children: kelas.pelajaran.map((pelajaran) {
          final progress = quizState.progressMap[pelajaran.idPelajaran];
          if (progress == null) {
            return ListTile(
              title: Text(pelajaran.namaPelajaran),
              subtitle: Text('Belum ada progress'),
              trailing: Icon(Icons.hourglass_empty, color: Colors.grey),
            );
          }
          
          return QuizProgressCard(
            progress: progress,
            pelajaranName: pelajaran.namaPelajaran,
            onReset: () => _showResetDialog(pelajaran.idPelajaran, pelajaran.namaPelajaran),
          );
        }).toList(),
      ),
    );
  }

  void _showResetDialog(String idPelajaran, String namaPelajaran) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Progress'),
        content: Text(
          'Apakah Anda yakin ingin mereset progress untuk mata pelajaran $namaPelajaran?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performReset(idPelajaran, namaPelajaran);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _performReset(String idPelajaran, String namaPelajaran) async {
    try {
      await ref.read(quizProvider.notifier).resetProgress(idPelajaran);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Progress $namaPelajaran berhasil direset'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mereset progress $namaPelajaran'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
