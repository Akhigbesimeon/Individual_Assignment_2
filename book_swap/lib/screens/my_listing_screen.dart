import '../screens/post_edit_book_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/my_books_tab.dart';
import '../screens/recieved_offers.dart';
import '../screens/sent_offers.dart';

class MyListingsScreen extends ConsumerStatefulWidget {
  const MyListingsScreen({Key? key}) : super(key: key);
  @override
  ConsumerState<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends ConsumerState<MyListingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PostEditBookScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFFFD700),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFFFD700),
          tabs: const [
            Tab(text: 'My Books'),
            Tab(text: 'Received Offers'),
            Tab(text: 'Sent Offers'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [MyBooksTab(), ReceivedOffersTab(), SentOffersTab()],
      ),
    );
  }
}
