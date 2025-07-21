// lib/presentation/pages/pelajaran_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/kelas.dart';
import '../widgets/pelinus_app_bar.dart';
import 'pelajaran_detail_page.dart';

class PelajaranListPage extends ConsumerWidget {
  final Kelas kelas;

  const PelajaranListPage({
    super.key,
    required this.kelas,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: PelinusAppBar(
        title: 'Kelas ${kelas.nomorKelas}',
        showSyncButton: false, // Tidak ada sync button di halaman ini
      ),
      body: kelas.pelajaran.isEmpty
          ? _buildEmptyState(context)
          : _buildPelajaranList(context),
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

  Widget _buildPelajaranList(BuildContext context) {
    return Column(
      children: [
        // Pelajaran list
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: kelas.pelajaran.length,
            itemBuilder: (context, index) {
              final pelajaran = kelas.pelajaran[index];
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
                  subtitle: Text('${pelajaran.kuis.length} kuis tersedia'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PelajaranDetailPage(
                          pelajaran: pelajaran,
                          kelasNomor: kelas.nomorKelas,
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
