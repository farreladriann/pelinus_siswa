// lib/presentation/pages/pelajaran_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pelajaran.dart';
import '../providers/pdf_provider.dart';
import 'pdf_viewer_page.dart';

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
  Widget build(BuildContext context) {
    final pdfState = ref.watch(pdfProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pelajaran.namaPelajaran),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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

          // Divider
          Divider(),

          // Kuis section
          Expanded(
            child: widget.pelajaran.kuis.isEmpty
                ? _buildEmptyKuisState(context)
                : _buildKuisList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyKuisState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.quiz_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Belum ada kuis',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Kuis akan muncul setelah admin menambahkannya',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildKuisList(BuildContext context) {
    return Column(
      children: [
        // Kuis header
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          child: Text(
            'Daftar Kuis',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),

        // Kuis list
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: widget.pelajaran.kuis.length,
            itemBuilder: (context, index) {
              final kuis = widget.pelajaran.kuis[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header kuis
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: Text(
                              '${kuis.nomorKuis}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Kuis #${kuis.nomorKuis}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),

                      // Soal
                      Text(
                        kuis.soal,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 12),

                      // Opsi jawaban
                      _buildOption(context, 'A', kuis.opsiA, kuis.opsiJawaban == 'A'),
                      _buildOption(context, 'B', kuis.opsiB, kuis.opsiJawaban == 'B'),
                      _buildOption(context, 'C', kuis.opsiC, kuis.opsiJawaban == 'C'),
                      _buildOption(context, 'D', kuis.opsiD, kuis.opsiJawaban == 'D'),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOption(BuildContext context, String label, String text, bool isCorrect) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCorrect 
            ? Colors.green.shade100 
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCorrect 
              ? Colors.green.shade300 
              : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCorrect 
                  ? Colors.green 
                  : Colors.grey.shade400,
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isCorrect 
                    ? Colors.green.shade800 
                    : Colors.black87,
              ),
            ),
          ),
          if (isCorrect)
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 20,
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
}
