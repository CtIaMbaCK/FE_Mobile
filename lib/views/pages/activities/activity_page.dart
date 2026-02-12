import 'package:flutter/material.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/views/pages/activities/beneficiary_activity.dart';
import 'package:mobile/views/pages/activities/volunteer_activity.dart';


class ActivityPage extends StatefulWidget {
  final int initialTabIndex;

  const ActivityPage({super.key, this.initialTabIndex = 0});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
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
      const SnackBar(content: Text("Không thể tải thông tin hoạt động")),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Màn hình loading
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FCFC),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF008080)),
        ),
      );
    }

    // 2. Màn hình lỗi/Thử lại
    if (_userData == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FCFC),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                "Lỗi tải dữ liệu",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _fetchAndRoute,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF008080),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Thử lại"),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Render Activity Page dựa trên Role
    if (_role == "VOLUNTEER") {
      return VolunteerActivityPage(
        userData: _userData!,
        initialTabIndex: widget.initialTabIndex,
      );
    } else if (_role == "BENEFICIARY") {
      return BeneficiaryActivityPage(userData: _userData!);
    } else {
      // Fallback cho role không xác định
      return Scaffold(
        backgroundColor: const Color(0xFFF8FCFC),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_circle_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                "Role không xác định: ${_role ?? 'null'}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
