import 'package:flutter/material.dart';
import 'package:mobile/data/notifiers.dart';
import 'package:mobile/views/widget_tree.dart';

class NavbarWidget extends StatelessWidget {
  const NavbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xff008080);

    return ValueListenableBuilder(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedPage, child) {
        return NavigationBarTheme(
          data: NavigationBarThemeData(
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: activeColor);
              }
              return const IconThemeData(color: Colors.grey);
            }),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  color: activeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                );
              }
              return const TextStyle(color: Colors.grey, fontSize: 12);
            }),
            indicatorColor: activeColor.withValues(alpha: 0.1),
          ),

          // --- BẮT ĐẦU SỬA TỪ ĐÂY ---
          child: SizedBox(
            height: 100, 
            child: Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,

              children: [
                NavigationBar(
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home),
                      label: "Trang chủ",
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.schedule),
                      label: "Hoạt động",
                    ),
                    // Item tàng hình để giữ chỗ ở giữa
                    NavigationDestination(
                      icon: Icon(Icons.circle, color: Colors.transparent),
                      label: "",
                      enabled: false,
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.message_outlined),
                      label: "Tin nhắn",
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.person),
                      label: "Hồ Sơ",
                    ),
                  ],
                  onDestinationSelected: (int value) {
                    if (value != 2) {
                      selectedPageNotifier.value = value;
                    }
                  },
                  selectedIndex: selectedPage,
                  backgroundColor: activeColor.withValues(alpha: 0.1),
                  elevation: 3,
                ),

                Positioned(
                  bottom: 30,
                  child: GestureDetector(
                    onTap: () {
                      selectedPageNotifier.value = 2;
                    },
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: activeColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Icon(
                        currentUser?.role == 'BENEFICIARY'
                            ? Icons.emergency
                            : Icons.map,
                        color: selectedPage == 2
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.8),
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
