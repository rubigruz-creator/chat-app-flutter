import '../services/socket_service.dart';  // ← ДОБАВЬ ЭТОТ ИМПОРТ
import 'package:flutter/material.dart';
import '../services/api_service.dart';
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
  bool _showExistingUsers = false;
  List<User> _existingUsers = [];

  @override
  void initState() {
    super.initState();
    _loadExistingUsers();
  }

  void _loadExistingUsers() async {
    try {
      final users = await ApiService.getUsers();
      setState(() {
        _existingUsers = users;
      });
    } catch (e) {
      print('Ошибка загрузки пользователей: $e');
    }
  }

  void _loginWithExistingUser(User user) async {
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
      _navigateToChatList(user);
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _navigateToChatList(User user) {    
    SocketService().initialize();  // ← ДОБАВЬ ПЕРЕД НАВИГАЦИЕЙ
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
      child: SingleChildScrollView(  // ← Делаем прокрутку
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ... остальной код до TextField ...
            
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
            ElevatedButton(
              onPressed: _isLoading ? null : _createAndLogin,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: AppConstants.primaryColor,
              ),
              child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Создать аккаунт', style: TextStyle(color: Colors.white)),
            ),
            
            // ← ПРИНУДИТЕЛЬНО ДОБАВЛЯЕМ КНОПКУ ДЛЯ ТЕСТА
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loginWithExistingUser(User(id: 'test-alice', name: 'Alice', createdAt: DateTime.now())),
              child: const Text('Войти как Alice (тест)'),
            ),
            
            const SizedBox(height: 32),
            if (_existingUsers.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 16),
              Text('Пользователи (${_existingUsers.length}):'),
              ..._existingUsers.map((user) => ListTile(
                onTap: () => _loginWithExistingUser(user),
                title: Text(user.name),
                trailing: const Icon(Icons.arrow_forward),
              )),
            ] else ...[
              const Text('Список пуст — ждём загрузки'),
            ],
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
