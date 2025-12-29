import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../models/user.dart';
import '../models/chat.dart';
import '../models/message.dart';

class ApiService {
  static const String baseUrl = BASE_URL;  // ✅ ИСПРАВЛЕНО: API_BASE_URL → BASE_URL

  // ========== ПОЛЬЗОВАТЕЛИ ==========

  /// Создать нового пользователя
  static Future<User> createUser(String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Ошибка создания пользователя: ${response.body}');
    }
  }

  /// Получить всех пользователей
  static Future<List<User>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((json) => User.fromJson(json)).toList();
        } else {
          print('Ответ сервера не список: $data');
          return [];
        }
      } else {
        print('Ошибка HTTP: ${response.statusCode} - ${response.body}');
        throw Exception('Ошибка получения пользователей');
      }
    } catch (e) {
      print('Ошибка загрузки пользователей: $e');
      rethrow;
    }
  }

  /// Получить пользователя по ID
  static Future<User> getUserById(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/$userId'),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Пользователь не найден');
    }
  }

  // ========== ЧАТЫ ==========

  /// Получить чаты пользователя
  static Future<List<Chat>> getUserChats(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/chats?userId=$userId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((json) => Chat.fromJson(json)).toList();
        } else {
          print('Ответ сервера не список чатов: $data');
          return [];
        }
      } else {
        print('Ошибка HTTP чаты: ${response.statusCode} - ${response.body}');
        throw Exception('Ошибка получения чатов');
      }
    } catch (e) {
      print('Ошибка загрузки чатов: $e');
      rethrow;
    }
  }

  /// Создать групповой чат
  static Future<Chat> createGroupChat(String title, List<String> memberIds) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/chats/group'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'memberIds': memberIds,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 201) {
      return Chat.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Ошибка создания группового чата: ${response.body}');
    }
  }

  /// Создать или получить личный чат
  static Future<Chat> getOrCreatePrivateChat(String userId1, String userId2) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/chats/private'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId1': userId1,
        'userId2': userId2,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Chat.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Ошибка создания личного чата');
    }
  }

  /// Получить информацию о чате
  static Future<Chat> getChatInfo(String chatId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/chats/$chatId'),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return Chat.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Чат не найден');
    }
  }

  // ========== СООБЩЕНИЯ ==========

  /// Получить сообщения чата
  static Future<List<Message>> getMessages(String chatId, {int limit = 50, int offset = 0}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/chats/$chatId/messages?limit=$limit&offset=$offset'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((json) => Message.fromJson(json)).toList();
        } else {
          print('Ответ сервера не список сообщений: $data');
          return [];
        }
      }
    } catch (e) {
      print('Ошибка загрузки сообщений: $e');
    }
    return [];
  }

  /// Отправить сообщение
  static Future<Message> sendMessage(String chatId, String userId, String text) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/chats/$chatId/messages'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'text': text,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 201) {
      return Message.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Ошибка отправки сообщения');
    }
  }

  /// Проверить здоровье сервера
  static Future<bool> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/health'),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
