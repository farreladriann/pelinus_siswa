// lib/presentation/pages/pelajaran_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pelajaran.dart';
import '../../domain/entities/quiz_result.dart';
import '../providers/pdf_provider.dart';
import '../providers/quiz_provider.dart';
import '../widgets/pelinus_app_bar.dart';
import 'pdf_viewer_page.dart';
import 'quiz_page.dart';

class PelajaranDetailPage extends ConsumerStatefulWidget {
  final Pelajaran pelajaran;
  final String kelasNomor;

  const PelajaranDetailPage({
    super.key,
    required this.pelajaran,
    required this.kelasNomor,
  });

  @override
  ConsumerState<PelajaranDetailPage> createState() => _PelajaranDetailPageState();
}

class _PelajaranDetailPageState extends ConsumerState<PelajaranDetailPage> {
  @override
  void initState() {
    super.initState();
    // Load quiz progress when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizProvider.notifier).loadPelajaranProgress(widget.pelajaran.idPelajaran);
      ref.read(quizProvider.notifier).loadQuizResults(widget.pelajaran.idPelajaran);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pdfState = ref.watch(pdfProvider);
    final quizState = ref.watch(quizProvider);
    final progress = quizState.progressMap[widget.pelajaran.idPelajaran];

    return Scaffold(
      appBar: PelinusAppBar(
        title: widget.pelajaran.namaPelajaran,
        showSyncButton: false, // Tidak ada sync button di halaman ini
      ),
      body: Column(
        children: [
          // Header info dan tombol PDF
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.pelajaran.namaPelajaran,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Kelas ${widget.kelasNomor}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${widget.pelajaran.kuis.length} kuis tersedia',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (progress != null) ...[
                            SizedBox(height: 4),
                            Text(
                              'Progress: ${progress.completedKuis}/${progress.totalKuis} kuis (${progress.score.toStringAsFixed(1)}%)',
                              style: TextStyle(
                                color: progress.isCompleted ? Colors.green : Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                
                // Tombol Lihat Materi PDF
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: pdfState.isLoading 
                        ? null 
                        : () => _openPdfViewer(),
                    icon: pdfState.isLoading 
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(Icons.picture_as_pdf),
                    label: Text(pdfState.isLoading 
                        ? 'Memuat PDF...' 
                        : 'Lihat Materi PDF'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(16),
                    ),
                  ),
                ),
                
                SizedBox(height: 12),
                
                // Tombol Mulai Kuis
                if (widget.pelajaran.kuis.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _startQuiz(),
                      icon: Icon(Icons.quiz),
                      label: Text(progress != null && progress.completedKuis > 0 
                          ? 'Lanjutkan Kuis' 
                          : 'Mulai Kuis'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.all(16),
                      ),
                    ),
                  ),
                
                SizedBox(height: 12),
                
                // Tombol Reset Progress (hanya tampil jika ada progress)
                if (progress != null && progress.completedKuis > 0)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: quizState.isLoading ? null : () => _showResetDialog(),
                      icon: Icon(Icons.refresh, color: Colors.red),
                      label: Text(
                        'Reset Semua Kuis',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red),
                        padding: EdgeInsets.all(16),
                      ),
                    ),
                  ),

                SizedBox(height: 12),

                // Tombol Lihat Detail Progress (jika ada progress)
                if (progress != null)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showProgressDetail(progress),
                      icon: Icon(Icons.analytics_outlined),
                      label: Text('Lihat Detail Progress'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.all(16),
                      ),
                    ),
                  ),

                if (pdfState.error != null) ...[
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            pdfState.error!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Divider untuk pemisah visual
          Divider(),

          // Spacer untuk mengisi ruang kosong
          Expanded(
            child: Container(),
          ),
        ],
      ),
    );
  }

  void _openPdfViewer() async {
    // Clear previous PDF state
    ref.read(pdfProvider.notifier).clearPdf();
    
    // Load PDF file
    await ref.read(pdfProvider.notifier).loadPdfFile(widget.pelajaran.idPelajaran);
    
    if (!mounted) return;
    
    final pdfState = ref.read(pdfProvider);
    
    if (pdfState.pdfFile != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PdfViewerPage(
            pdfFile: pdfState.pdfFile!,
            pelajaranName: widget.pelajaran.namaPelajaran,
          ),
        ),
      );
    }
    // Silent error handling - tidak menampilkan error SnackBar
  }

  void _showProgressDetail(PelajaranProgress progress) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.analytics_outlined, color: Theme.of(context).primaryColor),
            SizedBox(width: 8),
            Text('Detail Progress'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressItem('Total Kuis', '${progress.totalKuis} soal'),
            _buildProgressItem('Kuis Diselesaikan', '${progress.completedKuis}/${progress.totalKuis}'),
            _buildProgressItem('Jawaban Benar', '${progress.correctAnswers}/${progress.completedKuis}'),
            _buildProgressItem('Skor Akhir', '${progress.score.toStringAsFixed(1)}%'),
            _buildProgressItem('Status', progress.isCompleted ? 'Selesai' : 'Belum Selesai'),
            if (progress.lastAttemptAt != null)
              _buildProgressItem(
                'Terakhir Mengerjakan',
                _formatDateTime(progress.lastAttemptAt!),
              ),
            SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress.totalKuis > 0 ? progress.completedKuis / progress.totalKuis : 0,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress.isCompleted ? Colors.green : Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                '${((progress.completedKuis / progress.totalKuis) * 100).toStringAsFixed(1)}% selesai',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (progress.completedKuis > 0)
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _showResetDialog();
              },
              icon: Icon(Icons.refresh, color: Colors.red),
              label: Text('Reset', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startQuiz();
            },
            child: Text(progress.completedKuis > 0 ? 'Lanjutkan' : 'Mulai Kuis'),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  void _startQuiz() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizPage(
          pelajaran: widget.pelajaran,
          kelasNomor: widget.kelasNomor,
        ),
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Reset Progress'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apakah Anda yakin ingin mereset semua progress kuis untuk mata pelajaran ini?',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tindakan ini akan:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text('• Menghapus semua jawaban kuis'),
                  Text('• Mereset skor menjadi 0'),
                  Text('• Mereset progress menjadi 0'),
                  SizedBox(height: 8),
                  Text(
                    'Tindakan ini tidak dapat dibatalkan!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performReset();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _performReset() async {
    try {
      await ref.read(quizProvider.notifier).resetProgress(widget.pelajaran.idPelajaran);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Progress berhasil direset'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('Gagal mereset progress'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
