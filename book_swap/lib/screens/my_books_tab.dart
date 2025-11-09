import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bookswap_providers.dart';
import '../screens/post_edit_book_screen.dart';
import '../widgets/book_list_tile.dart';

class MyBooksTab extends ConsumerWidget {
  const MyBooksTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myListingsAsync = ref.watch(myListingsProvider);

    return myListingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: ${err.toString()}')),
      data: (listings) {
        if (listings.isEmpty) {
          return const Center(
            child: Text(
              'You haven\'t posted any books yet.\nTap the "+" to add one!',
              textAlign: TextAlign.center,
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
                    builder: (context) => PostEditBookScreen(book: book),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
