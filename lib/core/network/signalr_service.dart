import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:urbano_manage/core/constants/api_config.dart';
import 'package:urbano_manage/core/services/local_notification_service.dart';

class SignalRService extends ChangeNotifier {
  HubConnection? _connection;
  bool isConnected = false;
  Map<String, int> unreadCounts = {
    'thongBao': 0,
    'yeuCau': 0,
    'datLich': 0,
    'hoaDon': 0,
  };

  int get totalUnread => unreadCounts.values.fold(0, (a, b) => a + b);

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
    _connection!.on('PaymentReceived', _onEvent('payment_received'));

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
      isConnected = false;
      notifyListeners();
    }
  }

  void Function(List<Object?>?) _onEvent(String type) {
    return (args) {
      final data = args?.isNotEmpty == true
          ? Map<String, dynamic>.from(args![0] as Map)
          : <String, dynamic>{};
      data['_type'] = type;
      data['_receivedAt'] = DateTime.now().toIso8601String();
      recentEvents.insert(0, data);
      if (recentEvents.length > 50) recentEvents.removeLast(); // giữ 50 event gần nhất
      
      String notificationTitle = 'Thông báo mới';
      String notificationBody = 'Bạn có một thông báo mới từ hệ thống.';

      switch (type) {
        case 'notification':
          unreadCounts['thongBao'] = (unreadCounts['thongBao'] ?? 0) + 1;
          notificationTitle = data['tieuDe']?.toString() ?? 'Thông báo hệ thống';
          notificationBody = data['noiDung']?.toString() ?? 'Có thông báo mới';
          break;
        case 'new_request':
          unreadCounts['yeuCau'] = (unreadCounts['yeuCau'] ?? 0) + 1;
          notificationTitle = 'Yêu cầu cư dân mới';
          notificationBody = data['tieuDe']?.toString() ?? 'Có yêu cầu mới được gửi đến';
          break;
        case 'new_booking':
          unreadCounts['datLich'] = (unreadCounts['datLich'] ?? 0) + 1;
          notificationTitle = 'Đặt lịch mới';
          notificationBody = 'Có một lượt đặt lịch tiện ích mới cần xem xét';
          break;
        case 'new_invoice':
          unreadCounts['hoaDon'] = (unreadCounts['hoaDon'] ?? 0) + 1;
          notificationTitle = 'Hóa đơn mới';
          notificationBody = 'Hóa đơn ${data['maThanhToan'] ?? ''} vừa được tạo';
          break;
        case 'payment_received':
          unreadCounts['hoaDon'] = (unreadCounts['hoaDon'] ?? 0) + 1;
          notificationTitle = 'Thanh toán thành công';
          notificationBody = 'Đã nhận thanh toán cho hóa đơn ${data['maThanhToan'] ?? ''}';
          break;
        case 'request_status':
          unreadCounts['yeuCau'] = (unreadCounts['yeuCau'] ?? 0) + 1;
          notificationTitle = 'Cập nhật yêu cầu';
          notificationBody = 'Yêu cầu của bạn vừa được cập nhật trạng thái';
          break;
        case 'booking_status':
          unreadCounts['datLich'] = (unreadCounts['datLich'] ?? 0) + 1;
          notificationTitle = 'Cập nhật đặt lịch';
          notificationBody = 'Lịch tiện ích của bạn đã được cập nhật';
          break;
        case 'system_alert':
          unreadCounts['thongBao'] = (unreadCounts['thongBao'] ?? 0) + 1;
          notificationTitle = 'Cảnh báo hệ thống';
          notificationBody = data['noiDung']?.toString() ?? 'Cảnh báo từ hệ thống';
          break;
        default:
          unreadCounts['thongBao'] = (unreadCounts['thongBao'] ?? 0) + 1;
          notificationTitle = data['tieuDe']?.toString() ?? 'Thông báo';
          notificationBody = 'Sự kiện mới: $type';
      }
      
      LocalNotificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title: notificationTitle,
        body: notificationBody,
        payload: type,
      );

      notifyListeners();
      debugPrint('SignalR: Received $type → ${data['tieuDe'] ?? data['id'] ?? ''}');
    };
  }

  void clearUnreadFor(String key) {
    if (unreadCounts.containsKey(key)) {
      unreadCounts[key] = 0;
      notifyListeners();
    }
  }

  void clearUnread() {
    for (var key in unreadCounts.keys) {
      unreadCounts[key] = 0;
    }
    notifyListeners();
  }

  Future<void> disconnect() async {
    await _connection?.stop();
    isConnected = false;
    recentEvents.clear();
    for (var key in unreadCounts.keys) {
      unreadCounts[key] = 0;
    }
    notifyListeners();
  }
}
