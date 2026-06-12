import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/journal_model.dart';

class JournalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _journalsRef => _firestore.collection('journals');
  String get _uid => _auth.currentUser!.uid;

  // READ
  Stream<List<JournalEntry>> getJournals() {
    return _journalsRef
        .where('userId', isEqualTo: _uid)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((doc) => JournalEntry.fromDoc(doc))
              .toList();
          list.sort((a, b) => b.tanggal.compareTo(a.tanggal));
          return list;
        });
  }

  // CREATE
  Future<void> addJournal(JournalEntry entry, {File? screenshotFile}) async {
    // Convert foto ke Base64 kalau ada
    String? base64Screenshot;
    if (screenshotFile != null) {
      final bytes = await screenshotFile.readAsBytes();
      base64Screenshot = base64Encode(bytes);
    }

    final newEntry = JournalEntry(
      userId: _uid,
      saham: entry.saham,
      deskripsi: entry.deskripsi,
      hargaBeli: entry.hargaBeli,
      hargaJual: entry.hargaJual,
      lot: entry.lot,
      tanggal: entry.tanggal,
      result: entry.result,
      pnl: entry.pnl,
      pnlPercent: entry.pnlPercent,
      screenshotBase64: base64Screenshot,
      setup: entry.setup,
      emotion: entry.emotion,
      createdAt: DateTime.now(),
    );

    await _journalsRef.add(newEntry.toMap());
  }

  // UPDATE
  Future<void> updateJournal(String id, JournalEntry entry,
      {File? screenshotFile}) async {
    // Kalau ada foto baru, convert ke Base64
    // Kalau tidak ada foto baru, pakai yang lama
    String? base64Screenshot = entry.screenshotBase64;
    if (screenshotFile != null) {
      final bytes = await screenshotFile.readAsBytes();
      base64Screenshot = base64Encode(bytes);
    }

    final updatedEntry = JournalEntry(
      userId: _uid,
      saham: entry.saham,
      deskripsi: entry.deskripsi,
      hargaBeli: entry.hargaBeli,
      hargaJual: entry.hargaJual,
      lot: entry.lot,
      tanggal: entry.tanggal,
      result: entry.result,
      pnl: entry.pnl,
      pnlPercent: entry.pnlPercent,
      screenshotBase64: base64Screenshot,
      setup: entry.setup,
      emotion: entry.emotion,
      createdAt: entry.createdAt,
    );

    await _journalsRef.doc(id).update(updatedEntry.toMap());
  }

  // DELETE
  Future<void> deleteJournal(String id) async {
    await _journalsRef.doc(id).delete();
  }

  // STATS
  Future<Map<String, dynamic>> getStats() async {
    final snap =
        await _journalsRef.where('userId', isEqualTo: _uid).get();
    final entries =
        snap.docs.map((doc) => JournalEntry.fromDoc(doc)).toList();

    if (entries.isEmpty) {
      return {
        'totalTrade': 0,
        'totalProfit': 0.0,
        'winRate': 0.0,
        'totalWin': 0,
        'totalLoss': 0,
      };
    }

    final wins =
        entries.where((e) => e.result == TradeResult.profit).length;
    final totalPnl = entries.fold(0.0, (sum, e) => sum + e.pnl);

    return {
      'totalTrade': entries.length,
      'totalProfit': totalPnl,
      'winRate': (wins / entries.length) * 100,
      'totalWin': wins,
      'totalLoss':
          entries.where((e) => e.result == TradeResult.loss).length,
    };
  }
}
