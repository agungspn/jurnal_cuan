import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/journal_model.dart';
import '../services/journal_service.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import 'login_screen.dart';
import 'input_journal_screen.dart';
import 'alarm_screen.dart';
import 'chart_screen.dart';
import 'journal_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _BerandaPage(),
          AlarmScreen(),
          ChartScreen(),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InputJournalScreen()),
              ),
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: AppTheme.primaryDark,
              child: const Icon(Icons.add_rounded, size: 28),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surfaceDark,
          border: Border(
            top: BorderSide(color: AppTheme.borderColor, width: 0.5),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.book_rounded,
                  label: 'Jurnal',
                  selected: _selectedIndex == 0,
                  onTap: () => setState(() => _selectedIndex = 0),
                ),
                _NavItem(
                  icon: Icons.notifications_rounded,
                  label: 'Alarm',
                  selected: _selectedIndex == 1,
                  onTap: () => setState(() => _selectedIndex = 1),
                ),
                _NavItem(
                  icon: Icons.candlestick_chart_rounded,
                  label: 'Chart',
                  selected: _selectedIndex == 2,
                  onTap: () => setState(() => _selectedIndex = 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================
// NAV ITEM
// ============================
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? AppTheme.primaryGreen : AppTheme.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? AppTheme.primaryGreen : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================
// BERANDA PAGE
// ============================
class _BerandaPage extends StatefulWidget {
  const _BerandaPage();

  @override
  State<_BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<_BerandaPage> {
  final JournalService _journalService = JournalService();
  final AuthService _authService = AuthService();
  String _filterPeriod = 'Today';

  final _currencyFmt = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  Stream<List<JournalEntry>> _getFilteredJournals() {
    return _journalService.getJournals().map((list) {
      final now = DateTime.now();
      return list.where((e) {
        switch (_filterPeriod) {
          case 'Today':
            return e.tanggal.year == now.year &&
                e.tanggal.month == now.month &&
                e.tanggal.day == now.day;
          case 'Yesterday':
            final yesterday = now.subtract(const Duration(days: 1));
            return e.tanggal.year == yesterday.year &&
                e.tanggal.month == yesterday.month &&
                e.tanggal.day == yesterday.day;
          case 'This week':
            final startOfWeek =
                now.subtract(Duration(days: now.weekday - 1));
            final startMidnight = DateTime(
                startOfWeek.year, startOfWeek.month, startOfWeek.day);
            return !e.tanggal.isBefore(startMidnight);
          case 'Last week':
            final startOfLastWeek =
                now.subtract(Duration(days: now.weekday + 6));
            final endOfLastWeek =
                now.subtract(Duration(days: now.weekday - 1));
            return e.tanggal.isAfter(DateTime(startOfLastWeek.year,
                    startOfLastWeek.month, startOfLastWeek.day)) &&
                e.tanggal.isBefore(DateTime(endOfLastWeek.year,
                    endOfLastWeek.month, endOfLastWeek.day));
          default:
            return true;
        }
      }).toList();
    });
  }

  Future<void> _showLogoutMenu() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout?',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text('Yakin mau keluar?',
            style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout',
                style: TextStyle(color: AppTheme.lossRed)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _authService.logout();
      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Jurnal\nAnda',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      height: 1.1,
                    ),
                  ),
                  GestureDetector(
                    onTap: _showLogoutMenu,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: AppTheme.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: ['Today', 'Yesterday', 'This week', 'Last week']
                    .map((period) => GestureDetector(
                          onTap: () =>
                              setState(() => _filterPeriod = period),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _filterPeriod == period
                                  ? AppTheme.primaryGreen
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _filterPeriod == period
                                    ? AppTheme.primaryGreen
                                    : AppTheme.borderColor,
                              ),
                            ),
                            child: Text(
                              period,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _filterPeriod == period
                                    ? AppTheme.primaryDark
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: StreamBuilder<List<JournalEntry>>(
                stream: _getFilteredJournals(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.primaryGreen),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'Belum ada data trading.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    );
                  }
                  final journals = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: journals.length,
                    itemBuilder: (_, i) => _JournalCard(
                      entry: journals[i],
                      currencyFmt: _currencyFmt,
                      onDelete: () =>
                          _journalService.deleteJournal(journals[i].id!),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================
// JOURNAL CARD
// ============================
class _JournalCard extends StatelessWidget {
  final JournalEntry entry;
  final NumberFormat currencyFmt;
  final VoidCallback onDelete;

  const _JournalCard({
    required this.entry,
    required this.currencyFmt,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isProfit = entry.result == TradeResult.profit;
    final isLoss = entry.result == TradeResult.loss;
    final resultColor = isProfit
        ? AppTheme.profitGreen
        : isLoss
            ? AppTheme.lossRed
            : AppTheme.textSecondary;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => JournalDetailScreen(entry: entry),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: resultColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isProfit
                    ? Icons.trending_up_rounded
                    : isLoss
                        ? Icons.trending_down_rounded
                        : Icons.trending_flat_rounded,
                color: resultColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        entry.saham,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: resultColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          entry.result.name.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: resultColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${entry.lot} lot · ${DateFormat('dd MMM yyyy').format(entry.tanggal)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  (entry.pnl >= 0 ? '+' : '') + currencyFmt.format(entry.pnl),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: resultColor,
                  ),
                ),
                Text(
                  '${entry.pnlPercent >= 0 ? '+' : ''}${entry.pnlPercent.toStringAsFixed(2)}%',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: resultColor.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(Icons.delete_outline_rounded,
                      size: 18, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}