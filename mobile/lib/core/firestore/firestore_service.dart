import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_repository.dart';

/// Central Firestore service for ProofBuy AI.
///
/// All user accounts, orders, and transaction history are stored here
/// in the default Firestore database.
class FirestoreService {
  FirestoreService._();
  static final FirestoreService _instance = FirestoreService._();
  factory FirestoreService() => _instance;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Collection references ──────────────────────────────────────────────
  CollectionReference get _users => _db.collection('users');
  CollectionReference get _orders => _db.collection('orders');
  CollectionReference get _transactions => _db.collection('transactions');
  CollectionReference get _sessions => _db.collection('shopping_sessions');

  // ── Users ─────────────────────────────────────────────────────────────

  /// Create or update a user profile in Firestore.
  Future<void> saveUser(AuthUser user) async {
    await _users.doc(user.userId).set({
      'userId': user.userId,
      'fullName': user.fullName,
      'email': user.email,
      'accessToken': user.accessToken,
      'country': user.country,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Get a user profile by ID.
  Future<AuthUser?> getUser(String userId) async {
    try {
      final doc = await _users.doc(userId).get();
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>;
      return AuthUser(
        userId: data['userId'] as String? ?? '',
        fullName: data['fullName'] as String? ?? 'User',
        email: data['email'] as String? ?? '',
        accessToken: data['accessToken'] as String? ?? '',
        country: data['country'] as String?,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FirestoreService] getUser error: $e');
      }
      return null;
    }
  }

  /// Get a user profile by email.
  Future<AuthUser?> getUserByEmail(String email) async {
    try {
      final query = await _users
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (query.docs.isEmpty) return null;
      final data = query.docs.first.data() as Map<String, dynamic>;
      return AuthUser(
        userId: data['userId'] as String? ?? '',
        fullName: data['fullName'] as String? ?? 'User',
        email: data['email'] as String? ?? '',
        accessToken: data['accessToken'] as String? ?? '',
        country: data['country'] as String?,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FirestoreService] getUserByEmail error: $e');
      }
      return null;
    }
  }

  // ── Orders ────────────────────────────────────────────────────────────

  /// Save a completed order to Firestore.
  Future<void> saveOrder({
    required String orderId,
    required String userId,
    required String productResultId,
    required String productName,
    required double amount,
    required String currency,
    required String status,
    required String paypalOrderId,
    required String? captureId,
    required bool verified,
  }) async {
    await _orders.doc(orderId).set({
      'orderId': orderId,
      'userId': userId,
      'productResultId': productResultId,
      'productName': productName,
      'amount': amount,
      'currency': currency,
      'status': status,
      'paypalOrderId': paypalOrderId,
      'captureId': captureId,
      'verified': verified,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Get all orders for a user.
  Future<List<Map<String, dynamic>>> getOrdersForUser(String userId) async {
    try {
      final query = await _orders
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return query.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FirestoreService] getOrdersForUser error: $e');
      }
      return [];
    }
  }

  // ── Transactions ─────────────────────────────────────────────────────

  /// Save a transaction record to Firestore.
  Future<void> saveTransaction({
    required String transactionId,
    required String purchaseId,
    required String paypalCaptureId,
    required String status,
    required bool verified,
    required DateTime? verifiedAt,
    required Map<String, dynamic> rawCaptureJson,
  }) async {
    await _transactions.doc(transactionId).set({
      'transactionId': transactionId,
      'purchaseId': purchaseId,
      'paypalCaptureId': paypalCaptureId,
      'status': status,
      'verified': verified,
      'verifiedAt': verifiedAt != null
          ? Timestamp.fromDate(verifiedAt)
          : null,
      'rawCaptureJson': rawCaptureJson,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ── Shopping Sessions ────────────────────────────────────────────────

  /// Save a shopping session to Firestore.
  Future<void> saveShoppingSession({
    required String sessionId,
    required String briefText,
    required Map<String, dynamic> requirementsJson,
    required String status,
  }) async {
    await _sessions.doc(sessionId).set({
      'sessionId': sessionId,
      'briefText': briefText,
      'requirementsJson': requirementsJson,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Initialize Firestore settings (persistence enabled).
  Future<void> init() async {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
  }
}

final firestoreServiceProvider = Provider<FirestoreService>((_) => FirestoreService());
