import '../models/book_listing.dart';
import '../providers/bookswap_providers.dart';
import '../widgets/loading_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class PostEditBookScreen extends ConsumerStatefulWidget {
  final BookListing? book;
  const PostEditBookScreen({super.key, this.book});

  bool get isEditing => book != null;

  @override
  ConsumerState<PostEditBookScreen> createState() => _PostEditBookScreenState();
}

class _PostEditBookScreenState extends ConsumerState<PostEditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  BookCondition _selectedCondition = BookCondition.Good;

  bool _isLoading = false;

  final String _placeholderImageUrl =
      'https://placehold.co/600x800/222222/FFFFFF?text=Book+Cover';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book?.title);
    _authorController = TextEditingController(text: widget.book?.author);
    if (widget.isEditing) {
      _selectedCondition = widget.book!.condition;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      final currentUid = ref.read(authStateProvider).value!.uid;

      if (widget.isEditing) {
        BookListing updatedBook = BookListing(
          listingId: widget.book!.listingId,
          ownerUid: widget.book!.ownerUid,
          title: _titleController.text.trim(),
          author: _authorController.text.trim(),
          condition: _selectedCondition,
          coverImageUrl: widget.book!.coverImageUrl.isNotEmpty
              ? widget.book!.coverImageUrl
              : _placeholderImageUrl,
          status: widget.book!.status,
          createdAt: widget.book!.createdAt,
        );

        await firestoreService.updateBook(updatedBook);
      } else {
        final newBookId = const Uuid().v4();

        BookListing newBook = BookListing(
          listingId: newBookId,
          ownerUid: currentUid,
          title: _titleController.text.trim(),
          author: _authorController.text.trim(),
          condition: _selectedCondition,
          coverImageUrl: _placeholderImageUrl,
          status: ListingStatus.available,
          createdAt: Timestamp.now(),
        );

        await firestoreService.postBook(newBook);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Book ${widget.isEditing ? 'updated' : 'posted'}!'),
            backgroundColor: Colors.green[600],
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save book: ${e.toString()}'),
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

  Future<void> _deleteBook() async {
    if (!widget.isEditing) return;

    final didConfirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text(
          'Do you want to permanently delete this book listing?',
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (didConfirm != true) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final firestoreService = ref.read(firestoreServiceProvider);

      await firestoreService.deleteBook(widget.book!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Book deleted'),
            backgroundColor: Colors.green[600],
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete book: ${e.toString()}'),
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
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(widget.isEditing ? 'Edit Book' : 'Post a Book'),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            actions: [
              if (widget.isEditing)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: _deleteBook,
                ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Book Title',
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a title' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _authorController,
                      decoration: const InputDecoration(labelText: 'Author'),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter an author' : null,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Condition',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                    DropdownButtonFormField<BookCondition>(
                      value: _selectedCondition,
                      items: BookCondition.values
                          .map(
                            (condition) => DropdownMenuItem(
                              value: condition,
                              child: Text(condition.toDisplayString()),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCondition = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text(
                        widget.isEditing ? 'Save Changes' : 'Post Book',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_isLoading) const LoadingScreen(message: 'Saving...'),
      ],
    );
  }
}
