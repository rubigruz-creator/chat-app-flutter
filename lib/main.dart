import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'services/socket_service.dart';

void main() {
  SocketService(); // Инициализируем singleton
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Friend Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
