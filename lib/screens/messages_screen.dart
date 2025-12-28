import 'package:flutter/material.dart';
import 'dart:async';
import '../models/user.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../services/socket_service.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/message_bubble.dart';
import '../widgets/loading_widget.dart';

class MessagesScreen extends StatefulWidget {
  final Chat chat;
  final User currentUser;

  const MessagesScreen({
    Key? key,
    required this.chat,
    required this.currentUser,
  }) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<Message> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late SocketService _socketService;
  bool _isSending = false;
  bool _isLoading = true;
  StreamSubscription? _messageSubscription;

  @override
  void initState() {
    super.initState();
    _socketService = SocketService();
    _socketService.initialize();
    _socketService.connect();
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _socketService.joinChat(widget.currentUser.id, widget.chat.id);
      }
    });

    _setupSocketListeners();
    _loadMessages();
  }

  void _setupSocketListeners() {
    _messageSubscription = _socketService.onNewMessage((data) {
      if (data['chat_id'] == widget.chat.id && mounted) {
        final message = Message.fromJson(data);
        setState(() {
          _messages.add(message);
        });
        _scrollToBottom();
      }
    });
  }

  Future<void> _loadMessages() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final messages = await ApiService.getMessages(widget.chat.id);
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      print('Ошибка сообщений: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    _messageController.clear();

    try {
      _socketService.sendMessage(
        widget.chat.id,
        widget.currentUser.id,
        text,
      );
      _scrollToBottom();
    } catch (e) {
      print('Ошибка отправки: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка отправки: $e')),
      );
      _messageController.text = text;
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && mounted) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatTitle = widget.chat.title ?? 'Personal Chat';

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(chatTitle),
            Text(
              '${widget.chat.memberCount} участников',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const LoadingWidget(message: 'Загрузка сообщений...')
                : RefreshIndicator(
                    onRefresh: _loadMessages,
                    child: _messages.isEmpty
                        ? const Center(child: Text('Нет сообщений. Начните разговор!'))
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final message = _messages[index];
                              return MessageBubble(
                                message: message,
                                isCurrentUser: message.userId == widget.currentUser.id,
                              );
                            },
                          ),
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: AppConstants.surfaceColor,
              border: Border(
                top: BorderSide(color: AppConstants.dividerColor),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Сообщение...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.defaultPadding,
                        vertical: AppConstants.smallPadding,
                      ),
                    ),
                    maxLines: null,
                    enabled: !_isSending,
                  ),
                ),
                const SizedBox(width: AppConstants.smallPadding),
                FloatingActionButton(
                  onPressed: _isSending ? null : _sendMessage,
                  backgroundColor: AppConstants.primaryColor,
                  mini: true,
                  child: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    _socketService.leaveChat(widget.chat.id);
    super.dispose();
  }
}
