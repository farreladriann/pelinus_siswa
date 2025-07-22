// lib/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/kelas_provider.dart';
import '../providers/sync_timer_provider.dart';
import '../widgets/pelinus_app_bar.dart';
import 'pelajaran_list_page.dart';
import 'quiz_statistics_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load data and start auto sync when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(kelasProvider.notifier).loadCachedData();
      ref.read(syncTimerProvider.notifier).performInitialSync();
      ref.read(syncTimerProvider.notifier).startAutoSync();
    });
  }

  @override
  Widget build(BuildContext context) {
    final kelasState = ref.watch(kelasProvider);
    final syncTimerState = ref.watch(syncTimerProvider);

    // Silent error handling - tidak menampilkan error di UI

    return Scaffold(
      appBar: PelinusAppBar(
        title: 'Pelinus Mengajar',
        showBackButton: false,
        showSyncButton: true, // Hanya di home page yang menampilkan sync button
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(kelasProvider.notifier).performSync();
        },
        child: _buildBody(context, kelasState, syncTimerState),
      ),
      floatingActionButton: kelasState.kelasList.isNotEmpty 
          ? FloatingActionButton.extended(
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
              backgroundColor: Colors.blue,
            )
          : null,
    );
  }

  Widget _buildBody(BuildContext context, KelasState kelasState, SyncTimerState syncTimerState) {
    if (kelasState.isLoading && kelasState.kelasList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat data...'),
          ],
        ),
      );
    }

    // Silent error handling - tidak menampilkan error state

    if (kelasState.kelasList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Belum ada data kelas',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Lakukan sinkronisasi untuk memuat data',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: kelasState.isSyncing 
                  ? null 
                  : () {
                      ref.read(kelasProvider.notifier).performSync();
                    },
              icon: Icon(Icons.sync),
              label: Text('Sinkronisasi'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Status bar
        if (kelasState.isSyncing)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8),
            color: Colors.blue.shade100,
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Melakukan sinkronisasi...'),
              ],
            ),
          ),
        
        // Kelas list
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: kelasState.kelasList.length,
            itemBuilder: (context, index) {
              final kelas = kelasState.kelasList[index];
              return Card(
                margin: EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      kelas.nomorKelas,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text('Kelas ${kelas.nomorKelas}'),
                  subtitle: Text('${kelas.pelajaran.length} pelajaran'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PelajaranListPage(kelas: kelas),
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