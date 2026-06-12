import 'package:cloud_firestore/cloud_firestore.dart';

enum TradeResult { profit, loss, breakeven }

class JournalEntry {
  final String? id;
  final String userId;
  final String saham;
  final String? deskripsi;
  final double hargaBeli;
  final double hargaJual;
  final int lot;
  final DateTime tanggal;
  final TradeResult result;
  final double pnl;
  final double pnlPercent;
  final String? screenshotBase64; // <-- simpan sebagai Base64
  final String? setup;
  final String? emotion;
  final DateTime createdAt;

  JournalEntry({
    this.id,
    required this.userId,
    required this.saham,
    this.deskripsi,
    required this.hargaBeli,
    required this.hargaJual,
    required this.lot,
    required this.tanggal,
    required this.result,
    required this.pnl,
    required this.pnlPercent,
    this.screenshotBase64,
    this.setup,
    this.emotion,
    required this.createdAt,
  });

  static double hitungPnL(double hargaBeli, double hargaJual, int lot) {
    return (hargaJual - hargaBeli) * lot * 100;
  }

  static double hitungPnLPercent(double hargaBeli, double hargaJual) {
    return ((hargaJual - hargaBeli) / hargaBeli) * 100;
  }

  static TradeResult tentukanResult(double pnl) {
    if (pnl > 0) return TradeResult.profit;
    if (pnl < 0) return TradeResult.loss;
    return TradeResult.breakeven;
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'saham': saham.toUpperCase(),
      'deskripsi': deskripsi,
      'hargaBeli': hargaBeli,
      'hargaJual': hargaJual,
      'lot': lot,
      'tanggal': Timestamp.fromDate(tanggal),
      'result': result.name,
      'pnl': pnl,
      'pnlPercent': pnlPercent,
      'screenshotBase64': screenshotBase64,
      'setup': setup,
      'emotion': emotion,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory JournalEntry.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JournalEntry(
      id: doc.id,
      userId: data['userId'] ?? '',
      saham: data['saham'] ?? '',
      deskripsi: data['deskripsi'],
      hargaBeli: (data['hargaBeli'] as num).toDouble(),
      hargaJual: (data['hargaJual'] as num).toDouble(),
      lot: data['lot'] ?? 1,
      tanggal: (data['tanggal'] as Timestamp).toDate(),
      result: TradeResult.values.firstWhere(
        (e) => e.name == data['result'],
        orElse: () => TradeResult.breakeven,
      ),
      pnl: (data['pnl'] as num).toDouble(),
      pnlPercent: (data['pnlPercent'] as num).toDouble(),
      screenshotBase64: data['screenshotBase64'],
      setup: data['setup'],
      emotion: data['emotion'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
