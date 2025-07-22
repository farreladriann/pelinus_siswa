// lib/presentation/pages/pelajaran_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/kelas.dart';
import '../providers/quiz_provider.dart';
import '../widgets/pelinus_app_bar.dart';
import '../widgets/enhanced_card.dart';
import '../widgets/circular_progress_widget.dart';
import '../themes/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import 'package:pelinus_siswa/presentation/pages/pelajaran_detail_page.dart' show PelajaranDetailPage;

class PelajaranListPage extends ConsumerStatefulWidget {
  final Kelas kelas;

  const PelajaranListPage({
    super.key,
    required this.kelas,
  });

  @override
  ConsumerState<PelajaranListPage> createState() => _PelajaranListPageState();
}

class _PelajaranListPageState extends ConsumerState<PelajaranListPage> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animation setup
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    // Load progress for all pelajaran when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var pelajaran in widget.kelas.pelajaran) {
        ref.read(quizProvider.notifier).loadPelajaranProgress(pelajaran.idPelajaran);
      }
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PelinusAppBar(
        title: 'Kelas ${widget.kelas.nomorKelas}',
        showSyncButton: false,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.kelas.pelajaran.isEmpty
            ? _buildEmptyState(context)
            : _buildPelajaranList(context, quizState),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(AppDimensions.spacing32),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.book_outlined,
              size: AppDimensions.iconMassive * 1.5,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppDimensions.spacing24),
          Text(
            'Belum ada pelajaran',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppDimensions.spacing8),
          Text(
            'Pelajaran akan muncul setelah admin menambahkannya',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPelajaranList(BuildContext context, QuizState quizState) {
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
      child: ListView.builder(
        padding: EdgeInsets.all(AppSizes.md),
        itemCount: widget.kelas.pelajaran.length,
        itemBuilder: (context, index) {
          final pelajaran = widget.kelas.pelajaran[index];
          final progress = quizState.progressMap[pelajaran.idPelajaran];
          
          return AnimatedContainer(
            duration: Duration(milliseconds: 300 + (index * 100)),
            curve: Curves.easeOutBack,
            child: PelajaranCard(
              title: pelajaran.namaPelajaran,
              subtitle: '${pelajaran.kuis.length} kuis tersedia',
              leading: Icon(
                _getSubjectIcon(pelajaran.namaPelajaran),
                color: _getSubjectColor(pelajaran.namaPelajaran),
                size: AppSizes.iconLarge,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (progress != null && progress.isCompleted)
                    Container(
                      padding: EdgeInsets.all(AppSizes.xs),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  SizedBox(width: AppSizes.sm),
                  if (progress != null)
                    CircularProgressRing(
                      progress: progress.totalKuis > 0 
                          ? progress.completedKuis / progress.totalKuis 
                          : 0.0,
                      size: 40,
                      color: _getProgressColor(progress),
                      centerText: '${(progress.totalKuis > 0 ? (progress.completedKuis / progress.totalKuis * 100) : 0).toInt()}%',
                    )
                  else
                    CircularProgressRing(
                      progress: 0.0,
                      size: 40,
                      color: AppColors.textHint,
                      centerText: '0%',
                    ),
                  SizedBox(width: AppSizes.sm),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
                ],
              ),
              progressWidget: progress != null ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: Colors.grey.shade200,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: progress.totalKuis > 0 
                                  ? progress.completedKuis / progress.totalKuis 
                                  : 0,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getProgressColor(progress),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSizes.sm),
                      Text(
                        '${progress.completedKuis}/${progress.totalKuis}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (progress.completedKuis > 0) ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSizes.sm,
                            vertical: AppSizes.xs,
                          ),
                          decoration: BoxDecoration(
                            color: _getScoreColor(progress.score).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getScoreIcon(progress.score),
                                size: 12,
                                color: _getScoreColor(progress.score),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Skor: ${progress.score.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: _getScoreColor(progress.score),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (progress.lastAttemptAt != null)
                        Text(
                          _formatDateTime(progress.lastAttemptAt!),
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textHint,
                          ),
                        ),
                    ],
                  ),
                ],
              ) : null,
              accentColor: _getSubjectColor(pelajaran.namaPelajaran),
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
    );
  }

  IconData _getSubjectIcon(String subjectName) {
    final name = subjectName.toLowerCase();
    if (name.contains('matematik')) return Icons.calculate;
    if (name.contains('bahasa')) return Icons.translate;
    if (name.contains('ipa') || name.contains('sains')) return Icons.science;
    if (name.contains('ips') || name.contains('sosial')) return Icons.public;
    if (name.contains('agama')) return Icons.mosque;
    if (name.contains('seni')) return Icons.palette;
    if (name.contains('olahraga')) return Icons.sports;
    return Icons.book;
  }

  Color _getSubjectColor(String subjectName) {
    final name = subjectName.toLowerCase();
    if (name.contains('matematik')) return Colors.blue;
    if (name.contains('bahasa')) return Colors.green;
    if (name.contains('ipa') || name.contains('sains')) return Colors.purple;
    if (name.contains('ips') || name.contains('sosial')) return Colors.orange;
    if (name.contains('agama')) return Colors.teal;
    if (name.contains('seni')) return Colors.pink;
    if (name.contains('olahraga')) return Colors.red;
    return AppColors.primary;
  }

  Color _getProgressColor(progress) {
    if (progress.isCompleted) return AppColors.success;
    if (progress.completedKuis > 0) return AppColors.secondary;
    return AppColors.textHint;
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }

  IconData _getScoreIcon(double score) {
    if (score >= 80) return Icons.sentiment_very_satisfied;
    if (score >= 60) return Icons.sentiment_satisfied;
    return Icons.sentiment_dissatisfied;
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }
}
