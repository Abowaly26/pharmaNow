import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pharma_now/core/services/database_service.dart';

/// Manages FCM token lifecycle: generation, refresh, storage and deletion.
class FCMTokenManager {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final DatabaseService _firestore;

  FCMTokenManager(this._firestore);

  /// Initialize token handling: request permission, store current token and
  /// listen for token refresh events.
  Future<void> init() async {
    debugPrint("[FCMTokenManager] Initializing...");
    // Request notification permissions (iOS & Android >= 13).
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint(
        "[FCMTokenManager] Permission status: ${settings.authorizationStatus}");

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await _storeCurrentToken();
    }
    // Listen for token refreshes.
    FirebaseMessaging.instance.onTokenRefresh.listen(_handleTokenRefresh);
  }

  /// Store the current FCM token for the logged‑in user.
  Future<void> _storeCurrentToken() async {
    final String? token = await _messaging.getToken();
    debugPrint("[FCMTokenManager] Current Token: $token");
    if (token != null) {
      await _storeToken(token);
    }
  }

  /// Called when Firebase issues a new token.
  Future<void> _handleTokenRefresh(String token) async {
    await _storeToken(token);
  }

  /// Persist a token document under `users/{uid}/fcmTokens/{token}`.
  /// Using the token string as the document ID enables multiple device support.
  Future<void> _storeToken(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _firestore.addData(
      path: 'users/$uid/fcmTokens',
      data: {
        'token': token,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'platform': Platform.isIOS ? 'ios' : 'android',
      },
      documentId: token,
    );
  }

  /// Delete the token belonging to the current device – typically called on logout.
  Future<void> deleteCurrentToken() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final String? token = await _messaging.getToken();
    if (token == null) return;
    await _firestore.deleteData(
      path: 'users/$uid/fcmTokens',
      documentId: token,
    );
  }

  /// Delete **all** tokens for the user – used when the account is removed.
  Future<void> deleteAllTokens() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final tokens = await _firestore.getData(path: 'users/$uid/fcmTokens');
    if (tokens is List) {
      for (var tokenDoc in tokens) {
        final tokenId = tokenDoc['token'] ?? tokenDoc['id'];
        if (tokenId != null) {
          await _firestore.deleteData(
            path: 'users/$uid/fcmTokens',
            documentId: tokenId,
          );
        }
      }
    }
  }
}
