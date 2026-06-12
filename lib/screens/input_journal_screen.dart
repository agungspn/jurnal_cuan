import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/journal_model.dart';
import '../services/journal_service.dart';
import '../utils/app_theme.dart';

class InputJournalScreen extends StatefulWidget {
  final JournalEntry? editEntry;

  const InputJournalScreen({super.key, this.editEntry});

  @override
  State<InputJournalScreen> createState() => _InputJournalScreenState();
}

class _InputJournalScreenState extends State<InputJournalScreen> {
  final JournalService _service = JournalService();
  final _formKey = GlobalKey<FormState>();

  final _sahamCtrl = TextEditingController();
  final _hargaBeliCtrl = TextEditingController();
  final _hargaJualCtrl = TextEditingController();
  final _lotCtrl = TextEditingController(text: '1');
  final _deskripsiCtrl = TextEditingController();

  DateTime _tanggal = DateTime.now();
  String? _selectedSetup;
  String? _selectedEmotion;
  File? _screenshotFile; // file baru yang dipilih
  bool _isLoading = false;

  double _pnlPreview = 0;
  double _pnlPercentPreview = 0;

  final List<String> _setupOptions = [
    'Breakout', 'Pullback', 'Reversal', 'Momentum',
    'Support/Resistance', 'Gap Up/Down', 'Lainnya',
  ];

  final List<String> _emotionOptions = [
    '😌 Tenang & Disiplin', '😤 FOMO', '😰 Panik',
    '🤑 Greedy', '😕 Ragu-ragu', '💪 Percaya Diri',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.editEntry != null) {
      final e = widget.editEntry!;
      _sahamCtrl.text = e.saham;
      _hargaBeliCtrl.text = e.hargaBeli.toString();
      _hargaJualCtrl.text = e.hargaJual.toString();
      _lotCtrl.text = e.lot.toString();
      _deskripsiCtrl.text = e.deskripsi ?? '';
      _tanggal = e.tanggal;
      _selectedSetup = e.setup;
      _selectedEmotion = e.emotion;
    }

    _hargaBeliCtrl.addListener(_hitungPnL);
    _hargaJualCtrl.addListener(_hitungPnL);
    _lotCtrl.addListener(_hitungPnL);
  }

  void _hitungPnL() {
    final beli = double.tryParse(_hargaBeliCtrl.text) ?? 0;
    final jual = double.tryParse(_hargaJualCtrl.text) ?? 0;
    final lot = int.tryParse(_lotCtrl.text) ?? 0;
    if (beli > 0 && jual > 0 && lot > 0) {
      setState(() {
        _pnlPreview = JournalEntry.hitungPnL(beli, jual, lot);
        _pnlPercentPreview = JournalEntry.hitungPnLPercent(beli, jual);
      });
    }
  }

  Future<void> _pickScreenshot() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // compress supaya Base64 tidak terlalu besar
    );
    if (picked != null) {
      setState(() => _screenshotFile = File(picked.path));
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
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
    if (picked != null) setState(() => _tanggal = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final beli = double.parse(_hargaBeliCtrl.text);
    final jual = double.parse(_hargaJualCtrl.text);
    final lot = int.parse(_lotCtrl.text);
    final pnl = JournalEntry.hitungPnL(beli, jual, lot);
    final pnlPercent = JournalEntry.hitungPnLPercent(beli, jual);

    final entry = JournalEntry(
      userId: '',
      saham: _sahamCtrl.text.toUpperCase(),
      deskripsi: _deskripsiCtrl.text.isEmpty ? null : _deskripsiCtrl.text,
      hargaBeli: beli,
      hargaJual: jual,
      lot: lot,
      tanggal: _tanggal,
      result: JournalEntry.tentukanResult(pnl),
      pnl: pnl,
      pnlPercent: pnlPercent,
      // Kalau edit dan tidak ganti foto, pakai Base64 yang lama
      screenshotBase64: widget.editEntry?.screenshotBase64,
      setup: _selectedSetup,
      emotion: _selectedEmotion,
      createdAt: DateTime.now(),
    );

    setState(() => _isLoading = true);

    try {
      if (widget.editEntry?.id != null) {
        await _service.updateJournal(
          widget.editEntry!.id!,
          entry,
          screenshotFile: _screenshotFile,
        );
      } else {
        await _service.addJournal(entry, screenshotFile: _screenshotFile);
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Jurnal berhasil disimpan!'),
          backgroundColor: AppTheme.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal simpan: $e'),
          backgroundColor: AppTheme.lossRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _sahamCtrl.dispose();
    _hargaBeliCtrl.dispose();
    _hargaJualCtrl.dispose();
    _lotCtrl.dispose();
    _deskripsiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPnlPositive = _pnlPreview >= 0;
    final currFmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    // Tampilkan foto: kalau ada file baru pakai File, kalau edit pakai Base64 lama
    final hasExistingScreenshot = widget.editEntry?.screenshotBase64 != null;
    final hasAnyScreenshot = _screenshotFile != null || hasExistingScreenshot;

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
        ),
        title: Text(
          widget.editEntry != null ? 'Edit Trade' : 'Tambah Trade',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PNL PREVIEW
              if (_pnlPreview != 0)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: (isPnlPositive ? AppTheme.profitGreen : AppTheme.lossRed).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: (isPnlPositive ? AppTheme.profitGreen : AppTheme.lossRed).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isPnlPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                        color: isPnlPositive ? AppTheme.profitGreen : AppTheme.lossRed,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Estimasi PnL',
                              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary)),
                          Text(
                            '${isPnlPositive ? '+' : ''}${currFmt.format(_pnlPreview)} (${_pnlPercentPreview.toStringAsFixed(2)}%)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isPnlPositive ? AppTheme.profitGreen : AppTheme.lossRed,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // KODE SAHAM
              _sectionLabel('Kode Saham / Pair'),
              TextFormField(
                controller: _sahamCtrl,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(hintText: 'Contoh: BBCA, GOTO, XAUUSD'),
                validator: (v) => v == null || v.isEmpty ? 'Kode saham wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // HARGA BELI & JUAL
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel('Harga Beli'),
                        TextFormField(
                          controller: _hargaBeliCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                          style: const TextStyle(color: AppTheme.textPrimary),
                          decoration: const InputDecoration(hintText: '0'),
                          validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel('Harga Jual'),
                        TextFormField(
                          controller: _hargaJualCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                          style: const TextStyle(color: AppTheme.textPrimary),
                          decoration: const InputDecoration(hintText: '0'),
                          validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // LOT & TANGGAL
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel('Jumlah Lot'),
                        TextFormField(
                          controller: _lotCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          style: const TextStyle(color: AppTheme.textPrimary),
                          decoration: const InputDecoration(hintText: '1'),
                          validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel('Tanggal'),
                        GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                            decoration: BoxDecoration(
                              color: AppTheme.cardDark,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.borderColor),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.textSecondary),
                                const SizedBox(width: 8),
                                Text(DateFormat('dd/MM/yy').format(_tanggal),
                                    style: const TextStyle(color: AppTheme.textPrimary)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // SETUP
              _sectionLabel('Setup Trading (Opsional)'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _setupOptions.map((s) => GestureDetector(
                  onTap: () => setState(() => _selectedSetup = _selectedSetup == s ? null : s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedSetup == s ? AppTheme.primaryGreen.withOpacity(0.2) : AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _selectedSetup == s ? AppTheme.primaryGreen : AppTheme.borderColor),
                    ),
                    child: Text(s,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: _selectedSetup == s ? AppTheme.primaryGreen : AppTheme.textSecondary,
                        fontWeight: _selectedSetup == s ? FontWeight.w600 : FontWeight.w400,
                      )),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),

              // EMOSI
              _sectionLabel('Emosi Saat Trading (Opsional)'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _emotionOptions.map((e) => GestureDetector(
                  onTap: () => setState(() => _selectedEmotion = _selectedEmotion == e ? null : e),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedEmotion == e ? AppTheme.accentGold.withOpacity(0.15) : AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _selectedEmotion == e ? AppTheme.accentGold : AppTheme.borderColor),
                    ),
                    child: Text(e,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: _selectedEmotion == e ? AppTheme.accentGold : AppTheme.textSecondary,
                      )),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),

              // DESKRIPSI
              _sectionLabel('Catatan / Analisa (Opsional)'),
              TextFormField(
                controller: _deskripsiCtrl,
                maxLines: 3,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Kenapa masuk? Apa yang salah? Pelajaran apa yang didapat?',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),

              // SCREENSHOT
              _sectionLabel('Screenshot Chart (Opsional)'),
              GestureDetector(
                onTap: _pickScreenshot,
                child: Container(
                  width: double.infinity,
                  height: hasAnyScreenshot ? null : 100,
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: hasAnyScreenshot ? AppTheme.primaryGreen : AppTheme.borderColor,
                    ),
                  ),
                  child: hasAnyScreenshot
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: _screenshotFile != null
                                  // File baru yang baru dipilih
                                  ? Image.file(_screenshotFile!, width: double.infinity, fit: BoxFit.cover)
                                  // Base64 dari Firestore (saat edit)
                                  : Image.memory(
                                      Uri.parse('data:image/jpeg;base64,${widget.editEntry!.screenshotBase64}')
                                          .data!.contentAsBytes(),
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            // Overlay "Ganti Foto"
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.edit, color: Colors.white, size: 14),
                                    const SizedBox(width: 4),
                                    Text('Ganti Foto',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11, color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_photo_alternate_outlined, color: AppTheme.textSecondary, size: 28),
                            const SizedBox(height: 6),
                            Text('Tap untuk upload screenshot',
                              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 32),

              // SAVE BUTTON
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.primaryDark),
                      )
                    : Text(widget.editEntry != null ? 'Simpan Perubahan' : 'Simpan Trade'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
    );
  }
}
