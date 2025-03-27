import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryItem {
  final String id;
  final String type;
  final double value;
  final String unit;
  final String country;
  final double co2eGm;
  final double co2eLb;
  final double co2eKg;
  final double co2eMt;
  final DateTime timestamp;

  HistoryItem({
    required this.id,
    required this.type,
    required this.value,
    required this.unit,
    required this.country,
    required this.co2eGm,
    required this.co2eLb,
    required this.co2eKg,
    required this.co2eMt,
    required this.timestamp,
  });

  factory HistoryItem.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return HistoryItem(
      id: doc.id,
      type: data['type'] ?? '',
      value: (data['value'] ?? 0.0).toDouble(),
      unit: data['unit'] ?? '',
      country: data['country'] ?? '',
      co2eGm: (data['co2eGm'] ?? 0.0).toDouble(),
      co2eLb: (data['co2eLb'] ?? 0.0).toDouble(),
      co2eKg: (data['co2eKg'] ?? 0.0).toDouble(),
      co2eMt: (data['co2eMt'] ?? 0.0).toDouble(),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'value': value,
      'unit': unit,
      'country': country,
      'co2eGm': co2eGm,
      'co2eLb': co2eLb,
      'co2eKg': co2eKg,
      'co2eMt': co2eMt,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
} 