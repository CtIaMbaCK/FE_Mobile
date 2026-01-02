import 'package:flutter/material.dart';
import 'package:mobile/services/auth_service.dart';

// Đảm bảo tên file dưới đây trùng khớp với tên file bạn đã tạo trong thư mục
import 'beneficiary_profile_form.dart';
import 'volunteer_profile_form.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authService = AuthService();
  String? _role;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAndRoute();
  }

  Future<void> _fetchAndRoute() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final data = await _authService.getMyProfile();

      if (data != null && mounted) {
        setState(() {
          _role = data['role']; // VOLUNTEER hoặc BENEFICIARY
          _userData = data;
          _isLoading = false;
        });
      } else if (mounted) {
        _handleError();
      }
    } catch (e) {
      if (mounted) _handleError();
    }
  }

  void _handleError() {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Không thể tải thông tin hồ sơ")),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Màn hình loading
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF008080)),
        ),
      );
    }

    // 2. Màn hình lỗi/Thử lại
    if (_userData == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Lỗi tải dữ liệu"),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _fetchAndRoute,
                child: const Text("Thử lại"),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Render Form dựa trên Role
    // Lưu ý: Đảm bảo class BeneficiaryProfileForm đã được định nghĩa trong file tương ứng
    if (_role == "VOLUNTEER") {
      return VolunteerProfileForm(initialData: _userData!);
    } else {
      return BeneficiaryProfileForm(initialData: _userData!);
    }
  }
}
