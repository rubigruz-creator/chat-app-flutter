import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import 'chat_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  List<User> _existingUsers = [];
  bool _usersLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadExistingUsers();
  }

  void _loadExistingUsers() async {
    try {
      final users = await ApiService.getUsers();
      if (mounted) {
        setState(() {
          _existingUsers = users;
          _usersLoaded = true;
        });
      }
    } catch (e) {
      print('Ошибка загрузки пользователей: $e');
      if (mounted) {
        setState(() {
          _usersLoaded = true;
        });
      }
    }
  }

  void _loginWithExistingUser(User user) {
    _navigateToChatList(user);
  }

  void _createAndLogin() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Пожалуйста, введите имя';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await ApiService.createUser(name);
      if (mounted) {
        _navigateToChatList(user);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Ошибка: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToChatList(User user) {
    SocketService().initialize();
    SocketService().connect();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ChatListScreen(currentUser: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              const Icon(
                Icons.chat,
                size: 64,
                color: AppConstants.primaryColor,
              ),
              const SizedBox(height: 32),
              const Text(
                'Chat App',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Создать новый аккаунт:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Введите своё имя',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              ElevatedButton(
                onPressed: _isLoading ? null : _createAndLogin,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: AppConstants.primaryColor,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Создать аккаунт',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Или выбери существующего пользователя:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (!_usersLoaded)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else if (_existingUsers.isEmpty)
                const Center(
                  child: Text('Пользователей нет'),
                )
              else
                Column(
                  children: _existingUsers.map((user) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ElevatedButton(
                        onPressed: () => _loginWithExistingUser(user),
                        style: ElevatedButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          backgroundColor: Colors.white,
                          foregroundColor: AppConstants.textPrimary,
                          side: const BorderSide(color: AppConstants.dividerColor),
                        ),
                        child: Text(user.name),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
