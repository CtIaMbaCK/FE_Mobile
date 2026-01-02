import 'package:flutter/material.dart';
import 'package:mobile/data/notifiers.dart';
import 'package:mobile/models/user_model.dart'; // Đảm bảo bạn có file này
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/views/welcome_page.dart'; // Import trang Onboarding
import 'package:mobile/views/pages/activities/activity_page.dart';
import 'package:mobile/views/pages/home/home_page.dart';
import 'package:mobile/views/pages/main_page.dart';
import 'package:mobile/views/pages/profile/profile_page.dart';
import 'package:mobile/views/pages/user_message.dart';
import 'package:mobile/views/widgets/navbar_widget.dart';

// Biến toàn cục để lưu user hiện tại (Để truy cập ở các trang con)
// Bạn nên để cái này trong một file riêng như user_manager.dart hoặc trong notifiers.dart
UserModel? currentUser; 

List<Widget> pages = [
  const HomePage(),
  const ActivityPage(),
  const MainPage(),
  const UserMessage(),
  const ProfilePage(),
];

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  final AuthService _authService = AuthService();
  // Tạo biến Future để tránh việc hàm getMe() bị gọi lại liên tục khi rebuild
  late Future<UserModel?> _userFuture;

  @override
  void initState() {
    super.initState();
    // Gọi hàm lấy thông tin user 1 lần duy nhất khi Widget được tạo
    _userFuture = _authService.getMe();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: _userFuture,
      builder: (context, snapshot) {
        // 1. Đang tải: Hiện màn hình Splash hoặc Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8FCFC),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Có dữ liệu: User đã đăng nhập
        if (snapshot.hasData && snapshot.data != null) {
          // QUAN TRỌNG: Lưu user vào biến toàn cục để dùng ở HomePage, ProfilePage...
          currentUser = snapshot.data; 

          return Scaffold(
            body: ValueListenableBuilder(
              valueListenable: selectedPageNotifier,
              builder: (context, selectedPage, child) {
                return pages[selectedPage];
              },
            ),
            bottomNavigationBar: const NavbarWidget(),
          );
        }

        // 3. Không có dữ liệu (Chưa đăng nhập hoặc lỗi): Về Onboarding hoặc Login
        // Bạn có thể chọn về LoginPage() luôn hoặc OnBoardingPage() tùy logic
        return const OnBoardingPage(); 
      },
    );
  }
}