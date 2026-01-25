import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Logo/Brand
              Text(
                "BetterUS",
                style: GoogleFonts.roboto(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF008080),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Tạo tài khoản",
                style: GoogleFonts.roboto(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF12151C),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Tham gia cộng đồng để bắt đầu tạo sự khác biệt.",
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),

              // Form Inputs
              buildInputLabel("Số điện thoại"),
              buildTextField(
                controller: _phoneController,
                hint: "Nhập số điện thoại của bạn",
                icon: Icons.phone_outlined,
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
                icon: Icons.lock_outline,
                isPass: true,
                isObserved: !_isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              ),

              buildInputLabel("Xác nhận mật khẩu"),
              buildTextField(
                controller: _confirmPasswordController,
                hint: "Nhập lại mật khẩu",
                icon: Icons.history,
                isPass: true,
                isObserved: !_isConfirmedPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmedPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(
                    () => _isConfirmedPasswordVisible =
                        !_isConfirmedPasswordVisible,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Button Tiếp theo
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF008080),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _nextStep,
                  child: Text(
                    "Tiếp theo",
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
                    style: GoogleFonts.roboto(color: Colors.grey[600]),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      "Đăng nhập",
                      style: GoogleFonts.roboto(
                        color: const Color(0xFF008080),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
