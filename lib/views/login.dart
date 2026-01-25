import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/views/register.dart';
import 'package:mobile/views/widget_tree.dart';

// Lưu ý: Đảm bảo buildInputDecoration đã được định nghĩa hoặc import từ file khác.
// Nếu chưa có, tôi thêm một bản đơn giản ở cuối file này.

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
      prefixIcon: Icon(icon, color: const Color(0xFF008080), size: 20),
      labelStyle: GoogleFonts.roboto(color: const Color(0xFF57636C)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: const BorderSide(color: Color(0xFFF1F4F8), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: const BorderSide(color: Color(0xFF008080), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      filled: true,
      fillColor: Colors.white,
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
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );

          // 4. Chuyển hướng vào WidgetTree
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
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xffCC4362),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F4F8),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- LOGO ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 40, 0, 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Color(0xFF008080),
                        child: Icon(
                          Icons.volunteer_activism,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'BetterUS',
                        style: GoogleFonts.roboto(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF101213),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- FORM BOX ---
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'Chào mừng trở lại',
                          style: GoogleFonts.roboto(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Đăng nhập để tiếp tục hành trình ý nghĩa',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.roboto(
                            color: const Color(0xFF57636C),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Input SĐT
                        TextFormField(
                          controller: _phoneController,
                          focusNode: _phoneFocusNode,
                          keyboardType: TextInputType.phone,
                          decoration: _buildDecoration(
                            label: 'Số điện thoại',
                            icon: Icons.phone_android,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Input Mật khẩu
                        TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          obscureText: !_passwordVisible,
                          decoration:
                              _buildDecoration(
                                label: 'Mật khẩu',
                                icon: Icons.lock_outline,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: const Color(0xFF57636C),
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                    () => _passwordVisible = !_passwordVisible,
                                  ),
                                ),
                              ),
                        ),

                        // Quên mật khẩu
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              'Quên mật khẩu?',
                              style: GoogleFonts.roboto(
                                color: const Color(0xFF008080),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        // Nút Đăng nhập
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : onLoginPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF008080),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              elevation: 2,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'ĐĂNG NHẬP',
                                    style: GoogleFonts.roboto(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        // const SizedBox(height: 24),
                        // const Text(
                        //   'hoặc',
                        //   style: TextStyle(color: Color(0xFF57636C)),
                        // ),
                        // const SizedBox(height: 16),

                        // // Google Login
                        // OutlinedButton.icon(
                        //   onPressed: () {},
                        //   icon: const FaIcon(
                        //     FontAwesomeIcons.google,
                        //     size: 18,
                        //     color: Colors.red,
                        //   ),
                        //   label: const Text('Đăng nhập bằng Google'),
                        //   style: OutlinedButton.styleFrom(
                        //     minimumSize: const Size(double.infinity, 50),
                        //     side: const BorderSide(
                        //       color: Color(0xFFF1F4F8),
                        //       width: 2,
                        //     ),
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(50),
                        //     ),
                        //   ),
                        // ),

                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Chưa có tài khoản? '),
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
                              child: const Text(
                                'Đăng ký ngay',
                                style: TextStyle(
                                  color: Color(0xFF008080),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ).animate().fade(duration: 400.ms).moveY(begin: 50, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
