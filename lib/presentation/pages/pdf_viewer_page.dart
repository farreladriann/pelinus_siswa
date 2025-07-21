// lib/presentation/pages/pdf_viewer_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';
import '../../domain/entities/pdf_file.dart';

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
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pelajaranName),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (isReady && pages != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  '${(currentPage ?? 0) + 1} / $pages',
                  style: TextStyle(fontWeight: FontWeight.w500),
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
      return _buildErrorState('File PDF tidak ditemukan di perangkat');
    }

    if (errorMessage.isNotEmpty) {
      return _buildErrorState(errorMessage);
    }

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
            setState(() {
              errorMessage = error.toString();
            });
          },
          onPageError: (page, error) {
            setState(() {
              errorMessage = 'Error pada halaman $page: $error';
            });
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
        if (!isReady && errorMessage.isEmpty)
          Container(
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat PDF...'),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              'Gagal Membuka PDF',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade700),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}
