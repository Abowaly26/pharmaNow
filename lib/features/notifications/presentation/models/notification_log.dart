import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationLog {
  final String id;
  final Map<String, dynamic> payload;
  final bool read;
  final Timestamp timestamp;

  NotificationLog({
    required this.id,
    required this.payload,
    required this.read,
    required this.timestamp,
  });

  factory NotificationLog.fromMap(String id, Map<String, dynamic> map) {
    return NotificationLog(
      id: id,
      payload: Map<String, dynamic>.from(map['payload'] ?? {}),
      read: map['read'] as bool? ?? false,
      timestamp: map['timestamp'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'payload': payload,
      'read': read,
      'timestamp': timestamp,
    };
  }
}
