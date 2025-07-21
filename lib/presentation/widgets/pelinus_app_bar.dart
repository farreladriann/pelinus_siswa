// lib/presentation/widgets/pelinus_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/kelas_provider.dart';

class PelinusAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showSyncButton;
  final bool showBackButton;

  const PelinusAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showSyncButton = false, // Default: tidak menampilkan sync button
    this.showBackButton = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kelasState = ref.watch(kelasProvider);

    return AppBar(
      leading: showBackButton ? null : const SizedBox.shrink(),
      automaticallyImplyLeading: showBackButton,
      title: Row(
        children: [
          // Logo aplikasi
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/rusabljrbg.png',
              width: 32,
              height: 32,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: Colors.blue,
                    size: 20,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      actions: [
        // Custom actions first
        if (actions != null) ...actions!,
        
        // Sync button (always show, regardless of network status)
        if (showSyncButton)
          IconButton(
            icon: kelasState.isSyncing 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            onPressed: kelasState.isSyncing 
                ? null 
                : () {
                    ref.read(kelasProvider.notifier).performSync();
                  },
            tooltip: 'Sinkronisasi Manual',
          ),
      ],
    );
  }
}
