import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/journal_model.dart';

class JournalService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get _col =>
      _db.collection('users').doc(_uid).collection('journals');

  Future<void> addJournal(JournalEntry entry, {File? screenshotFile}) async {
    final data = entry.toMap();
    data['userId'] = _uid;
    // screenshotFile diabaikan dulu
    await _col.add(data);
  }

  Future<void> updateJournal(String docId, JournalEntry entry, {File? screenshotFile}) async {
    await _col.doc(docId).update(entry.toMap());
  }

  Future<void> deleteJournal(String docId) async {
    await _col.doc(docId).delete();
  }

  Stream<List<JournalEntry>> getJournals() {
    return _col
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => JournalEntry.fromDoc(d))
            .toList());
  }
}