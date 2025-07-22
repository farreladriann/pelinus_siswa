// lib/presentation/pages/quiz_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pelajaran.dart';
import '../../domain/entities/kuis.dart';
import '../providers/quiz_provider.dart';
import '../widgets/pelinus_app_bar.dart';
import '../themes/app_colors.dart';

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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background,
            AppColors.surface,
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.quiz_outlined,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Belum ada kuis',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Kuis akan muncul setelah admin menambahkannya',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Periksa kembali nanti',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizContent(QuizState quizState) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background,
            AppColors.surface,
          ],
        ),
      ),
      child: Column(
        children: [
          // Enhanced progress indicator
          Container(
            padding: EdgeInsets.all(AppSizes.md),
            margin: EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Soal ${_currentQuestionIndex + 1} dari ${widget.pelajaran.kuis.length}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Kelas ${widget.kelasNomor}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                        vertical: AppSizes.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${(((_currentQuestionIndex + 1) / widget.pelajaran.kuis.length) * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSizes.md),
                
                // Enhanced progress bar
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey.shade200,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_currentQuestionIndex + 1) / widget.pelajaran.kuis.length,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
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
      ),
    );
  }

  Widget _buildQuestionCard(Kuis kuis, QuizState quizState) {
    final isAnswered = quizState.quizResults.containsKey(kuis.idKuis);
    final userAnswer = quizState.quizResults[kuis.idKuis]?.userAnswer;
    final showResults = isAnswered;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryLight.withOpacity(0.1),
              AppColors.secondaryLight.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question header with enhanced styling
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${kuis.nomorKuis}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Soal #${kuis.nomorKuis}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          if (isAnswered)
                            Text(
                              quizState.quizResults[kuis.idKuis]!.isCorrect
                                  ? 'Terjawab dengan benar'
                                  : 'Terjawab dengan salah',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (isAnswered)
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          quizState.quizResults[kuis.idKuis]!.isCorrect
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Question text with enhanced styling
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Text(
                  kuis.soal,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Answer options with enhanced styling
              Text(
                'Pilih jawaban:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 12),
              _buildAnswerOption('A', kuis.opsiA, kuis, showResults, userAnswer),
              SizedBox(height: 8),
              _buildAnswerOption('B', kuis.opsiB, kuis, showResults, userAnswer),
              SizedBox(height: 8),
              _buildAnswerOption('C', kuis.opsiC, kuis, showResults, userAnswer),
              SizedBox(height: 8),
              _buildAnswerOption('D', kuis.opsiD, kuis, showResults, userAnswer),

              if (showResults) ...[
                SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: quizState.quizResults[kuis.idKuis]!.isCorrect
                        ? LinearGradient(
                            colors: [Colors.green.shade50, Colors.green.shade100],
                          )
                        : LinearGradient(
                            colors: [Colors.red.shade50, Colors.red.shade100],
                          ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: quizState.quizResults[kuis.idKuis]!.isCorrect
                          ? Colors.green.shade300
                          : Colors.red.shade300,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: quizState.quizResults[kuis.idKuis]!.isCorrect
                              ? Colors.green
                              : Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          quizState.quizResults[kuis.idKuis]!.isCorrect
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          quizState.quizResults[kuis.idKuis]!.isCorrect
                              ? 'Benar! Jawaban Anda tepat.'
                              : 'Jawaban Anda salah.',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
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
    Color? labelBackgroundColor;
    Color? labelTextColor;

    if (showResults) {
      // Hanya tampilkan jawaban yang salah dengan warna merah
      if (isUserAnswer && !isCorrectAnswer) {
        backgroundColor = Colors.red.shade50;
        borderColor = Colors.red.shade300;
        textColor = Colors.red.shade800;
        labelBackgroundColor = Colors.red;
        labelTextColor = Colors.white;
      } else {
        // Semua opsi lain tetap abu-abu (termasuk jawaban yang benar)
        backgroundColor = Colors.grey.shade50;
        borderColor = Colors.grey.shade300;
        textColor = AppColors.textPrimary;
        labelBackgroundColor = Colors.grey.shade400;
        labelTextColor = Colors.white;
      }
    } else {
      if (isSelected) {
        backgroundColor = AppColors.primary.withOpacity(0.1);
        borderColor = AppColors.primary;
        textColor = AppColors.primary;
        labelBackgroundColor = AppColors.primary;
        labelTextColor = Colors.white;
      } else {
        backgroundColor = Colors.white;
        borderColor = Colors.grey.shade300;
        textColor = AppColors.textPrimary;
        labelBackgroundColor = Colors.grey.shade300;
        labelTextColor = Colors.grey.shade600;
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        elevation: isSelected && !showResults ? 2 : 0,
        shadowColor: AppColors.primary.withOpacity(0.3),
        child: InkWell(
          onTap: showResults
              ? null
              : () {
                  setState(() {
                    _userAnswers[kuis.idKuis] = label;
                  });
                  _submitAnswer(kuis, label);
                },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: borderColor,
                width: isSelected && !showResults ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: labelBackgroundColor,
                    boxShadow: isSelected && !showResults
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: labelTextColor,
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
                      height: 1.3,
                    ),
                  ),
                ),
                // Tidak menampilkan ikon centang untuk jawaban benar
                if (showResults && isUserAnswer && !isCorrectAnswer)
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationBar() {
    final canGoPrevious = _currentQuestionIndex > 0;
    final canGoNext = _currentQuestionIndex < widget.pelajaran.kuis.length - 1;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (canGoPrevious)
              Expanded(
                child: Container(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    icon: Icon(Icons.arrow_back_ios, size: 18),
                    label: Text(
                      'Sebelumnya',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: AppColors.textSecondary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              )
            else
              Spacer(),
            SizedBox(width: 16),
            if (canGoNext)
              Expanded(
                child: Container(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    icon: Icon(Icons.arrow_forward_ios, size: 18),
                    label: Text(
                      'Selanjutnya',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: AppColors.primary.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: Container(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showCompletionDialog();
                    },
                    icon: Icon(Icons.check_circle, size: 20),
                    label: Text(
                      'Selesai',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: Colors.green.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
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
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon and title
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: progress?.isCompleted == true 
                        ? LinearGradient(
                            colors: [Colors.green.shade400, Colors.green.shade600],
                          )
                        : AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          progress?.isCompleted == true ? Icons.celebration : Icons.quiz,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        progress?.isCompleted == true ? 'Kuis Selesai!' : 'Progress Kuis',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (progress?.isCompleted == true)
                        Text(
                          'Selamat! Anda telah menyelesaikan semua kuis',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Results summary
                if (progress != null) ...[
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hasil Anda',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 16),
                        
                        _buildEnhancedResultItem(
                          Icons.quiz,
                          'Soal dijawab',
                          '${progress.completedKuis}/${progress.totalKuis}',
                          AppColors.primary,
                        ),
                        _buildEnhancedResultItem(
                          Icons.check_circle,
                          'Jawaban benar',
                          '${progress.correctAnswers}',
                          Colors.green,
                        ),
                        _buildEnhancedResultItem(
                          Icons.cancel,
                          'Jawaban salah',
                          '${progress.completedKuis - progress.correctAnswers}',
                          Colors.red,
                        ),
                        
                        SizedBox(height: 16),
                        
                        // Score display with circular progress
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getScoreColor(progress.score).withOpacity(0.1),
                                _getScoreColor(progress.score).withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getScoreColor(progress.score).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                child: Stack(
                                  children: [
                                    CircularProgressIndicator(
                                      value: progress.score / 100,
                                      strokeWidth: 6,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        _getScoreColor(progress.score),
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        '${progress.score.toStringAsFixed(0)}%',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: _getScoreColor(progress.score),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getScoreText(progress.score),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: _getScoreColor(progress.score),
                                      ),
                                    ),
                                    Text(
                                      _getScoreDescription(progress.score),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                SizedBox(height: 24),
                
                // Action buttons
                Row(
                  children: [
                    if (progress != null && progress.completedKuis < progress.totalKuis)
                      Expanded(
                        child: Container(
                          height: 48,
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                              ),
                            ),
                            child: Text(
                              'Lanjutkan',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (progress != null && progress.completedKuis > 0) ...[
                      if (progress.completedKuis < progress.totalKuis) SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 48,
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _showResetConfirmation();
                            },
                            icon: Icon(Icons.refresh, color: Colors.orange, size: 18),
                            label: Text(
                              'Ulangi',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.orange.withOpacity(0.3)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Container(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shadowColor: AppColors.primary.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Selesai',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedResultItem(IconData icon, String label, String value, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
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
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning icon
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber,
                  color: Colors.orange,
                  size: 32,
                ),
              ),
              SizedBox(height: 16),
              
              // Title
              Text(
                'Ulangi Kuis?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 12),
              
              // Content
              Text(
                'Apakah Anda yakin ingin mengulang kuis ini? Semua jawaban sebelumnya akan dihapus dan tidak dapat dikembalikan.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _performReset();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: Colors.orange.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Ulangi',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
