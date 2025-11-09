import '../screens/book_details.dart';
import '../widgets/book_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bookswap_providers.dart';

class BrowseListingsScreen extends ConsumerWidget {
  const BrowseListingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(allListingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Listings'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: listingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: ${err.toString()}')),
        data: (listings) {
          if (listings.isEmpty) {
            return const Center(
              child: Text(
                'No books have been listed yet.',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: listings.length,
            itemBuilder: (context, index) {
              final book = listings[index];
              return BookListTile(
                book: book,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookDetailScreen(book: book),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
