// lib/presentation/pages/pelajaran_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/kelas.dart';
import '../providers/quiz_provider.dart';
import '../widgets/pelinus_app_bar.dart';
import 'pelajaran_detail_page.dart';

class PelajaranListPage extends ConsumerStatefulWidget {
  final Kelas kelas;

  const PelajaranListPage({
    super.key,
    required this.kelas,
  });

  @override
  ConsumerState<PelajaranListPage> createState() => _PelajaranListPageState();
}

class _PelajaranListPageState extends ConsumerState<PelajaranListPage> {
  @override
  void initState() {
    super.initState();
    // Load progress for all pelajaran when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var pelajaran in widget.kelas.pelajaran) {
        ref.read(quizProvider.notifier).loadPelajaranProgress(pelajaran.idPelajaran);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizProvider);
    
    return Scaffold(
      appBar: PelinusAppBar(
        title: 'Kelas ${widget.kelas.nomorKelas}',
        showSyncButton: false, // Tidak ada sync button di halaman ini
      ),
      body: widget.kelas.pelajaran.isEmpty
          ? _buildEmptyState(context)
          : _buildPelajaranList(context, quizState),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Belum ada pelajaran',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Pelajaran akan muncul setelah admin menambahkannya',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPelajaranList(BuildContext context, QuizState quizState) {
    return Column(
      children: [
        // Pelajaran list
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: widget.kelas.pelajaran.length,
            itemBuilder: (context, index) {
              final pelajaran = widget.kelas.pelajaran[index];
              final progress = quizState.progressMap[pelajaran.idPelajaran];
              
              return Card(
                margin: EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: Icon(
                      Icons.book,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    pelajaran.namaPelajaran,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${pelajaran.kuis.length} kuis tersedia'),
                      if (progress != null) ...[
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: progress.totalKuis > 0 
                                    ? progress.completedKuis / progress.totalKuis 
                                    : 0,
                                backgroundColor: Colors.grey.shade300,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  progress.isCompleted ? Colors.green : Colors.orange,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '${progress.completedKuis}/${progress.totalKuis}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Skor: ${progress.score.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: progress.isCompleted ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (progress != null && progress.isCompleted)
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                      Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PelajaranDetailPage(
                          pelajaran: pelajaran,
                          kelasNomor: widget.kelas.nomorKelas,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
