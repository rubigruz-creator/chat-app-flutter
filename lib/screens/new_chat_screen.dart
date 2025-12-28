import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import 'select_members_screen.dart';
import 'messages_screen.dart';

class NewChatScreen extends StatefulWidget {
  final User currentUser;

  const NewChatScreen({
    Key? key,
    required this.currentUser,
  }) : super(key: key);

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = ApiService.getUsers();
  }

  void _startPrivateChat(User selectedUser) async {
    try {
      final chat = await ApiService.getOrCreatePrivateChat(
        widget.currentUser.id,
        selectedUser.id,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MessagesScreen(
              chat: chat,
              currentUser: widget.currentUser,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  void _startGroupChat() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SelectMembersScreen(
          currentUser: widget.currentUser,
        ),
      ),
    ).then((result) {
      if (result != null && mounted) {
        Navigator.of(context).pop(result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Новый чат'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: FutureBuilder<List<User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }

          final users = snapshot.data ?? [];
          final otherUsers = users
            .where((user) => user.id != widget.currentUser.id)
            .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.person_add,
                          size: 32,
                          color: AppConstants.primaryColor,
                        ),
                        const SizedBox(height: AppConstants.defaultPadding),
                        const Text(
                          'Личный чат',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppConstants.smallPadding),
                        const Text(
                          'Выберите друга для личного разговора',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppConstants.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppConstants.defaultPadding),
                        ...otherUsers.map((user) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppConstants.smallPadding,
                          ),
                          child: ElevatedButton(
                            onPressed: () => _startPrivateChat(user),
                            style: ElevatedButton.styleFrom(
                              alignment: Alignment.centerLeft,
                              backgroundColor: Colors.white,
                              foregroundColor: AppConstants.textPrimary,
                              side: const BorderSide(
                                color: AppConstants.dividerColor,
                              ),
                            ),
                            child: Text(user.name),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.group_add,
                          size: 32,
                          color: AppConstants.primaryColor,
                        ),
                        const SizedBox(height: AppConstants.defaultPadding),
                        const Text(
                          'Групповой чат',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppConstants.smallPadding),
                        const Text(
                          'Создайте чат с несколькими друзьями',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppConstants.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppConstants.defaultPadding),
                        ElevatedButton(
                          onPressed: _startGroupChat,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(AppConstants.smallPadding),
                            child: Text(
                              'Создать групповой чат',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
