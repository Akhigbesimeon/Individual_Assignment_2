import 'package:cloud_firestore/cloud_firestore.dart';

// BookCondition
enum BookCondition { New, LikeNew, Good, Used }

extension BookConditionExtension on BookCondition {
  String toDisplayString() {
    switch (this) {
      case BookCondition.LikeNew:
        return 'Like New';
      default:
        return toString().split('.').last;
    }
  }

  static BookCondition fromMap(String value) {
    switch (value) {
      case 'Like New':
        return BookCondition.LikeNew;
      case 'New':
        return BookCondition.New;
      case 'Good':
        return BookCondition.Good;
      case 'Used':
        return BookCondition.Used;
      default:
        return BookCondition.Used;
    }
  }
}

// ListingStatus
enum ListingStatus { available, pending, swapped }

extension ListingStatusExtension on ListingStatus {
  String toDisplayString() {
    String s = toString().split('.').last;
    return "${s[0].toUpperCase()}${s.substring(1)}";
  }

  static ListingStatus fromMap(String value) {
    switch (value) {
      case 'available':
        return ListingStatus.available;
      case 'pending':
        return ListingStatus.pending;
      case 'swapped':
        return ListingStatus.swapped;
      default:
        return ListingStatus.available;
    }
  }
}

// BookListing model class
class BookListing {
  final String listingId;
  final String ownerUid;
  final String title;
  final String author;
  final BookCondition condition;
  final String coverImageUrl;
  final ListingStatus status;
  final Timestamp createdAt;

  BookListing({
    required this.listingId,
    required this.ownerUid,
    required this.title,
    required this.author,
    required this.condition,
    required this.coverImageUrl,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'listingId': listingId,
      'ownerUid': ownerUid,
      'title': title,
      'author': author,
      'condition': condition.toDisplayString(),
      'coverImageUrl': coverImageUrl,
      'status': status.toDisplayString().toLowerCase(),
      'createdAt': createdAt,
    };
  }

  factory BookListing.fromMap(Map<String, dynamic> map) {
    return BookListing(
      listingId: map['listingId'] ?? '',
      ownerUid: map['ownerUid'] ?? '',
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      condition: BookConditionExtension.fromMap(map['condition']),
      coverImageUrl: map['coverImageUrl'] ?? '',
      status: ListingStatusExtension.fromMap(map['status']),
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }
}
