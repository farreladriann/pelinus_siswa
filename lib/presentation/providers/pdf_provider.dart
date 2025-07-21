// lib/presentation/providers/pdf_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pdf_file.dart';
import '../../domain/usecases/get_pdf_file.dart';
import 'app_providers.dart';

// State classes
class PdfState {
  final PdfFile? pdfFile;
  final bool isLoading;
  final String? error;

  PdfState({
    this.pdfFile,
    this.isLoading = false,
    this.error,
  });

  PdfState copyWith({
    PdfFile? pdfFile,
    bool? isLoading,
    String? error,
  }) {
    return PdfState(
      pdfFile: pdfFile ?? this.pdfFile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// PDF Provider
class PdfNotifier extends StateNotifier<PdfState> {
  final GetPdfFile getPdfFile;

  PdfNotifier({
    required this.getPdfFile,
  }) : super(PdfState());

  Future<void> loadPdfFile(String idPelajaran) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final pdfFile = await getPdfFile(idPelajaran);
      state = state.copyWith(
        pdfFile: pdfFile,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearPdf() {
    state = PdfState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider definition
final pdfProvider = StateNotifierProvider<PdfNotifier, PdfState>((ref) {
  return PdfNotifier(
    getPdfFile: ref.read(getPdfFileProvider),
  );
});
