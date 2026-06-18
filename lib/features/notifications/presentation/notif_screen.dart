// =============================================================
// FILE: lib/features/notifications/presentation/notif_screen.dart
// VERSI: Tampilan dasar — siap dihubungkan ke FCM/Firestore nanti
// =============================================================
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class NotifItem {
  final String icon, title, body, time;
  final bool isRead;
  const NotifItem({required this.icon, required this.title, required this.body,
    required this.time, this.isRead = false});
}

class NotifScreen extends StatefulWidget {
  const NotifScreen({super.key});
  @override
  State<NotifScreen> createState() => _NotifScreenState();
}

class _NotifScreenState extends State<NotifScreen> {
  // TODO: ganti dengan data dari Firestore collection notifications/{uid}/userNotifs
  List<NotifItem> _notifs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(backgroundColor: AppColors.surface, title: Text('Notifikasi', style: AppTypography.h3)),
      body: _notifs.isEmpty ? _buildEmpty() : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8), itemCount: _notifs.length,
        itemBuilder: (_, i) => _NotifTile(item: _notifs[i],
          onDismiss: () => setState(() => _notifs.removeAt(i)))),
    );
  }

  Widget _buildEmpty() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    const Icon(Icons.notifications_none, size: 56, color: AppColors.textTertiary),
    const SizedBox(height: 16),
    Text('Tidak ada notifikasi', style: AppTypography.bodyMuted),
  ]));
}

class _NotifTile extends StatelessWidget {
  final NotifItem item;
  final VoidCallback onDismiss;
  const _NotifTile({required this.item, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Dismissible(key: Key('${item.title}_${item.time}'), direction: DismissDirection.endToStart,
      background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20),
        color: AppColors.coralDim, child: const Icon(Icons.delete_outline, color: AppColors.coral)),
      onDismissed: (_) => onDismiss(),
      child: Container(margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: item.isRead ? AppColors.surface : AppColors.surface2,
          borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(
            color: AppColors.tealDim, borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(item.icon, style: const TextStyle(fontSize: 20)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.title, style: AppTypography.h4.copyWith(fontSize: 13)),
            const SizedBox(height: 4),
            Text(item.body, style: AppTypography.caption, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Text(item.time, style: AppTypography.caption.copyWith(fontSize: 10, color: AppColors.textTertiary)),
          ])),
        ])));
  }
}
