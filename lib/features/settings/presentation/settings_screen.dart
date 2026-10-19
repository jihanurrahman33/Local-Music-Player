import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/platform/permission_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../library/presentation/library_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final persistence = ref.watch(persistenceServiceProvider);
    final shuffleByDefault = persistence.shuffleByDefault;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            _Section(
              title: 'Library',
              children: [
                ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text('Refresh library'),
                  subtitle: const Text(
                      'Rescan device for new or updated audio files'),
                  onTap: () async {
                    await ref
                        .read(libraryNotifierProvider.notifier)
                        .load(refresh: true);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Library refreshed successfully')),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.folder_open),
                  title: const Text('Import files / folders'),
                  subtitle: const Text('iOS document picker & manual import'),
                  onTap: () {
                    ref.read(libraryNotifierProvider.notifier).importFiles();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('Media permissions'),
                  subtitle: const Text('Manage storage and audio permissions'),
                  onTap: () => PermissionService.openSettings(),
                ),
              ],
            ),
            _Section(
              title: 'Playback',
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.shuffle),
                  title: const Text('Shuffle by default'),
                  subtitle: const Text('Automatically shuffle queue on play'),
                  value: shuffleByDefault,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) async {
                    await persistence.setShuffleByDefault(val);
                    setState(() {});
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Clear listening history'),
                  subtitle: const Text(
                      'Reset recently played tracks and play counts'),
                  onTap: () => _showClearHistoryDialog(context),
                ),
              ],
            ),
            _Section(
              title: 'About',
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Version'),
                  subtitle: Text('0.1.0+1 (Alpha)'),
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy statement'),
                  subtitle: const Text(
                      '100% offline. Zero network calls or tracking.'),
                  onTap: () => _showPrivacyDialog(context),
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Open source licenses'),
                  onTap: () {
                    showLicensePage(
                      context: context,
                      applicationName: 'Local Music Player',
                      applicationVersion: '0.1.0',
                      applicationLegalese:
                          'MIT License • Offline Local Music Player inspired by YouTube Music',
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text('Clear listening history?'),
        content: const Text(
          'This will remove all entries from "Listen again" and reset play counts. Your audio files and playlists will not be affected.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              await ref.read(libraryNotifierProvider.notifier).clearHistory();
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Listening history cleared')),
                );
              }
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text('Privacy Statement'),
        content: const SingleChildScrollView(
          child: Text(
            'Local Music Player is an offline-first, local audio player.\n\n'
            '• No accounts or sign-ins.\n'
            '• No telemetry, crash logs, or analytics sent to remote servers.\n'
            '• No audio files or library metadata ever leave your device.\n'
            '• Audio playback runs directly on your device hardware.',
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Card(
          color: AppColors.surfaceCard,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(children: children),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
