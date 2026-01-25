import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/data/notifiers.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/views/login.dart';
import 'volunteer_profile_edit_form.dart';

class SettingsPage extends StatelessWidget {
  final Map<String, dynamic> userData;

  const SettingsPage({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFC),
      appBar: AppBar(
        title: Text(
          'Cài đặt',
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Menu item: Thông tin người dùng
            _buildMenuItem(
              context: context,
              icon: Icons.person_outline,
              title: 'Thông tin người dùng',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VolunteerProfileEditForm(
                      initialData: userData,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // Menu item: Đăng xuất
            _buildMenuItem(
              context: context,
              icon: Icons.logout,
              title: 'Đăng xuất',
              iconColor: Colors.red.shade400,
              titleColor: Colors.red.shade400,
              onTap: () async {
                // Hiển thị dialog xác nhận
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      'Xác nhận đăng xuất',
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Hủy'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Đăng xuất'),
                      ),
                    ],
                  ),
                );

                if (shouldLogout == true) {
                  await authService.logout();
                  selectedPageNotifier.value = 0;

                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                      (route) => false,
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (iconColor ?? const Color(0xFF008080)).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? const Color(0xFF008080),
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: titleColor ?? Colors.black87,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 24,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
