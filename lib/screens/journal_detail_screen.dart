import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/journal_model.dart';
import '../utils/app_theme.dart';
import 'input_journal_screen.dart';

class JournalDetailScreen extends StatelessWidget {
  final JournalEntry entry;

  const JournalDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final isProfit = entry.result == TradeResult.profit;
    final isLoss = entry.result == TradeResult.loss;
    final resultColor = isProfit
        ? AppTheme.profitGreen
        : isLoss
            ? AppTheme.lossRed
            : AppTheme.textSecondary;

    final currFmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(entry.saham,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: AppTheme.textPrimary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => InputJournalScreen(editEntry: entry)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HASIL TRADE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: resultColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: resultColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(
                    isProfit ? Icons.trending_up_rounded
                        : isLoss ? Icons.trending_down_rounded
                        : Icons.trending_flat_rounded,
                    color: resultColor, size: 36,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (entry.pnl >= 0 ? '+' : '') + currFmt.format(entry.pnl),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28, fontWeight: FontWeight.w800, color: resultColor),
                  ),
                  Text(
                    '${entry.pnlPercent >= 0 ? '+' : ''}${entry.pnlPercent.toStringAsFixed(2)}%',
                    style: GoogleFonts.plusJakartaSans(fontSize: 14, color: resultColor.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: resultColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(entry.result.name.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: resultColor, letterSpacing: 1)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // DETAIL GRID
            _sectionTitle('Detail Trade'),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                children: [
                  _detailRow('Kode Saham', entry.saham),
                  _divider(),
                  _detailRow('Harga Beli', currFmt.format(entry.hargaBeli)),
                  _divider(),
                  _detailRow('Harga Jual', currFmt.format(entry.hargaJual)),
                  _divider(),
                  _detailRow('Jumlah Lot', '${entry.lot} lot'),
                  _divider(),
                  _detailRow('Tanggal', DateFormat('dd MMMM yyyy').format(entry.tanggal)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // SETUP & EMOSI
            if (entry.setup != null || entry.emotion != null) ...[
              _sectionTitle('Setup & Psikologi'),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  children: [
                    if (entry.setup != null) ...[
                      _detailRow('Setup', entry.setup!),
                      if (entry.emotion != null) _divider(),
                    ],
                    if (entry.emotion != null) _detailRow('Emosi', entry.emotion!),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // CATATAN
            if (entry.deskripsi != null && entry.deskripsi!.isNotEmpty) ...[
              _sectionTitle('Catatan / Analisa'),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Text(entry.deskripsi!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, color: AppTheme.textPrimary, height: 1.6)),
              ),
              const SizedBox(height: 20),
            ],

            // SCREENSHOT - tampil dari Base64
            if (entry.screenshotBase64 != null) ...[
              _sectionTitle('Screenshot Chart'),
              const SizedBox(height: 10),
              GestureDetector(
                // Tap untuk fullscreen
                onTap: () => _showFullscreenImage(context, entry.screenshotBase64!),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.memory(
                    base64Decode(entry.screenshotBase64!),
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text('Tap foto untuk fullscreen',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, color: AppTheme.textSecondary)),
              ),
              const SizedBox(height: 20),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showFullscreenImage(BuildContext context, String base64) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              // Bisa zoom & pan
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.memory(
                base64Decode(base64),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary));
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary)),
          Text(value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }

  Widget _divider() => Container(
    height: 0.5, color: AppTheme.borderColor,
    margin: const EdgeInsets.symmetric(horizontal: 16));
}
