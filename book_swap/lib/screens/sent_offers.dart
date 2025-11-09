import '../providers/bookswap_provider.dart';
import '../widgets/swap_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SentOffersTab extends ConsumerWidget {
  const SentOffersTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sentSwapsAsync = ref.watch(sentSwapsProvider);

    return sentSwapsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: ${err.toString()}')),
      data: (swaps) {
        if (swaps.isEmpty) {
          return const Center(
            child: Text(
              'You have not sent any swap requests.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: swaps.length,
          itemBuilder: (context, index) {
            final swap = swaps[index];
            return SwapListTile(swap: swap, isReceivedOffer: false);
          },
        );
      },
    );
  }
}
