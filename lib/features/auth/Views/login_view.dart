import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:urbano_manage/features/auth/ViewModels/login_viewmodel.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/core/Widgets/app_button.dart';
import 'package:urbano_manage/core/Widgets/app_text_field.dart';
import 'package:urbano_manage/features/yeu_cau_cu_dan/Views/yeu_cau_cu_dan_view.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: const _LoginViewInner(),
    );
  }
}

class _LoginViewInner extends StatefulWidget {
  const _LoginViewInner();

  @override
  State<_LoginViewInner> createState() => _LoginViewInnerState();
}

class _LoginViewInnerState extends State<_LoginViewInner> {
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColors.bgDark, AppColors.bgMid, AppColors.bgDarkest],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLogoSection(),
                          const SizedBox(height: 20),
                          _buildGreeting(),
                          const SizedBox(height: 24),
                          _buildAccountField(),
                          const SizedBox(height: 24),
                          _buildPassword(),
                          const SizedBox(height: 8),
                          _buildForgetPassword(),
                          const SizedBox(height: 50),
                          _buildButtonLogin(),
                          const SizedBox(height: 24),
                          const Spacer(),
                          _buildBottomNote(),
                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Align(
      alignment: Alignment.topCenter,
      child: Image.asset(
        'assets/images/logo_urbano.png',
        width: double.infinity,
        height: 200,
      ),
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chào mừng trở lại 👋',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18),
        ),
        const SizedBox(height: 4),
        const Text(
          'Đăng nhập tài khoản nhân viên ban quản lý',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountField() {
    return AppTextField(
      label: 'Mã nhân viên / SĐT / Email',
      hint: 'Nhập mã NV, Email hoặc SĐT',
      controller: _accountController,
      prefixIcon: Icons.person_3_rounded,
      keyboardType: TextInputType.text,
    );
  }

  Widget _buildPassword() {
    return AppTextField(
      label: 'Mật khẩu',
      hint: 'Nhập mật khẩu',
      controller: _passwordController,
      prefixIcon: Icons.lock_outline_rounded,
      obscureText: _obscurePassword,
      suffixIcon: GestureDetector(
        onTap: () => setState(() => _obscurePassword = !_obscurePassword),
        child: Icon(
          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 18,
          color: AppColors.iconMuted,
        ),
      ),
    );
  }

  Widget _buildForgetPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // Implement action later
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text(
          'Quên mật khẩu?',
          style: TextStyle(fontSize: 12, color: AppColors.tealPrimary),
        ),
      ),
    );
  }

  Widget _buildButtonLogin() {
    final watchModel = context.watch<LoginViewModel>();
    final isLoading = watchModel.isLoading;

    return AppButton(
      icon: Icons.login_rounded,
      label: isLoading ? 'Đang đăng nhập...' : 'Đăng Nhập',
      isLoading: isLoading,
      onPressed: isLoading
          ? null
          : () async {
              final vm = context.read<LoginViewModel>();
              final result = await vm.login(
                _accountController.text,
                _passwordController.text,
              );
              if (!mounted) return;
              if (result) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const YeuCauCuDanView()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(vm.error ?? 'Đăng nhập thất bại')),
                );
              }
            },
    );
  }

  Widget _buildBottomNote() {
    return Center(
      child: Text.rich(
        TextSpan(
          children: [
            const TextSpan(
              text: 'Gặp sự cố đăng nhập? ',
              style: TextStyle(color: AppColors.textMuted),
            ),
            TextSpan(
              text: 'Liên hệ Kỹ thuật',
              style: const TextStyle(color: AppColors.tealDark),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: AppColors.bgMid,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Hỗ trợ kỹ thuật',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            leading: const Icon(Icons.phone, color: AppColors.tealPrimary),
                            title: const Text('Hotline: 1900 xxxx', style: TextStyle(color: Colors.white)),
                            onTap: () {},
                          ),
                          ListTile(
                            leading: const Icon(Icons.email, color: AppColors.tealPrimary),
                            title: const Text('Email: tech@urbano.vn', style: TextStyle(color: Colors.white)),
                            onTap: () {},
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                  );
                },
            ),
          ],
        ),
      ),
    );
  }
}
