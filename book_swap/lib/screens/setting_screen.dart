import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bookswap_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationReminders = true;
  bool _emailUpdates = false;

  Future<void> _signOut() async {
    final didConfirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out', style: TextStyle(color: Colors.black)),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: const Text('Log Out'),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (didConfirm == true) {
      await ref.read(authServiceProvider).signOut();
    }
  }

  void _showEditProfileDialog(UserModel currentUser) {
    final nameController = TextEditingController(text: currentUser.displayName);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Display Name'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name.';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newName = nameController.text.trim();
                  await ref
                      .read(firestoreServiceProvider)
                      .updateUserName(currentUser.uid, newName);
                  if (mounted) {
                    Navigator.of(ctx).pop();
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: authState.when(
        data: (User? user) {
          if (user == null) {
            return const Center(child: Text('Not logged in.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildProfileHeader(ref, user.uid),
              const SizedBox(height: 24),
              _buildSettingsGroup(
                title: 'PREFERENCES',
                children: [
                  SwitchListTile(
                    title: const Text(
                      'Notification reminders',
                      style: TextStyle(color: Colors.black),
                    ),
                    subtitle: const Text(
                      'Daily pings for new swaps',
                      style: TextStyle(color: Colors.black),
                    ),
                    secondary: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.black,
                    ),
                    value: _notificationReminders,
                    onChanged: (value) {
                      setState(() {
                        _notificationReminders = value;
                      });
                    },
                    activeColor: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  SwitchListTile(
                    title: const Text(
                      'Email Updates',
                      style: TextStyle(color: Colors.black),
                    ),
                    subtitle: const Text(
                      'Newsletters and updates',
                      style: TextStyle(color: Colors.black),
                    ),
                    secondary: const Icon(
                      Icons.email_outlined,
                      color: Colors.black,
                    ),
                    value: _emailUpdates,
                    onChanged: (value) {
                      setState(() {
                        _emailUpdates = value;
                      });
                    },
                    activeColor: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildSettingsGroup(
                title: 'ABOUT',
                children: [
                  ListTile(
                    title: const Text(
                      'About BookSwap',
                      style: TextStyle(color: Colors.black),
                    ),
                    leading: const Icon(
                      Icons.info_outline,
                      color: Colors.black,
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('About BookSwap'),
                          content: const Text(
                            'This app was built with Flutter and Firebase. Happy swapping!',
                          ),
                          actions: [
                            TextButton(
                              child: const Text('Close'),
                              onPressed: () => Navigator.of(ctx).pop(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text(
                      'Version',
                      style: TextStyle(color: Colors.black),
                    ),
                    leading: const Icon(
                      Icons.code_rounded,
                      color: Colors.black,
                    ),
                    subtitle: const Text(
                      '1.0.0',
                      style: TextStyle(color: Colors.black),
                    ),
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 32),

              ElevatedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.black),
                label: const Text(
                  'Log Out',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: _signOut,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: ${e.toString()}')),
      ),
    );
  }

  Widget _buildProfileHeader(WidgetRef ref, String uid) {
    final userAsync = ref.watch(userByIdProvider(uid));

    return userAsync.when(
      data: (UserModel? user) {
        if (user == null) {
          return const Center(child: Text('User not found.'));
        }
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  user.displayName.isNotEmpty ? user.displayName[0] : 'U',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, color: Colors.grey[600]),
                onPressed: () {
                  _showEditProfileDialog(user);
                },
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => const Center(child: Text('Could not load profile.')),
    );
  }

  Widget _buildSettingsGroup({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: children.length,
            itemBuilder: (context, index) => children[index],
            separatorBuilder: (context, index) => Divider(
              height: 1,
              indent: 16,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
          ),
        ),
      ],
    );
  }
}
