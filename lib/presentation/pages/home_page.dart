// lib/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../providers/kelas_provider.dart';
import '../providers/sync_timer_provider.dart';
import '../providers/quiz_provider.dart';
import '../widgets/modern_card.dart';
import 'pelajaran_list_page.dart';
import 'quiz_statistics_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    // Load data and start auto sync when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(kelasProvider.notifier).loadCachedData();
      ref.read(syncTimerProvider.notifier).performInitialSync();
      ref.read(syncTimerProvider.notifier).startAutoSync();
      
      // Start animations
      _animationController.forward();
      
      // Load quiz progress for all pelajaran
      _loadAllProgress();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadAllProgress() {
    final kelasState = ref.read(kelasProvider);
    for (var kelas in kelasState.kelasList) {
      for (var pelajaran in kelas.pelajaran) {
        ref.read(quizProvider.notifier).loadPelajaranProgress(pelajaran.idPelajaran);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final kelasState = ref.watch(kelasProvider);
    final syncTimerState = ref.watch(syncTimerProvider);
    final quizState = ref.watch(quizProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: CustomScrollView(
          slivers: [
            // Enhanced App Bar
            SliverAppBar(
              expandedHeight: 120.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.heroGradient,
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(AppDimensions.spacing16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Logo
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                                  child: Image.asset(
                                    'assets/images/rusabljrbg.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.school,
                                        color: Colors.white,
                                        size: AppDimensions.iconLarge,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(width: AppDimensions.spacing12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pelinus Mengajar',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Platform Pembelajaran Digital',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Sync button
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
                                ),
                                child: IconButton(
                                  icon: kelasState.isSyncing 
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : Icon(Icons.sync, color: Colors.white),
                                  onPressed: kelasState.isSyncing 
                                      ? null 
                                      : () {
                                          ref.read(kelasProvider.notifier).performSync();
                                        },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Content
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildContent(context, kelasState, quizState),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: kelasState.kelasList.isNotEmpty 
          ? AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => QuizStatisticsPage(
                            kelasList: kelasState.kelasList,
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.analytics),
                    label: Text('Statistik'),
                    backgroundColor: AppColors.primary,
                    elevation: AppDimensions.elevationFloating,
                  ),
                );
              },
            )
          : null,
    );
  }

  Widget _buildContent(BuildContext context, KelasState kelasState, QuizState quizState) {
    if (kelasState.isLoading && kelasState.kelasList.isEmpty) {
      return _buildLoadingState();
    }

    if (kelasState.kelasList.isEmpty) {
      return _buildEmptyState(kelasState);
    }

    return Column(
      children: [
        // Stats Overview
        _buildStatsOverview(kelasState, quizState),
        
        // Sync Status
        if (kelasState.isSyncing) _buildSyncStatus(),
        
        // Kelas Grid
        _buildKelasGrid(kelasState, quizState),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            SizedBox(height: AppDimensions.spacing16),
            Text(
              'Memuat data...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(KelasState kelasState) {
    return Container(
      height: 400,
      padding: EdgeInsets.all(AppDimensions.spacing24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusExtraLarge),
              ),
              child: Icon(
                Icons.school_outlined,
                size: AppDimensions.iconMassive,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: AppDimensions.spacing24),
            Text(
              'Belum ada data kelas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppDimensions.spacing8),
            Text(
              'Lakukan sinkronisasi untuk memuat data kelas dan mata pelajaran',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDimensions.spacing24),
            ElevatedButton.icon(
              onPressed: kelasState.isSyncing 
                  ? null 
                  : () {
                      ref.read(kelasProvider.notifier).performSync();
                    },
              icon: kelasState.isSyncing
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.sync),
              label: Text(kelasState.isSyncing ? 'Menyinkronkan...' : 'Sinkronisasi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing24,
                  vertical: AppDimensions.spacing12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverview(KelasState kelasState, QuizState quizState) {
    final totalKelas = kelasState.kelasList.length;
    final totalPelajaran = kelasState.kelasList
        .fold<int>(0, (sum, kelas) => sum + kelas.pelajaran.length);
    final totalKuis = kelasState.kelasList
        .fold<int>(0, (sum, kelas) => sum + kelas.pelajaran
            .fold<int>(0, (sum2, pelajaran) => sum2 + pelajaran.kuis.length));
    
    final allProgress = quizState.progressMap.values.toList();
    final completedKuis = allProgress.fold<int>(0, (sum, p) => sum + p.completedKuis);

    return Padding(
      padding: EdgeInsets.all(AppDimensions.spacing16),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              title: 'Total Kelas',
              value: totalKelas.toString(),
              subtitle: 'Tersedia',
              icon: Icons.class_,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: AppDimensions.spacing12),
          Expanded(
            child: StatCard(
              title: 'Mata Pelajaran',
              value: totalPelajaran.toString(),
              subtitle: 'Pelajaran',
              icon: Icons.book,
              color: AppColors.secondary,
            ),
          ),
          SizedBox(width: AppDimensions.spacing12),
          Expanded(
            child: StatCard(
              title: 'Kuis Selesai',
              value: completedKuis.toString(),
              subtitle: 'dari $totalKuis',
              icon: Icons.quiz,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncStatus() {
    return ModernCard(
      margin: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing16,
        vertical: AppDimensions.spacing8,
      ),
      backgroundColor: AppColors.info.withOpacity(0.1),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.info),
            ),
          ),
          SizedBox(width: AppDimensions.spacing12),
          Text(
            'Melakukan sinkronisasi...',
            style: TextStyle(
              color: AppColors.info,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKelasGrid(KelasState kelasState, QuizState quizState) {
    return Padding(
      padding: EdgeInsets.all(AppDimensions.spacing16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: AppDimensions.spacing12,
          mainAxisSpacing: AppDimensions.spacing12,
        ),
        itemCount: kelasState.kelasList.length,
        itemBuilder: (context, index) {
          final kelas = kelasState.kelasList[index];
          final kelasProgress = kelas.pelajaran
              .map((p) => quizState.progressMap[p.idPelajaran])
              .where((p) => p != null)
              .cast()
              .toList();
          
          final completedPelajaran = kelasProgress.where((p) => p.isCompleted).length;
          final totalProgress = kelasProgress.isNotEmpty
              ? kelasProgress.fold<double>(0, (sum, p) => sum + p.score) / kelasProgress.length
              : 0.0;

          return ModernCard(
            margin: EdgeInsets.zero,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.subjectColors[index % AppColors.subjectColors.length],
                AppColors.subjectColors[index % AppColors.subjectColors.length].withOpacity(0.8),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PelajaranListPage(kelas: kelas),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      ),
                      child: Center(
                        child: Text(
                          kelas.nomorKelas,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    if (completedPelajaran == kelas.pelajaran.length && kelas.pelajaran.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: AppDimensions.spacing12),
                Text(
                  'Kelas ${kelas.nomorKelas}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppDimensions.spacing4),
                Text(
                  '${kelas.pelajaran.length} mata pelajaran',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                Spacer(),
                if (kelasProgress.isNotEmpty) ...[
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.white.withOpacity(0.3),
                    ),
                    child: LinearProgressIndicator(
                      value: completedPelajaran / kelas.pelajaran.length,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: AppDimensions.spacing4),
                  Text(
                    'Progress: ${totalProgress.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ] else
                  Text(
                    'Belum ada progress',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      margin: EdgeInsets.zero,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withOpacity(0.1),
          color.withOpacity(0.05),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              Spacer(),
            ],
          ),
          SizedBox(height: AppDimensions.spacing12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppDimensions.spacing4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          SizedBox(height: AppDimensions.spacing4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}