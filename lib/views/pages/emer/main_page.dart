import 'package:flutter/material.dart';
import 'package:mobile/views/pages/emer/map_requests_page.dart';
import 'package:mobile/views/widget_tree.dart'; // Import để dùng currentUser

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    // Kiểm tra role: Chỉ Volunteer mới xem được map
    final isVolunteer = currentUser?.role == 'VOLUNTEER';

    if (isVolunteer) {
      // Volunteer → Hiển thị bản đồ với các yêu cầu trợ giúp
      return const MapRequestsPage();
    } else {
      // Beneficiary hoặc role khác → Hiển thị trang trống
      return Scaffold(
        appBar: AppBar(
          title: const Text('Bản đồ yêu cầu'),
          backgroundColor: const Color(0xFF008080),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              Text(
                'Tính năng này dành cho Tình nguyện viên',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Chức năng sẽ được bổ sung sau',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }
}
