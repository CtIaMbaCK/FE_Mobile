import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/services/auth_service.dart';

import 'setup_beneficiary_profile.dart';
import 'setup_volunteer_profile.dart';

class RoleSelectionPage extends StatelessWidget {
  final Map<String, dynamic> basicData;

  const RoleSelectionPage({super.key, required this.basicData});

  void _handleRoleChoice(BuildContext context, String role) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF008080)),
      ),
    );

    final authService = AuthService();
    final result = await authService.registerUser({...basicData, "role": role});

    if (context.mounted) Navigator.pop(context);

    if (result != null) {
      String token = result['accessToken'];
      if (context.mounted) {
        if (role == "BENEFICIARY") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SetupBeneficiaryProfile(token: token),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SetupVolunteerProfile(token: token),
            ),
          );
        }
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Đăng ký thất bại hoặc Email đã tồn tại!"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.volunteer_activism,
                size: 80,
                color: Color(0xFF008080),
              ),
              const SizedBox(height: 24),
              Text(
                "Bạn tham gia với vai trò gì?",
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF12151C),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Lựa chọn này giúp chúng tôi hỗ trợ bạn tốt nhất.",
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  color: Colors.grey[600],
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 48),
              _roleCard(
                context,
                title: "Tôi muốn giúp đỡ",
                sub: "Trở thành tình nguyện viên cộng đồng",
                icon: Icons.favorite_rounded,
                role: "VOLUNTEER",
              ),
              const SizedBox(height: 16),
              _roleCard(
                context,
                title: "Tôi cần giúp đỡ",
                sub: "Kết nối với sự hỗ trợ từ cộng đồng",
                icon: Icons.front_hand_rounded,
                role: "BENEFICIARY",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleCard(
    BuildContext context, {
    required String title,
    required String sub,
    required IconData icon,
    required String role,
  }) {
    return InkWell(
      onTap: () => _handleRoleChoice(context, role),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF008080).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: const Color(0xFF008080)),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: const Color(0xFF12151C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sub,
                    style: GoogleFonts.roboto(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
