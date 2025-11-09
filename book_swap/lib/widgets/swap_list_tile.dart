import '../models/book_listing.dart';
import '../models/user_model.dart';
import '../models/swap_offer.dart';
import '../providers/bookswap_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class SwapListTile extends ConsumerWidget {
  final SwapOffer swap;
  final bool isReceivedOffer;

  const SwapListTile({
    Key? key,
    required this.swap,
    required this.isReceivedOffer,
  }) : super(key: key);

  String _getSubtitle(BookListing book, UserModel user, SwapStatus status) {
    if (isReceivedOffer) {
      return 'Offer from ${user.displayName} for your book: ${book.title}';
    } else {
      return 'Your offer for ${user.displayName}\'s book: ${book.title}';
    }
  }

  // Helper to get the color based on the status
  Color _getStatusColor(SwapStatus status) {
    switch (status) {
      case SwapStatus.pending:
        return Colors.orangeAccent;
      case SwapStatus.accepted:
        return Colors.greenAccent;
      case SwapStatus.rejected:
        return Colors.redAccent;
    }
  }

  // Method to handle managing the swap
  void _manageSwap(BuildContext context, WidgetRef ref, bool accept) {
    final firestoreService = ref.read(firestoreServiceProvider);
    firestoreService
        .manageSwap(swap, accept)
        .then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Offer ${accept ? 'accepted' : 'rejected'}'),
              backgroundColor: Colors.green[600],
            ),
          );
        })
        .catchError((e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to manage offer: ${e.toString()}'),
              backgroundColor: Colors.redAccent,
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch the book and user details using the providers
    final bookAsync = ref.watch(bookByIdProvider(swap.listingId));
    final userAsync = ref.watch(
      userByIdProvider(
        isReceivedOffer ? swap.requesterUid : swap.listingOwnerUid,
      ),
    );

    return userAsync.when(
      data: (UserModel? user) {
        return bookAsync.when(
          data: (BookListing? book) {
            if (book == null || user == null) {
              return const Card(
                child: ListTile(title: Text('Loading swap data...')),
              );
            }

            return Card(
              color: Colors.grey[850],
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(book.coverImageUrl),
                    ),
                    title: Text(
                      isReceivedOffer ? 'New Offer Received' : 'Offer Sent',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(_getSubtitle(book, user, swap.status)),
                    trailing: Text(
                      swap.status.toDisplayString().toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(swap.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isReceivedOffer && swap.status == SwapStatus.pending)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => _manageSwap(context, ref, false),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent),
                            ),
                            child: const Text('Reject'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () => _manageSwap(context, ref, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                            ),
                            child: const Text('Accept'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
          loading: () =>
              const Card(child: ListTile(title: Text('Loading book...'))),
          error: (e, s) => Card(child: ListTile(title: Text('Error: $e'))),
        );
      },
      loading: () =>
          const Card(child: ListTile(title: Text('Loading user...'))),
      error: (e, s) => Card(child: ListTile(title: Text('Error: $e'))),
    );
  }
}
