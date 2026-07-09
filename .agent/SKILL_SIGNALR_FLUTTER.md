# SKILL BỔ SUNG — SignalR Real-time cho Flutter (Quản lý + Cư dân)

File này áp dụng cho CẢ HAI app Flutter. Sự khác biệt giữa 2 app được ghi rõ.

---

## SR1. PACKAGE

```yaml
# pubspec.yaml — thêm cho CẢ HAI app
dependencies:
  signalr_netcore: ^1.3.7
```

## SR2. SIGNALR SERVICE (`lib/core/network/signalr_service.dart`)

Tạo **cùng một file** cho cả 2 app (copy y hệt), đặt ở `lib/core/network/`:

```dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_netcore/signalr_netcore.dart';
import 'package:urbano/core/constants/apiconfig.dart';  // hoặc api_config.dart tùy app

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
            transport: HttpTransportType.webSockets,
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
```

## SR3. ĐĂNG KÝ PROVIDER + KẾT NỐI

### App Quản lý (`main.dart`):
```dart
// Thêm vào MultiProvider
ChangeNotifierProvider(create: (_) => SignalRService()),
```

Sau login thành công (trong `LoginViewModel` hoặc `AuthGate`):
```dart
final signalR = Provider.of<SignalRService>(context, listen: false);
await signalR.connect();
```

Khi logout:
```dart
await signalR.disconnect();
```

### App Cư dân (`main.dart`):
Tương tự — thêm provider, connect sau login, disconnect khi logout.
Trong `LoginViewmodel.login()` sau `prefs.setString('token', ...)`:
```dart
// Kết nối SignalR sau login
// (cần truyền context hoặc dùng service locator)
```

**Lưu ý app cư dân:** vì `LoginViewmodel` không có `BuildContext`, cách tốt nhất
là kết nối SignalR **ở `HomeScreen.initState`** (màn đầu tiên sau login):
```dart
@override
void initState() {
  super.initState();
  Provider.of<SignalRService>(context, listen: false).connect();
}
```

## SR4. HIỂN THỊ UI

### Badge thông báo chưa đọc (CẢ HAI app):
```dart
Consumer<SignalRService>(
  builder: (_, signalR, __) => Badge(
    isLabelVisible: signalR.unreadCount > 0,
    label: Text('${signalR.unreadCount}'),
    child: IconButton(
      icon: const Icon(Icons.notifications_outlined),
      onPressed: () { /* mở màn thông báo */ },
    ),
  ),
)
```

### SnackBar khi nhận event (đặt ở MainShell hoặc HomeScreen):
```dart
// Lắng nghe thay đổi
final signalR = context.watch<SignalRService>();
// Trong didChangeDependencies hoặc listener:
if (signalR.recentEvents.isNotEmpty) {
  final latest = signalR.recentEvents.first;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(latest['tieuDe'] ?? latest['message'] ?? 'Có cập nhật mới'),
      backgroundColor: AppColors.tealPrimary,
    ),
  );
}
```

### Trạng thái kết nối (nhỏ, tùy chọn):
```dart
if (!signalR.isConnected)
  Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 2),
    color: AppColors.red,
    child: const Text('Mất kết nối', textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 11)),
  )
```

## SR5. RECONNECT KHI APP QUAY LẠI FOREGROUND

### App Quản lý (MainShell đã có lifecycle):
Thêm `WidgetsBindingObserver` vào `MainShellState`:
```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    final signalR = context.read<SignalRService>();
    if (!signalR.isConnected) signalR.connect();
  }
}
```

### App Cư dân (HomeScreen):
Tương tự, thêm `WidgetsBindingObserver` vào `_HomeviewState` (cần đổi
`_Homeview` từ `StatelessWidget` sang `StatefulWidget` nếu chưa):
```dart
class _Homeview extends StatefulWidget { ... }
class _HomeviewState extends State<_Homeview> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final signalR = context.read<SignalRService>();
      if (!signalR.isConnected) signalR.connect();
    }
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
```

## SR6. SỰ KIỆN NÀO QUAN TRỌNG VỚI APP NÀO

| Event | App Quản lý | App Cư dân | Hành động UI |
|---|---|---|---|
| `ReceiveNotification` | ✅ (staff) | ❌ (không trong group) | Badge + SnackBar + refresh list thông báo |
| `NewRequest` | ✅ (managers) | ❌ | Badge + SnackBar + refresh list yêu cầu nếu đang mở |
| `RequestStatusChanged` | ❌ | ✅ (resident_{id}) | SnackBar "Yêu cầu đã được xử lý" + refresh |
| `NewBooking` | ✅ (managers) | ❌ | Badge + SnackBar |
| `BookingStatusChanged` | ❌ | ✅ (resident_{id}) | SnackBar "Đặt lịch đã duyệt/từ chối" |
| `NewInvoice` | ❌ | ✅ (resident_{id}) | SnackBar "Hóa đơn mới" + badge |
| `SystemAlert` | ✅ (managers) | ❌ | Thẻ cảnh báo Dashboard |

Cả hai app đăng ký **tất cả event** (code giống nhau) — server tự quyết gửi tới
group nào. Client không nhận event nếu không thuộc group đó.

## SR7. AUTO-REFRESH LIST KHI NHẬN EVENT

Khi đang ở màn yêu cầu cư dân mà nhận `NewRequest` → list nên tự refresh.
Cách đơn giản: trong View, listen `SignalRService`, khi `recentEvents` có event
type phù hợp → gọi lại `viewModel.fetchData()`:

```dart
// Trong build() hoặc didChangeDependencies()
final signalR = context.watch<SignalRService>();
final latestType = signalR.recentEvents.isNotEmpty
    ? signalR.recentEvents.first['_type'] : null;
if (latestType == 'new_request') {
  // Debounce để tránh gọi liên tục
  WidgetsBinding.instance.addPostFrameCallback((_) {
    viewModel.fetchYeuCaus();
  });
}
```
