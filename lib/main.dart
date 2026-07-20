import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/core/theme_provider.dart';
import 'package:urbano_manage/features/yeu_cau_cu_dan/ViewModels/yeu_cau_cu_dan_viewmodel.dart';
import 'package:urbano_manage/core/network/signalr_service.dart';
import 'package:urbano_manage/features/auth/ViewModels/login_viewmodel.dart';
import 'package:urbano_manage/features/auth/Views/auth_gate.dart';
import 'package:urbano_manage/features/dashboard/ViewModels/dashboard_viewmodel.dart';
import 'package:urbano_manage/features/cu_dan/ViewModels/cu_dan_viewmodel.dart';
import 'package:urbano_manage/features/hoa_don/ViewModels/hoa_don_viewmodel.dart';
import 'package:urbano_manage/features/thong_bao/ViewModels/thong_bao_viewmodel.dart';
import 'package:urbano_manage/features/nhan_vien/ViewModels/nhan_vien_viewmodel.dart';
import 'package:urbano_manage/features/can_ho/ViewModels/can_ho_viewmodel.dart';
import 'package:urbano_manage/features/phi_dich_vu/ViewModels/phi_dich_vu_viewmodel.dart';
import 'package:urbano_manage/features/bang_tin/ViewModels/bang_tin_viewmodel.dart';
import 'package:urbano_manage/features/phuong_tien/ViewModels/phuong_tien_viewmodel.dart';
import 'package:urbano_manage/features/nhat_ky_he_thong/ViewModels/nhat_ky_he_thong_viewmodel.dart';
import 'package:urbano_manage/features/tien_ich/ViewModels/tien_ich_viewmodel.dart';
import 'package:urbano_manage/features/dat_lich_tien_ich/ViewModels/dat_lich_tien_ich_viewmodel.dart';
import 'package:urbano_manage/features/lich_su_thanh_toan/ViewModels/lich_su_thanh_toan_viewmodel.dart';
import 'package:urbano_manage/core/services/local_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotificationService.initialize();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );
  final themeProvider = ThemeProvider();
  await themeProvider.loadFromPrefs();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => SignalRService()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => YeuCauCuDanViewModel()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => CuDanViewModel()),
        ChangeNotifierProvider(create: (_) => HoaDonViewModel()),
        ChangeNotifierProvider(create: (_) => ThongBaoViewModel()),
        ChangeNotifierProvider(create: (_) => NhanVienViewModel()),
        ChangeNotifierProvider(create: (_) => CanHoViewModel()),
        ChangeNotifierProvider(create: (_) => PhiDichVuViewModel()),
        ChangeNotifierProvider(create: (_) => BangTinViewModel()),
        ChangeNotifierProvider(create: (_) => PhuongTienViewModel()),
        ChangeNotifierProvider(create: (_) => NhatKyHeThongViewModel()),
        ChangeNotifierProvider(create: (_) => TienIchViewModel()),
        ChangeNotifierProvider(create: (_) => DatLichTienIchViewModel()),
        ChangeNotifierProvider(create: (_) => LichSuThanhToanViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  static final navigatorKey = GlobalKey<NavigatorState>();
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return MaterialApp(
          key: ValueKey(theme.isDarkMode), // Force full rebuild on theme change
          navigatorKey: navigatorKey,
          scaffoldMessengerKey: messengerKey,
          title: 'Urbano Manage',
          theme: ThemeData(
            scaffoldBackgroundColor: AppColors.bgDark,
            canvasColor: AppColors.bgDark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.tealPrimary,
              brightness: theme.isDarkMode ? Brightness.dark : Brightness.light,
            ),
            useMaterial3: true,
          ),
          debugShowCheckedModeBanner: false,
          home: const AuthGate(),
        );
      },
    );
  }
}
