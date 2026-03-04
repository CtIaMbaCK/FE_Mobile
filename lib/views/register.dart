import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile/views/widgets/build_widget.dart';
import 'role_selection_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // textField Controller
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // an hien mat khau va nhap lai mat khau
  bool _isPasswordVisible = false;
  bool _isConfirmedPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin!")),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mật khẩu xác nhận không khớp!")),
      );
      return;
    }

    // 3. Chuyển sang trang chọn Role và truyền data tạm
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoleSelectionPage(
          basicData: {
            "email": _emailController.text.trim(),
            "password": _passwordController.text,
            "phoneNumber": _phoneController.text.trim(),
          },
        ),
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
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- LOGO ---
                    Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipOval(
                                child: Image.asset(
                                  'assets/images/Logo.png',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'BetterUS',
                                style: GoogleFonts.roboto(
                                  fontSize: 32,
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
                                  "Tạo tài khoản",
                                  style: GoogleFonts.roboto(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Tham gia cộng đồng để tạo sự khác biệt",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    color: const Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Form Inputs
                                buildInputLabel("Số điện thoại"),
                                buildTextField(
                                  controller: _phoneController,
                                  hint: "Nhập số điện thoại của bạn",
                                  icon: Icons.phone_android_rounded,
                                  keyboardType: TextInputType.phone,
                                ),

                                buildInputLabel("Địa chỉ Email"),
                                buildTextField(
                                  controller: _emailController,
                                  hint: "Nhập email của bạn",
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                ),

                                buildInputLabel("Mật khẩu"),
                                buildTextField(
                                  controller: _passwordController,
                                  hint: "Nhập mật khẩu",
                                  icon: Icons.lock_outline_rounded,
                                  isPass: true,
                                  isObserved: !_isPasswordVisible,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: const Color(0xFF94A3B8),
                                      size: 22,
                                    ),
                                    onPressed: () => setState(
                                      () => _isPasswordVisible =
                                          !_isPasswordVisible,
                                    ),
                                  ),
                                ),

                                buildInputLabel("Xác nhận mật khẩu"),
                                buildTextField(
                                  controller: _confirmPasswordController,
                                  hint: "Nhập lại mật khẩu",
                                  icon: Icons.lock_reset_rounded,
                                  isPass: true,
                                  isObserved: !_isConfirmedPasswordVisible,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isConfirmedPasswordVisible
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: const Color(0xFF94A3B8),
                                      size: 22,
                                    ),
                                    onPressed: () => setState(
                                      () => _isConfirmedPasswordVisible =
                                          !_isConfirmedPasswordVisible,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Button Tiếp theo
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
                                    onPressed: _nextStep,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF008080),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      "TIẾP THEO",
                                      style: GoogleFonts.roboto(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Login Link
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Đã có tài khoản? ",
                                      style: GoogleFonts.roboto(
                                        color: const Color(0xFF64748B),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: Text(
                                        "Đăng nhập",
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
