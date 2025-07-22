// lib/presentation/pages/pdf_viewer_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';
import '../../core/utils/logger.dart';
import '../../domain/entities/pdf_file.dart';
import '../widgets/pelinus_app_bar.dart';

class PdfViewerPage extends StatefulWidget {
  final PdfFile pdfFile;
  final String pelajaranName;

  const PdfViewerPage({
    super.key,
    required this.pdfFile,
    required this.pelajaranName,
  });

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PelinusAppBar(
        title: widget.pelajaranName,
        showSyncButton: false, // Tidak ada sync button di halaman ini
        actions: [
          if (isReady && pages != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  '${(currentPage ?? 0) + 1} / $pages',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Check if file exists
    final file = File(widget.pdfFile.filePath);
    if (!file.existsSync()) {
      // Silent error - tampilkan loading terus menerus tanpa error message
      return _buildLoadingState();
    }

    // Jangan tampilkan error, tetap coba render PDF
    return Stack(
      children: [
        PDFView(
          filePath: widget.pdfFile.filePath,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: false,
          pageFling: false,
          onRender: (pages) {
            setState(() {
              this.pages = pages;
              isReady = true;
            });
          },
          onError: (error) {
            // Silent error - tidak mengubah state error
            AppLogger.warning('PDF Error: $error');
          },
          onPageError: (page, error) {
            // Silent error - tidak mengubah state error
            AppLogger.warning('PDF Page Error: $page - $error');
          },
          onViewCreated: (PDFViewController pdfViewController) {
            // PDF controller ready
          },
          onPageChanged: (page, total) {
            setState(() {
              currentPage = page;
            });
          },
        ),
        
        // Loading indicator
        if (!isReady)
          _buildLoadingState(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Memuat PDF...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
