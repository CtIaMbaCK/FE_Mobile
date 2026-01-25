import 'package:flutter/material.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/views/widgets/modern_ui_widgets.dart';

import 'beneficiary_profile_form.dart';
import 'volunteer_profile_view.dart';

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
        print("=== DEBUG PROFILE_PAGE ===");
        print("Full data: $data");
        print("Role: ${data['role']}");
        print("FullName: ${data['fullName']}");
        print("AvatarUrl: ${data['avatarUrl']}");

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
    // 1. Màn hình loading với shimmer
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FCFC),
        body: ProfileAvatarShimmer(),
      );
    }

    // 2. Màn hình lỗi/Thử lại
    if (_userData == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FCFC),
        body: RefreshIndicator(
          onRefresh: _fetchAndRoute,
          color: const Color(0xFF008080),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Color(0xFF008080),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Không thể tải dữ liệu",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Kéo xuống để thử lại",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF008080),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _fetchAndRoute,
                      child: const Text(
                        "Thử lại",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // 3. Render Form dựa trên Role
    if (_role == "VOLUNTEER") {
      return VolunteerProfileView(userData: _userData!);
    } else if (_role == "BENEFICIARY") {
      return BeneficiaryProfileEditForm(initialData: _userData!);
    } else {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FCFC),
        body: Center(
          child: Text("Role không hợp lệ"),
        ),
      );
    }
  }
}
