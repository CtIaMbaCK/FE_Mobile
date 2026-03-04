import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/services/chat/chat_socket_service.dart';
import 'package:mobile/views/register.dart';
import 'package:mobile/views/widget_tree.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _passwordVisible = false;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  InputDecoration _buildDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF008080), size: 22),
      labelStyle: GoogleFonts.roboto(
        color: const Color(0xFF64748B),
        fontWeight: FontWeight.w500,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF008080), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
    );
  }

  // --- LOGIC ĐĂNG NHẬP ĐÃ SỬA ---
  Future<void> onLoginPressed() async {
    // 1. Kiểm tra đầu vào
    String phone = _phoneController.text.trim();
    String password = _passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      _showErrorSnackBar('Vui lòng nhập đầy đủ thông tin!');
      return;
    }

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      // 2. Gọi service đăng nhập
      // Hàm này sẽ lưu Token và tự gọi luôn hàm getMe() để lấy Profile
      bool success = await _authService.login(phone, password);

      if (!mounted) return;

      if (success) {
        // 3. Kiểm tra xem đã lấy được Profile chưa (để tránh lỗi null ở trang sau)
        if (AuthService.currentUser != null) {
          // Lấy tên từ profile
          final profile = AuthService.currentUser!.profile;
          String name = profile?.fullName ?? "Thành viên";

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Chào mừng $name trở lại!'),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );

          // 4. Tái kết nối Socket với token mới (fix lỗi đổi tài khoản)
          ChatSocketService().reinitialize();

          // 5. Chuyển hướng vào WidgetTree
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const WidgetTree()),
            (route) => false,
          );
        } else {
          _showErrorSnackBar('Không thể lấy thông tin người dùng');
        }
      }
    } catch (error) {
      // Hiển thị lỗi từ Backend (ví dụ: "Sai mật khẩu", "Số điện thoại không tồn tại")
      String errorMessage = error.toString();
      // Xóa "Exception: " prefix
      errorMessage = errorMessage.replaceAll('Exception: ', '');
      _showErrorSnackBar(errorMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Stack(
          children: [
            // Background Decorative Elements for Soft UI
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF008080).withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -100,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF008080).withValues(alpha: 0.08),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- LOGO ---
                    Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 40),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipOval(
                                child: Image.asset(
                                  'assets/images/Logo.png',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'BetterUS',
                                style: GoogleFonts.roboto(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF0F172A),
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fade(duration: 500.ms)
                        .slideY(begin: -0.2, end: 0),

                    // --- FORM BOX ---
                    Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 500),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF008080,
                                  ).withValues(alpha: 0.06),
                                  blurRadius: 40,
                                  offset: const Offset(0, 20),
                                  spreadRadius: -5,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Chào mừng trở lại',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.roboto(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Đăng nhập để tiếp tục hành trình ý nghĩa',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.roboto(
                                    fontSize: 15,
                                    color: const Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Input SĐT
                                TextFormField(
                                  controller: _phoneController,
                                  focusNode: _phoneFocusNode,
                                  keyboardType: TextInputType.phone,
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF334155),
                                  ),
                                  decoration: _buildDecoration(
                                    label: 'Số điện thoại',
                                    icon: Icons.phone_android_rounded,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Input Mật khẩu
                                TextFormField(
                                  controller: _passwordController,
                                  focusNode: _passwordFocusNode,
                                  obscureText: !_passwordVisible,
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF334155),
                                  ),
                                  decoration:
                                      _buildDecoration(
                                        label: 'Mật khẩu',
                                        icon: Icons.lock_outline_rounded,
                                      ).copyWith(
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _passwordVisible
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: const Color(0xFF94A3B8),
                                            size: 22,
                                          ),
                                          onPressed: () => setState(
                                            () => _passwordVisible =
                                                !_passwordVisible,
                                          ),
                                        ),
                                      ),
                                ),

                                // Quên mật khẩu
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {},
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 16,
                                      ),
                                    ),
                                    child: Text(
                                      'Quên mật khẩu?',
                                      style: GoogleFonts.roboto(
                                        color: const Color(0xFF008080),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Nút Đăng nhập
                                Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF008080,
                                        ).withValues(alpha: 0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _isLoading
                                        ? null
                                        : onLoginPressed,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF008080),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : Text(
                                            'ĐĂNG NHẬP',
                                            style: GoogleFonts.roboto(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                  ),
                                ),

                                const SizedBox(height: 32),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Chưa có tài khoản? ',
                                      style: GoogleFonts.roboto(
                                        color: const Color(0xFF64748B),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return RegisterPage();
                                            },
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Đăng ký ngay',
                                        style: GoogleFonts.roboto(
                                          color: const Color(0xFF008080),
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                        .animate()
                        .fade(duration: 600.ms, delay: 200.ms)
                        .slideY(begin: 0.1, end: 0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
