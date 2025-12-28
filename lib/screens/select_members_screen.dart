import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import 'messages_screen.dart';

class SelectMembersScreen extends StatefulWidget {
  final User currentUser;

  const SelectMembersScreen({
    Key? key,
    required this.currentUser,
  }) : super(key: key);

  @override
  State<SelectMembersScreen> createState() => _SelectMembersScreenState();
}

class _SelectMembersScreenState extends State<SelectMembersScreen> {
  final TextEditingController _titleController = TextEditingController();
  late Future<List<User>> _usersFuture;
  final Set<String> _selectedMembers = {};
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _usersFuture = ApiService.getUsers();
  }

  void _createGroupChat() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название чата')),
      );
      return;
    }

    if (_selectedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите хотя бы одного участника')),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      // Добавляем текущего пользователя
      final memberIds = [..._selectedMembers, widget.currentUser.id];

      final chat = await ApiService.createGroupChat(title, memberIds);

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
      setState(() {
        _isCreating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Новый групповой чат'),
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

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Название чата',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                    ),
                    prefixIcon: const Icon(Icons.group),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding,
                ),
                child: Text(
                  'Выбрано: ${_selectedMembers.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppConstants.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: otherUsers.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final user = otherUsers[index];
                    final isSelected = _selectedMembers.contains(user.id);

                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedMembers.add(user.id);
                          } else {
                            _selectedMembers.remove(user.id);
                          }
                        });
                      },
                      title: Text(user.name),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: ElevatedButton(
                  onPressed: _isCreating ? null : _createGroupChat,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: AppConstants.primaryColor,
                  ),
                  child: _isCreating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Создать чат',
                        style: TextStyle(color: Colors.white),
                      ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
