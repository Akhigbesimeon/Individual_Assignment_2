import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../models/swap_offer.dart';
import '../services/firestore_service.dart';
import '../models/book_listing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Auth Providers
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(FirebaseAuth.instance, FirebaseFirestore.instance);
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Firestore Service Provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService(FirebaseFirestore.instance);
});

// Data Stream Providers
final allListingsProvider = StreamProvider<List<BookListing>>((ref) {
  return ref.watch(firestoreServiceProvider).getAllListings();
});

final myListingsProvider = StreamProvider<List<BookListing>>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  if (user != null) {
    return ref.watch(firestoreServiceProvider).getMyListings(user.uid);
  }
  return Stream.value([]);
});

final receivedSwapsProvider = StreamProvider<List<SwapOffer>>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  if (user != null) {
    return ref.watch(firestoreServiceProvider).getReceivedSwaps(user.uid);
  }
  return Stream.value([]);
});

final sentSwapsProvider = StreamProvider<List<SwapOffer>>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  if (user != null) {
    return ref.watch(firestoreServiceProvider).getSentSwaps(user.uid);
  }
  return Stream.value([]);
});

final bookByIdProvider = StreamProvider.autoDispose
    .family<BookListing?, String>((ref, id) {
      return ref.watch(firestoreServiceProvider).getBookById(id);
    });

final userByIdProvider = StreamProvider.autoDispose.family<UserModel?, String>((
  ref,
  id,
) {
  return ref.watch(firestoreServiceProvider).getUserById(id);
});

// StreamProvider for all chat room
final chatListProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;

  if (user != null) {
    return ref.watch(firestoreServiceProvider).getChatList(user.uid);
  }
  return Stream.value([]);
});

// StreamProvider for the messages in chat room
final messagesProvider = StreamProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, chatId) {
      return ref.watch(firestoreServiceProvider).getMessages(chatId);
    });
