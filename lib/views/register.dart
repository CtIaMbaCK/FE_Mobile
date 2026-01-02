import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'role_selection_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // --- Controllers ---
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Biến điều khiển ẩn/hiện mật khẩu
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _nextStep() {
    // 1. Kiểm tra rỗng
    if (_emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin!")),
      );
      return;
    }

    // 2. So sánh mật khẩu
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
                style: GoogleFonts.readexPro(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF008080),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Tạo tài khoản",
                style: GoogleFonts.readexPro(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF12151C),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Tham gia cộng đồng để bắt đầu tạo sự khác biệt.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),

              // Form Inputs
              _buildInputLabel("Số điện thoại"),
              _buildTextField(
                controller: _phoneController,
                hint: "Nhập số điện thoại của bạn",
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),

              _buildInputLabel("Địa chỉ Email"),
              _buildTextField(
                controller: _emailController,
                hint: "Nhập email của bạn",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              _buildInputLabel("Mật khẩu"),
              _buildTextField(
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

              _buildInputLabel("Xác nhận mật khẩu"),
              _buildTextField(
                controller: _confirmPasswordController,
                hint: "Nhập lại mật khẩu",
                icon:
                    Icons.history, // Icon đồng hồ/lịch sử theo yêu cầu của bạn
                isPass: true,
                isObserved: true, // Luôn ẩn mật khẩu xác nhận
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
                    style: GoogleFonts.inter(
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
                    style: GoogleFonts.inter(color: Colors.grey[600]),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      "Đăng nhập",
                      style: GoogleFonts.inter(
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

  // Helper Widget: Tiêu đề cho mỗi ô nhập
  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: const Color(0xFF12151C),
          ),
        ),
      ),
    );
  }

  // Helper Widget: TextField chung
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPass = false,
    bool isObserved = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextField(
        controller: controller,
        obscureText: isObserved,
        keyboardType: keyboardType,
        style: GoogleFonts.inter(fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFF008080), size: 20),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: const Color(0xFFF1F4F8),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF008080), width: 1.5),
          ),
        ),
      ),
    );
  }
}
