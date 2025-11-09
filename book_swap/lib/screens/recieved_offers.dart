import '../providers/bookswap_providers.dart';
import '../widgets/swap_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReceivedOffersTab extends ConsumerWidget {
  const ReceivedOffersTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receivedSwapsAsync = ref.watch(receivedSwapsProvider);

    return receivedSwapsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: ${err.toString()}')),
      data: (swaps) {
        if (swaps.isEmpty) {
          return const Center(
            child: Text(
              'You have no pending swap requests.',
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
            return SwapListTile(swap: swap, isReceivedOffer: true);
          },
        );
      },
    );
  }
}
