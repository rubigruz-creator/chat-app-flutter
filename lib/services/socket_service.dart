import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/api_config.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  late IO.Socket _socket;

  // ✅ StreamController с broadcast - правильно!
  final _newMessageController = StreamController<Map<String, dynamic>>.broadcast();
  final _chatUpdatedController = StreamController<Map<String, dynamic>>.broadcast();

  bool _listenersSetup = false;

  factory SocketService() => _instance;
  SocketService._internal();

  Stream<Map<String, dynamic>> get onNewMessageStream => _newMessageController.stream;
  Stream<Map<String, dynamic>> get onChatUpdatedStream => _chatUpdatedController.stream;

  IO.Socket get socket => _socket;
  bool get isConnected => _socket.connected;

  void initialize() {
    _socket = IO.io(
      SOCKET_URL,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );
    
    // ✅ Слушатели сервера ТОЛЬКО ОДИН РАЗ
    if (!_listenersSetup) {
      _setupListeners();
      _listenersSetup = true;
    }
  }

  void _setupListeners() {
    _socket.onConnect((_) {
      print('[Socket] Подключено к серверу');
    });

    _socket.onDisconnect((_) {
      print('[Socket] Отключено от сервера');
    });

    _socket.onConnectError((error) {
      print('[Socket] Ошибка подключения: $error');
    });

    // ✅ ЕДИНСТВЕННЫЙ слушатель new_message
    _socket.on('new_message', (data) {
      print('[Socket] Новое сообщение: $data');
      if (!_newMessageController.isClosed) {
        _newMessageController.add(data);
      }
    });

    // ✅ ЕДИНСТВЕННЫЙ слушатель chat_updated
    _socket.on('chat_updated', (data) {
      print('[Socket] Чат обновлен: $data');
      if (!_chatUpdatedController.isClosed) {
        _chatUpdatedController.add(data);
      }
    });
  }

  void connect() {
    if (!_socket.connected) {
      print('[Socket] Подключаюсь...');
      _socket.connect();
    }
  }

  void disconnect() {
    if (_socket.connected) {
      print('[Socket] Отключаюсь...');
      _socket.disconnect();
    }
  }

  void joinChat(String userId, String chatId) {
    print('[Socket] Присоединяюсь к чату: $chatId (user: $userId)');
    _socket.emit('join_chat', {'userId': userId, 'chatId': chatId});
  }

  void leaveChat(String chatId) {
    print('[Socket] Покидаю чат: $chatId');
    _socket.emit('leave_chat', {'chatId': chatId});
  }

  void sendMessage(String chatId, String userId, String text) {
    print('[Socket] Отправляю в $chatId: $text');
    _socket.emit('send_message', {'chatId': chatId, 'userId': userId, 'text': text});
  }

  StreamSubscription<Map<String, dynamic>>? onNewMessage(Function(Map<String, dynamic>) callback) {
    return _newMessageController.stream.listen(callback);
  }

  StreamSubscription<Map<String, dynamic>>? onChatUpdated(Function(Map<String, dynamic>) callback) {
    return _chatUpdatedController.stream.listen(callback);
  }

  void dispose() {
    if (!_newMessageController.isClosed) {
      _newMessageController.close();
    }
    if (!_chatUpdatedController.isClosed) {
      _chatUpdatedController.close();
    }
    _socket.dispose();
    _listenersSetup = false;
  }
}
