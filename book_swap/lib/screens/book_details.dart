import '../models/book_listing.dart';
import '../providers/bookswap_providers.dart';
import '../models/swap_offer.dart';
import '../widgets/loading_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class BookDetailScreen extends ConsumerStatefulWidget {
  final BookListing book;
  const BookDetailScreen({Key? key, required this.book}) : super(key: key);

  @override
  ConsumerState<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends ConsumerState<BookDetailScreen> {
  bool _isLoading = false;

  Future<void> _requestSwap() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      final currentUid = ref.read(authStateProvider).value?.uid;

      if (currentUid == null) {
        throw Exception('User not logged in.');
      }

      final newSwapId = const Uuid().v4();

      final SwapOffer newOffer = SwapOffer(
        swapId: newSwapId,
        listingId: widget.book.listingId,
        listingOwnerUid: widget.book.ownerUid,
        requesterUid: currentUid,
        status: SwapStatus.pending,
        createdAt: Timestamp.now(),
      );

      await firestoreService.requestSwap(newOffer);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Swap request sent!'),
            backgroundColor: Colors.green[600],
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send request: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = ref.watch(authStateProvider).value?.uid;
    final bool isOwner =
        (currentUid != null && currentUid == widget.book.ownerUid);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(widget.book.title),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(widget.book.coverImageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.book.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'by ${widget.book.author}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Divider(color: Colors.grey[800]),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'CONDITION',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white54,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        widget.book.condition.toDisplayString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'STATUS',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white54,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        widget.book.status.toDisplayString().toUpperCase(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: widget.book.status == ListingStatus.available
                              ? Colors.greenAccent
                              : Colors.orangeAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Swap Button
                  if (!isOwner && widget.book.status == ListingStatus.available)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _requestSwap,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                        ),
                        child: Text(
                          'Request Swap',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900],
                          ),
                        ),
                      ),
                    ),

                  if (isOwner)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'This is your listing. You can edit it from the "My Listings" tab.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (_isLoading) const LoadingScreen(message: 'Sending Request...'),
      ],
    );
  }
}
