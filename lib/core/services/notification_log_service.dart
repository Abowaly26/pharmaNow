import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pharma_now/core/services/database_service.dart';
import 'package:pharma_now/features/notifications/presentation/models/notification_payload.dart';
import 'package:pharma_now/features/notifications/presentation/models/notification_log.dart';

class NotificationLogService {
  final DatabaseService _databaseService;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  NotificationLogService(this._databaseService);

  String? get _uid => _auth.currentUser?.uid;

  /// Add a new notification log to Firestore.
  Future<void> addLog(NotificationPayload payload,
      {String? notificationId}) async {
    if (_uid == null) return;

    await _databaseService.addData(
      path: 'users/$_uid/notifications',
      data: {
        'payload': payload.toMap(),
        'read': false,
        'timestamp': FieldValue.serverTimestamp(),
      },
      documentId: notificationId,
    );
  }

  /// Fetch all notification logs for the current user.
  Future<List<NotificationLog>> getLogs() async {
    if (_uid == null) return [];

    final List<dynamic> data = await _databaseService.getData(
      path: 'users/$_uid/notifications',
      query: {
        'orderBy': 'timestamp',
        'descending': true,
      },
    );

    return data.map((e) => NotificationLog.fromMap(e['id'] ?? '', e)).toList();
  }

  /// Mark a specific notification as read.
  Future<void> markAsRead(String notificationId) async {
    if (_uid == null || notificationId.isEmpty) return;

    await _databaseService.addData(
      path: 'users/$_uid/notifications',
      data: {'read': true},
      documentId: notificationId,
    );
  }

  /// Mark all notifications as read.
  Future<void> markAllAsRead() async {
    if (_uid == null) return;

    final collection =
        FirebaseFirestore.instance.collection('users/$_uid/notifications');
    final unread = await collection.where('read', isEqualTo: false).get();
    if (unread.docs.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    for (final doc in unread.docs) {
      batch.set(doc.reference, {'read': true}, SetOptions(merge: true));
    }
    await batch.commit();
  }

  /// Delete a specific notification.
  Future<void> deleteNotification(String notificationId) async {
    if (_uid == null || notificationId.isEmpty) return;

    await _databaseService.deleteData(
      path: 'users/$_uid/notifications',
      documentId: notificationId,
    );
  }

  /// Clear all notifications for the user.
  Future<void> clearAll() async {
    if (_uid == null) return;

    final collection =
        FirebaseFirestore.instance.collection('users/$_uid/notifications');
    final snapshot = await collection.get();
    if (snapshot.docs.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
