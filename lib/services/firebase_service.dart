import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carbon_emission_app/models/history_item.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new history item
  Future<void> addHistoryItem(HistoryItem item) async {
    await _firestore.collection('history').add(item.toMap());
  }

  // Get all history items
  Stream<List<HistoryItem>> getHistoryItems() {
    return _firestore
        .collection('history')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => HistoryItem.fromFirestore(doc))
          .toList();
    });
  }

  // Delete a history item
  Future<void> deleteHistoryItem(String id) async {
    await _firestore.collection('history').doc(id).delete();
  }
} 