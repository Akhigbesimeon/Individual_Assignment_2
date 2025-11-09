import '../models/book_listing.dart';
import '../models/user_model.dart';
import '../models/swap_offer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db;
  FirestoreService(this._db);

  CollectionReference get _listingsRef => _db.collection('bookListings');
  CollectionReference get _swapsRef => _db.collection('swaps');
  CollectionReference get _usersRef => _db.collection('users');
  CollectionReference get _chatsRef => _db.collection('chats');

  // book CRUD operations
  Stream<List<BookListing>> getAllListings() {
    return _listingsRef
        .where('status', whereIn: ['available', 'swapped'])
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map(
                (doc) =>
                    BookListing.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Stream<List<BookListing>> getMyListings(String uid) {
    return _listingsRef.where('ownerUid', isEqualTo: uid).snapshots().map((
      snapshot,
    ) {
      final list = snapshot.docs
          .map((doc) => BookListing.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> postBook(BookListing book) async {
    try {
      await _listingsRef.doc(book.listingId).set(book.toMap());
    } catch (e) {
      print('Error posting book: $e');
      rethrow;
    }
  }

  Future<void> updateBook(BookListing book) async {
    try {
      await _listingsRef.doc(book.listingId).update({
        'title': book.title,
        'author': book.author,
        'condition': book.condition.toDisplayString(),
        'coverImageUrl': book.coverImageUrl,
      });
    } catch (e) {
      print('Error updating book: $e');
      rethrow;
    }
  }

  Future<void> deleteBook(BookListing book) async {
    try {
      await _listingsRef.doc(book.listingId).delete();

      final swaps = await _swapsRef
          .where('listingId', isEqualTo: book.listingId)
          .get();

      WriteBatch batch = _db.batch();
      for (final doc in swaps.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print('Error deleting book: $e');
      rethrow;
    }
  }

  // swap operations
  Future<void> requestSwap(SwapOffer offer) async {
    try {
      WriteBatch batch = _db.batch();
      batch.set(_swapsRef.doc(offer.swapId), offer.toMap());
      batch.update(_listingsRef.doc(offer.listingId), {'status': 'pending'});
      await batch.commit();
    } catch (e) {
      print('Error requesting swap: $e');
      rethrow;
    }
  }

  Future<void> manageSwap(SwapOffer offer, bool accept) async {
    try {
      WriteBatch batch = _db.batch();

      batch.update(_swapsRef.doc(offer.swapId), {
        'status': accept ? 'accepted' : 'rejected',
      });
      batch.update(_listingsRef.doc(offer.listingId), {
        'status': accept ? 'swapped' : 'available',
      });

      if (accept) {
        final chatDoc = _chatsRef.doc(offer.swapId);
        batch.set(chatDoc, {
          'chatId': offer.swapId,
          'listingId': offer.listingId,
          'participantUids': [offer.listingOwnerUid, offer.requesterUid],
          'lastMessage': 'Swap accepted! You can now chat.',
          'lastMessageTimestamp': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      print('Error managing swap: $e');
      rethrow;
    }
  }

  // swap stream providers
  Stream<List<SwapOffer>> getReceivedSwaps(String uid) {
    return _swapsRef.where('listingOwnerUid', isEqualTo: uid).snapshots().map((
      snapshot,
    ) {
      final list = snapshot.docs
          .map((doc) => SwapOffer.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      return list.where((swap) => swap.status == SwapStatus.pending).toList();
    });
  }

  Stream<List<SwapOffer>> getSentSwaps(String uid) {
    return _swapsRef.where('requesterUid', isEqualTo: uid).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => SwapOffer.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Stream<BookListing?> getBookById(String listingId) {
    return _listingsRef.doc(listingId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return BookListing.fromMap(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  Stream<UserModel?> getUserById(String uid) {
    return _usersRef.doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  Stream<List<Map<String, dynamic>>> getChatList(String uid) {
    return _chatsRef
        .where('participantUids', arrayContains: uid)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          list.sort((a, b) {
            final aTimestamp =
                a['lastMessageTimestamp'] as Timestamp? ?? Timestamp(0, 0);
            final bTimestamp =
                b['lastMessageTimestamp'] as Timestamp? ?? Timestamp(0, 0);
            return bTimestamp.compareTo(aTimestamp);
          });
          return list;
        });
  }

  Stream<List<Map<String, dynamic>>> getMessages(String chatId) {
    return _chatsRef
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
  }

  // Send a new message
  Future<void> sendMessage(String chatId, String text, String senderUid) async {
    try {
      final messageId = _chatsRef.doc().id;
      final messageData = {
        'messageId': messageId,
        'text': text,
        'senderUid': senderUid,
        'timestamp': FieldValue.serverTimestamp(),
      };

      WriteBatch batch = _db.batch();

      final messageRef = _chatsRef
          .doc(chatId)
          .collection('messages')
          .doc(messageId);
      batch.set(messageRef, messageData);

      final chatRef = _chatsRef.doc(chatId);
      batch.update(chatRef, {
        'lastMessage': text,
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }
}
