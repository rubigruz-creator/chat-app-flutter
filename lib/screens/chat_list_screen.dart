import 'package:flutter/material.dart';
import 'dart:async';
import '../models/user.dart';
import '../models/chat.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../utils/constants.dart';
import '../widgets/chat_tile.dart';
import '../widgets/loading_widget.dart';
import 'messages_screen.dart';
import 'new_chat_screen.dart';
import 'login_screen.dart';

class ChatListScreen extends StatefulWidget {
  final User currentUser;

  const ChatListScreen({
    Key? key,
    required this.currentUser,
  }) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Chat> _chats = [];
  late SocketService _socketService;
  bool _isLoading = true;
  StreamSubscription? _chatSubscription;

  @override
  void initState() {
    super.initState();
    _socketService = SocketService();
    _socketService.initialize();
    _socketService.connect();
    _setupSocketListeners();
    _loadChats();
  }

  void _setupSocketListeners() {
    _chatSubscription = _socketService.onChatUpdated((data) {
      print('[ChatList] Обновление чата: $data');
      if (mounted) {
        _loadChats();
      }
    });
  }

  Future<void> _loadChats() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final chats = await ApiService.getUserChats(widget.currentUser.id);
      if (mounted) {
        setState(() {
          _chats = chats;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Ошибка чатов: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openChat(Chat chat) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MessagesScreen(
          chat: chat,
          currentUser: widget.currentUser,
        ),
      ),
    );
  }

  void _createNewChat() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NewChatScreen(currentUser: widget.currentUser),
      ),
    ).then((_) => _loadChats());
  }

  void _logout() {
    _chatSubscription?.cancel();
    _socketService.disconnect();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: AppConstants.textSecondary,
          ),
          const SizedBox(height: 16),
          const Text('Нет чатов. Создайте новый!'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createNewChat,
            icon: const Icon(Icons.add),
            label: const Text('Новый чат'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Чаты'),
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Профиль'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Вход как: ${widget.currentUser.name}')),
                  );
                },
              ),
              PopupMenuItem(
                child: const Text('Выход'),
                onTap: _logout,
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Загрузка чатов...')
          : RefreshIndicator(
              onRefresh: _loadChats,
              child: _chats.isEmpty
                  ? _emptyState()
                  : ListView.separated(
                      itemCount: _chats.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final chat = _chats[index];
                        return ChatTile(
                          chat: chat,
                          onTap: () => _openChat(chat),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewChat,
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
    super.dispose();
  }
}
