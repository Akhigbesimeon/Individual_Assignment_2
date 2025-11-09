import 'package:cloud_firestore/cloud_firestore.dart';

enum SwapStatus { pending, accepted, rejected }

extension SwapStatusExtension on SwapStatus {
  String toDisplayString() {
    String s = toString().split('.').last;
    return "${s[0].toUpperCase()}${s.substring(1)}";
  }

  static SwapStatus fromMap(String value) {
    switch (value) {
      case 'pending':
        return SwapStatus.pending;
      case 'accepted':
        return SwapStatus.accepted;
      case 'rejected':
        return SwapStatus.rejected;
      default:
        return SwapStatus.pending;
    }
  }
}

// SwapOffer model class
class SwapOffer {
  final String swapId;
  final String listingId;
  final String listingOwnerUid;
  final String requesterUid;
  final SwapStatus status;
  final Timestamp createdAt;

  SwapOffer({
    required this.swapId,
    required this.listingId,
    required this.listingOwnerUid,
    required this.requesterUid,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'swapId': swapId,
      'listingId': listingId,
      'listingOwnerUid': listingOwnerUid,
      'requesterUid': requesterUid,
      'status': status.toDisplayString().toLowerCase(),
      'createdAt': createdAt,
    };
  }

  factory SwapOffer.fromMap(Map<String, dynamic> map) {
    return SwapOffer(
      swapId: map['swapId'] ?? '',
      listingId: map['listingId'] ?? '',
      listingOwnerUid: map['listingOwnerUid'] ?? '',
      requesterUid: map['requesterUid'] ?? '',
      status: SwapStatusExtension.fromMap(map['status']),
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }
}
