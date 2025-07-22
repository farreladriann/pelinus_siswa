// lib/presentation/pages/quiz_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pelajaran.dart';
import '../../domain/entities/kuis.dart';
import '../../domain/entities/quiz_result.dart';
import '../providers/quiz_provider.dart';
import '../widgets/pelinus_app_bar.dart';

class QuizPage extends ConsumerStatefulWidget {
  final Pelajaran pelajaran;
  final String kelasNomor;

  const QuizPage({
    super.key,
    required this.pelajaran,
    required this.kelasNomor,
  });

  @override
  ConsumerState<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends ConsumerState<QuizPage> {
  PageController _pageController = PageController();
  int _currentQuestionIndex = 0;
  Map<String, String> _userAnswers = {};

  @override
  void initState() {
    super.initState();
    // Load quiz results when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizProvider.notifier).loadQuizResults(widget.pelajaran.idPelajaran);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizProvider);
    
    return Scaffold(
      appBar: PelinusAppBar(
        title: 'Kuis ${widget.pelajaran.namaPelajaran}',
        showSyncButton: false,
      ),
      body: widget.pelajaran.kuis.isEmpty
          ? _buildEmptyState()
          : _buildQuizContent(quizState),
      bottomNavigationBar: widget.pelajaran.kuis.isNotEmpty
          ? _buildNavigationBar()
          : null,
    );
  }

  Widget _buildEmptyState() {
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

  Widget _buildQuizContent(QuizState quizState) {
    return Column(
      children: [
        // Progress indicator
        Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Soal ${_currentQuestionIndex + 1} dari ${widget.pelajaran.kuis.length}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Kelas ${widget.kelasNomor}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / widget.pelajaran.kuis.length,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        Divider(),
        
        // Quiz content
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentQuestionIndex = index;
              });
            },
            itemCount: widget.pelajaran.kuis.length,
            itemBuilder: (context, index) {
              final kuis = widget.pelajaran.kuis[index];
              return _buildQuestionCard(kuis, quizState);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(Kuis kuis, QuizState quizState) {
    final isAnswered = quizState.quizResults.containsKey(kuis.idKuis);
    final userAnswer = quizState.quizResults[kuis.idKuis]?.userAnswer;
    final showResults = isAnswered;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question header
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
                      'Soal #${kuis.nomorKuis}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  if (isAnswered)
                    Icon(
                      quizState.quizResults[kuis.idKuis]!.isCorrect
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: quizState.quizResults[kuis.idKuis]!.isCorrect
                          ? Colors.green
                          : Colors.red,
                    ),
                ],
              ),
              SizedBox(height: 20),

              // Question text
              Text(
                kuis.soal,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 20),

              // Answer options
              _buildAnswerOption('A', kuis.opsiA, kuis, showResults, userAnswer),
              _buildAnswerOption('B', kuis.opsiB, kuis, showResults, userAnswer),
              _buildAnswerOption('C', kuis.opsiC, kuis, showResults, userAnswer),
              _buildAnswerOption('D', kuis.opsiD, kuis, showResults, userAnswer),

              if (showResults) ...[
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: quizState.quizResults[kuis.idKuis]!.isCorrect
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        quizState.quizResults[kuis.idKuis]!.isCorrect
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: quizState.quizResults[kuis.idKuis]!.isCorrect
                            ? Colors.green
                            : Colors.red,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          quizState.quizResults[kuis.idKuis]!.isCorrect
                              ? 'Benar! Jawaban Anda tepat.'
                              : 'Jawaban Anda salah.',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: quizState.quizResults[kuis.idKuis]!.isCorrect
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerOption(
    String label,
    String text,
    Kuis kuis,
    bool showResults,
    String? userAnswer,
  ) {
    final isSelected = _userAnswers[kuis.idKuis] == label;
    final isUserAnswer = userAnswer == label;
    final isCorrectAnswer = kuis.opsiJawaban == label;
    
    Color? backgroundColor;
    Color? borderColor;
    Color? textColor;

    if (showResults) {
      // Hanya tampilkan jawaban yang salah dengan warna merah
      if (isUserAnswer && !isCorrectAnswer) {
        backgroundColor = Colors.red.shade100;
        borderColor = Colors.red;
        textColor = Colors.red.shade800;
      } else {
        // Semua opsi lain tetap abu-abu (termasuk jawaban yang benar)
        backgroundColor = Colors.grey.shade100;
        borderColor = Colors.grey.shade300;
        textColor = Colors.black87;
      }
    } else {
      if (isSelected) {
        backgroundColor = Theme.of(context).colorScheme.primary.withOpacity(0.1);
        borderColor = Theme.of(context).colorScheme.primary;
        textColor = Theme.of(context).colorScheme.primary;
      } else {
        backgroundColor = Colors.grey.shade50;
        borderColor = Colors.grey.shade300;
        textColor = Colors.black87;
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: showResults
            ? null
            : () {
                setState(() {
                  _userAnswers[kuis.idKuis] = label;
                });
                _submitAnswer(kuis, label);
              },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: borderColor,
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 15,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Tidak menampilkan ikon centang untuk jawaban benar
              if (showResults && isUserAnswer && !isCorrectAnswer)
                Icon(
                  Icons.cancel,
                  color: Colors.red,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationBar() {
    final canGoPrevious = _currentQuestionIndex > 0;
    final canGoNext = _currentQuestionIndex < widget.pelajaran.kuis.length - 1;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (canGoPrevious)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _pageController.previousPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                icon: Icon(Icons.arrow_back),
                label: Text('Sebelumnya'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  foregroundColor: Colors.black87,
                ),
              ),
            )
          else
            Spacer(),
          SizedBox(width: 16),
          if (canGoNext)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                icon: Icon(Icons.arrow_forward),
                label: Text('Selanjutnya'),
              ),
            )
          else
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _showCompletionDialog();
                },
                icon: Icon(Icons.check),
                label: Text('Selesai'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _submitAnswer(Kuis kuis, String userAnswer) {
    ref.read(quizProvider.notifier).answerQuiz(
      idPelajaran: widget.pelajaran.idPelajaran,
      idKuis: kuis.idKuis,
      userAnswer: userAnswer,
      correctAnswer: kuis.opsiJawaban,
    );
  }

  void _showCompletionDialog() {
    final progress = ref.read(quizProvider).progressMap[widget.pelajaran.idPelajaran];
    final quizResults = ref.read(quizProvider).quizResults;
    final currentPelajaranResults = quizResults.values
        .where((result) => result.idPelajaran == widget.pelajaran.idPelajaran)
        .toList();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              progress?.isCompleted == true ? Icons.celebration : Icons.quiz,
              color: progress?.isCompleted == true ? Colors.green : Colors.blue,
            ),
            SizedBox(width: 8),
            Text(progress?.isCompleted == true ? 'Kuis Selesai!' : 'Progress Kuis'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (progress?.isCompleted == true) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.star, color: Colors.green, size: 32),
                      SizedBox(height: 8),
                      Text(
                        'Selamat!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      Text(
                        'Anda telah menyelesaikan semua kuis',
                        style: TextStyle(color: Colors.green.shade700),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
              ],
              
              Text('Hasil Anda:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 12),
              
              if (progress != null) ...[
                _buildResultItem('Soal dijawab', '${progress.completedKuis}/${progress.totalKuis}'),
                _buildResultItem('Jawaban benar', '${progress.correctAnswers}'),
                _buildResultItem('Jawaban salah', '${progress.completedKuis - progress.correctAnswers}'),
                _buildResultItem('Skor akhir', '${progress.score.toStringAsFixed(1)}%'),
                
                SizedBox(height: 16),
                
                // Score indicator
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getScoreColor(progress.score).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _getScoreColor(progress.score).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(_getScoreIcon(progress.score), color: _getScoreColor(progress.score)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getScoreText(progress.score),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getScoreColor(progress.score),
                              ),
                            ),
                            Text(
                              _getScoreDescription(progress.score),
                              style: TextStyle(
                                fontSize: 12,
                                color: _getScoreColor(progress.score).withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Show individual question results if available
              if (currentPelajaranResults.isNotEmpty) ...[
                SizedBox(height: 16),
                Text('Detail Jawaban:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 8),
                ...currentPelajaranResults.map((result) {
                  Kuis? kuis;
                  try {
                    kuis = widget.pelajaran.kuis.firstWhere(
                      (k) => k.idKuis == result.idKuis,
                    );
                  } catch (e) {
                    // If not found, use the first quiz as fallback
                    kuis = widget.pelajaran.kuis.isNotEmpty 
                        ? widget.pelajaran.kuis.first 
                        : null;
                  }
                  
                  if (kuis != null) {
                    return _buildQuestionResult(kuis, result);
                  } else {
                    return SizedBox.shrink();
                  }
                }).toList(),
              ],
            ],
          ),
        ),
        actions: [
          if (progress != null && progress.completedKuis < progress.totalKuis)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Lanjutkan'),
            ),
          if (progress != null && progress.completedKuis > 0)
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _showResetConfirmation();
              },
              icon: Icon(Icons.refresh, color: Colors.orange),
              label: Text('Ulangi', style: TextStyle(color: Colors.orange)),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('Selesai'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionResult(Kuis kuis, QuizResult result) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: result.isCorrect ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: result.isCorrect ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: result.isCorrect ? Colors.green : Colors.red,
            ),
            child: Center(
              child: Text(
                '${kuis.nomorKuis}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Soal ${kuis.nomorKuis}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Jawaban: ${result.userAnswer} ${result.isCorrect ? '(Benar)' : '(Salah)'}',
                  style: TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
          Icon(
            result.isCorrect ? Icons.check_circle : Icons.cancel,
            color: result.isCorrect ? Colors.green : Colors.red,
            size: 20,
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  IconData _getScoreIcon(double score) {
    if (score >= 80) return Icons.sentiment_very_satisfied;
    if (score >= 60) return Icons.sentiment_satisfied;
    return Icons.sentiment_dissatisfied;
  }

  String _getScoreText(double score) {
    if (score >= 80) return 'Excellent!';
    if (score >= 60) return 'Good Job!';
    return 'Keep Trying!';
  }

  String _getScoreDescription(double score) {
    if (score >= 80) return 'Pemahaman materi sangat baik';
    if (score >= 60) return 'Pemahaman materi cukup baik';
    return 'Perlu belajar lebih giat lagi';
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ulangi Kuis?'),
        content: Text(
          'Apakah Anda yakin ingin mengulang kuis ini? Semua jawaban sebelumnya akan dihapus.',
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text('Ulangi'),
          ),
        ],
      ),
    );
  }

  void _performReset() async {
    try {
      await ref.read(quizProvider.notifier).resetProgress(widget.pelajaran.idPelajaran);
      
      // Reset local state
      setState(() {
        _userAnswers.clear();
        _currentQuestionIndex = 0;
      });
      
      // Go to first question
      _pageController.animateToPage(
        0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kuis berhasil direset. Anda dapat memulai dari awal.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mereset kuis'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
