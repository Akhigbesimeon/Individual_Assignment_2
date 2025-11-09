import 'package:flutter/material.dart';
import '../models/book_listing.dart';
import '../models/user_model.dart';
import '../providers/bookswap_provider.dart';
import '../screens/chat_detail_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatsScreen extends ConsumerWidget {
  const ChatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatListAsync = ref.watch(chatListProvider);
    final currentUid = ref.watch(authStateProvider).value?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: chatListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: ${err.toString()}')),
        data: (chats) {
          if (chats.isEmpty) {
            return const Center(
              child: Text(
                'You have no chats.\nAccept a swap to start a conversation!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final listingId = chat['listingId'] as String;
              final List participantUids = chat['participantUids'] as List;

              final String otherUserUid = participantUids.firstWhere(
                (uid) => uid != currentUid,
                orElse: () => '',
              );

              final bookAsync = ref.watch(bookByIdProvider(listingId));
              final userAsync = ref.watch(userByIdProvider(otherUserUid));

              return bookAsync.when(
                data: (BookListing? book) {
                  return userAsync.when(
                    data: (UserModel? user) {
                      if (book == null || user == null) {
                        return const ListTile(title: Text('Loading chat...'));
                      }

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(book.coverImageUrl),
                        ),
                        title: Text(
                          'Chat with ${user.displayName}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          chat['lastMessage'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatDetailScreen(
                                chatId: chat['chatId'] as String,
                                otherUser: user,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (e, s) => const SizedBox.shrink(),
                  );
                },
                loading: () => const ListTile(title: Text('Loading chat...')),
                error: (e, s) => const ListTile(title: Text('Error')),
              );
            },
          );
        },
      ),
    );
  }
}
