import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:urbano_manage/core/constants/api_config.dart'; 

class SignalRService extends ChangeNotifier {
  HubConnection? _connection;
  bool isConnected = false;
  int unreadCount = 0;
  List<Map<String, dynamic>> recentEvents = [];

  Future<void> connect() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    if (token.isEmpty) return;

    // Tạo URL Hub (bỏ /api, thêm /hubs/notification)
    final hubUrl = ApiConfig.baseUrl.replaceAll('/api', '/hubs/notification');

    _connection = HubConnectionBuilder()
        .withUrl(
          hubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async => token,
            transport: HttpTransportType.WebSockets,
            skipNegotiation: true,
          ),
        )
        .withAutomaticReconnect()
        .build();

    // === ĐĂNG KÝ LẮNG NGHE TẤT CẢ EVENT ===
    _connection!.on('ReceiveNotification', _onEvent('notification'));
    _connection!.on('NewRequest', _onEvent('new_request'));
    _connection!.on('RequestStatusChanged', _onEvent('request_status'));
    _connection!.on('NewBooking', _onEvent('new_booking'));
    _connection!.on('BookingStatusChanged', _onEvent('booking_status'));
    _connection!.on('NewInvoice', _onEvent('new_invoice'));
    _connection!.on('SystemAlert', _onEvent('system_alert'));

    // === TRẠNG THÁI KẾT NỐI ===
    _connection!.onclose(({error}) {
      isConnected = false;
      notifyListeners();
    });
    _connection!.onreconnecting(({error}) {
      isConnected = false;
      notifyListeners();
    });
    _connection!.onreconnected(({connectionId}) {
      isConnected = true;
      notifyListeners();
    });

    try {
      await _connection!.start();
      isConnected = true;
      notifyListeners();
      debugPrint('SignalR: Connected to $hubUrl');
    } catch (e) {
      debugPrint('SignalR: Connection failed: $e');
    }
  }

  /// Factory tạo handler cho mỗi loại event
  void Function(List<Object?>?) _onEvent(String type) {
    return (args) {
      final data = args?.isNotEmpty == true
          ? Map<String, dynamic>.from(args![0] as Map)
          : <String, dynamic>{};
      data['_type'] = type;
      data['_receivedAt'] = DateTime.now().toIso8601String();
      recentEvents.insert(0, data);
      if (recentEvents.length > 50) recentEvents.removeLast(); // giữ 50 event gần nhất
      unreadCount++;
      notifyListeners();
      debugPrint('SignalR: Received $type → ${data['tieuDe'] ?? data['id'] ?? ''}');
    };
  }

  void clearUnread() {
    unreadCount = 0;
    notifyListeners();
  }

  Future<void> disconnect() async {
    await _connection?.stop();
    isConnected = false;
    recentEvents.clear();
    unreadCount = 0;
    notifyListeners();
  }
}
