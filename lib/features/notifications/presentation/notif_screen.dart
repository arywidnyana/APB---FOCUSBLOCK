// =============================================================
// FILE: lib/features/notifications/presentation/notif_screen.dart
// TANGGUNG JAWAB: Layar semua notifikasi — pengingat blok,
//   aktivitas teman, pact update, dan sistem.
// =============================================================

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class NotifItem {
  final String type;   // pact | reminder | friend | system | achievement
  final String title;
  final String body;
  final String time;
  final bool   isRead;
  final String icon;

  const NotifItem({
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
    required this.icon,
  });
}

final List<NotifItem> _dummyNotifs = [
  NotifItem(type:'pact',        icon:'🤝', isRead:false,
    title:'Streak terancam putus!',
    body:'Ary Widnyana belum check-in hari ini. Streak 9 hari kalian akan hilang jam 23:59.',
    time:'10 menit lalu'),
  NotifItem(type:'reminder',    icon:'⏰', isRead:false,
    title:'Blok belajar dimulai',
    body:'Pemrograman Mobile — Implementasi Flutter widget dimulai 10 menit lagi.',
    time:'30 menit lalu'),
  NotifItem(type:'friend',      icon:'👋', isRead:false,
    title:'Permintaan pertemanan',
    body:'Dika Saputra ingin menjadi temanmu.',
    time:'1 jam lalu'),
  NotifItem(type:'achievement', icon:'🏆', isRead:true,
    title:'Badge baru terbuka!',
    body:'Kamu mendapat badge "7 Hari Streak" — konsistensi luar biasa!',
    time:'2 jam lalu'),
  NotifItem(type:'pact',        icon:'🔥', isRead:true,
    title:'Streak bertambah!',
    body:'Ary Widnyana sudah check-in. Streak kalian sekarang 9 hari!',
    time:'Kemarin'),
  NotifItem(type:'reminder',    icon:'⏰', isRead:true,
    title:'Jangan lupa belajar!',
    body:'Kamu belum menyelesaikan satu pun blok hari ini. Mulai sekarang yuk!',
    time:'Kemarin'),
  NotifItem(type:'system',      icon:'📢', isRead:true,
    title:'FocusBlock diperbarui',
    body:'Fitur Study Pact dan emoji reaction kini tersedia. Coba sekarang!',
    time:'3 hari lalu'),
  NotifItem(type:'friend',      icon:'🎉', isRead:true,
    title:'Sinta Maharani bergabung!',
    body:'Temanmu Sinta Maharani baru saja daftar di FocusBlock.',
    time:'5 hari lalu'),
];

class NotifScreen extends StatefulWidget {
  const NotifScreen({super.key});

  @override
  State<NotifScreen> createState() => _NotifScreenState();
}

class _NotifScreenState extends State<NotifScreen> {
  List<NotifItem> _notifs = List.from(_dummyNotifs);

  int get _unreadCount => _notifs.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            Text('Notifikasi', style: AppTypography.h3),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text('$_unreadCount baru',
                  style: AppTypography.label.copyWith(
                    color: AppColors.navy, fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() {
              _notifs = _notifs.map((n) => NotifItem(
                type: n.type, icon: n.icon, title: n.title,
                body: n.body, time: n.time, isRead: true)).toList();
            }),
            child: Text('Tandai semua dibaca',
              style: AppTypography.caption.copyWith(color: AppColors.teal)),
          ),
        ],
      ),
      body: _notifs.isEmpty
          ? _buildEmpty()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _notifs.length,
              itemBuilder: (_, i) => _NotifTile(
                item: _notifs[i],
                onTap: () => setState(() {
                  _notifs[i] = NotifItem(
                    type: _notifs[i].type, icon: _notifs[i].icon,
                    title: _notifs[i].title, body: _notifs[i].body,
                    time: _notifs[i].time, isRead: true);
                }),
                onDismiss: () => setState(() => _notifs.removeAt(i)),
              ),
            ),
    );
  }

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.notifications_none, size: 56, color: AppColors.textTertiary),
        const SizedBox(height: 16),
        Text('Tidak ada notifikasi', style: AppTypography.bodyMuted),
      ],
    ),
  );
}

class _NotifTile extends StatelessWidget {
  final NotifItem    item;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotifTile({
    required this.item,
    required this.onTap,
    required this.onDismiss,
  });

  Color get _typeColor => switch (item.type) {
    'pact'        => AppColors.teal,
    'reminder'    => AppColors.amber,
    'friend'      => AppColors.coral,
    'achievement' => const Color(0xFFAB8CFF),
    _             => AppColors.textSecondary,
  };

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('notif_${item.title}_${item.time}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.coralDim,
        child: const Icon(Icons.delete_outline, color: AppColors.coral),
      ),
      onDismissed: (_) => onDismiss(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: item.isRead ? AppColors.surface : AppColors.surface2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: item.isRead ? AppColors.border : _typeColor.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: _typeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(item.icon, style: const TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 12),

              // Konten
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(item.title,
                            style: AppTypography.h4.copyWith(
                              fontSize: 13,
                              color: item.isRead
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary)),
                        ),
                        if (!item.isRead)
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              color: _typeColor,
                              shape: BoxShape.circle),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(item.body,
                      style: AppTypography.caption.copyWith(
                        color: item.isRead
                            ? AppColors.textTertiary
                            : AppColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text(item.time,
                      style: AppTypography.caption.copyWith(
                        fontSize: 10, color: AppColors.textTertiary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
