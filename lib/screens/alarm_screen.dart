import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../models/alarm_model.dart';       // ✅ TAMBAHAN
import '../services/alarm_service.dart';   // ✅ TAMBAHAN

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  final AlarmService _alarmService = AlarmService();
  List<AlarmModel> _alarms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  // ──────────────────────────────────────────────
  // LOAD ALARM DARI STORAGE
  // ──────────────────────────────────────────────

  Future<void> _loadAlarms() async {
    final alarms = await _alarmService.loadAlarms();
    setState(() {
      _alarms = alarms;
      _isLoading = false;
    });
  }

  // ──────────────────────────────────────────────
  // TAMBAH ALARM
  // ──────────────────────────────────────────────

  Future<void> _addAlarm() async {
    final labelCtrl = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tambah Pengingat',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: labelCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Nama pengingat (contoh: Sesi London)',
                  hintStyle: const TextStyle(color: AppTheme.textSecondary),
                  filled: true,
                  fillColor: AppTheme.surfaceDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryGreen),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: ctx,
                    initialTime: selectedTime,
                    builder: (_, child) => Theme(
                      data: ThemeData.dark().copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: AppTheme.primaryGreen,
                          surface: AppTheme.cardDark,
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) {
                    setModalState(() => selectedTime = picked);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          color: AppTheme.primaryGreen, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        selectedTime.format(ctx),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (labelCtrl.text.isNotEmpty) {
                    final newAlarm = AlarmModel(
                      id: _alarmService.generateId(),
                      title: labelCtrl.text.trim(),
                      hour: selectedTime.hour,
                      minute: selectedTime.minute,
                      isEnabled: true,
                    );

                    // Schedule notifikasi
                    await _alarmService.scheduleAlarm(newAlarm);

                    // Simpan ke state & storage
                    setState(() => _alarms.add(newAlarm));
                    await _alarmService.saveAlarms(_alarms);

                    if (ctx.mounted) Navigator.pop(ctx);

                    // Feedback ke user
                    if (mounted) {
                      _showSnackbar(
                        '✅ Pengingat "${newAlarm.title}" aktif — '
                        '${newAlarm.hour.toString().padLeft(2, '0')}:'
                        '${newAlarm.minute.toString().padLeft(2, '0')} setiap hari',
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: AppTheme.primaryDark,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  'Simpan Pengingat',
                  style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // TOGGLE ON/OFF
  // ──────────────────────────────────────────────

  Future<void> _toggleAlarm(int index, bool value) async {
    final alarm = _alarms[index];
    final updated = alarm.copyWith(isEnabled: value);

    setState(() => _alarms[index] = updated);

    if (value) {
      // Aktifkan — jadwalkan notifikasi
      await _alarmService.scheduleAlarm(updated);
      _showSnackbar(
        '🔔 "${updated.title}" diaktifkan — '
        '${updated.hour.toString().padLeft(2, '0')}:'
        '${updated.minute.toString().padLeft(2, '0')} setiap hari',
      );
    } else {
      // Nonaktifkan — batalkan notifikasi
      await _alarmService.cancelAlarm(updated.id);
      _showSnackbar('🔕 "${updated.title}" dinonaktifkan');
    }

    await _alarmService.saveAlarms(_alarms);
  }

  // ──────────────────────────────────────────────
  // HAPUS ALARM
  // ──────────────────────────────────────────────

  Future<void> _deleteAlarm(int index) async {
    final alarm = _alarms[index];

    // Batalkan notifikasi terlebih dahulu
    await _alarmService.cancelAlarm(alarm.id);

    setState(() => _alarms.removeAt(index));
    await _alarmService.saveAlarms(_alarms);

    _showSnackbar('🗑️ "${alarm.title}" dihapus');
  }

  // ──────────────────────────────────────────────
  // HELPER UI
  // ──────────────────────────────────────────────

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(fontSize: 13),
        ),
        backgroundColor: AppTheme.cardDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // BUILD — SAMA PERSIS DENGAN UI LAMA
  // ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment(0, -0.2),
          colors: [Color(0xFF0D3B2E), AppTheme.primaryDark],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header — tidak diubah
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pengingat\nTrading',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      height: 1.1,
                    ),
                  ),
                  GestureDetector(
                    onTap: _addAlarm,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppTheme.primaryGreen.withOpacity(0.4)),
                      ),
                      child: const Icon(Icons.add_rounded,
                          color: AppTheme.primaryGreen, size: 22),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Atur jadwal untuk disiplin trading kamu',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryGreen,
                      ),
                    )
                  : _alarms.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.notifications_off_outlined,
                                  size: 60,
                                  color: AppTheme.textSecondary.withOpacity(0.4)),
                              const SizedBox(height: 16),
                              Text(
                                'Belum ada pengingat',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                          itemCount: _alarms.length,
                          itemBuilder: (_, i) => _AlarmCard(
                            alarm: _alarms[i],
                            onToggle: (val) => _toggleAlarm(i, val),
                            onDelete: () => _deleteAlarm(i),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// _AlarmCard — Tidak ada perubahan visual, hanya tipe data diganti ke AlarmModel
// ──────────────────────────────────────────────────────────────────────────────

class _AlarmCard extends StatelessWidget {
  final AlarmModel alarm;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const _AlarmCard({
    required this.alarm,
    required this.onToggle,
    required this.onDelete,
  });

  String _formatTime(int hour, int minute) {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: alarm.isEnabled
              ? AppTheme.primaryGreen.withOpacity(0.3)
              : AppTheme.borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: alarm.isEnabled
                  ? AppTheme.primaryGreen.withOpacity(0.12)
                  : AppTheme.borderColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.notifications_rounded,
              color: alarm.isEnabled
                  ? AppTheme.primaryGreen
                  : AppTheme.textSecondary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alarm.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: alarm.isEnabled
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTime(alarm.hour, alarm.minute),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: alarm.isEnabled
                        ? AppTheme.primaryGreen
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Switch(
                value: alarm.isEnabled,
                onChanged: onToggle,
                activeColor: AppTheme.primaryGreen,
              ),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.delete_outline_rounded,
                    size: 18, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}