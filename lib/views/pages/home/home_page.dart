import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile/dummy/dummyData.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/views/pages/home/blog_page.dart';
import 'package:mobile/views/pages/home/buildCard.dart';
import 'package:mobile/views/pages/home/organization_honor.dart';
import 'package:mobile/views/pages/home/volunteer_honor.dart'; // Import Service

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Color primaryColor = const Color(0xFF008080);

  @override
  Widget build(BuildContext context) {
    // Lấy data thật từ bộ nhớ static
    final user = AuthService.currentUser;
    // print(user);
    final profile = user?.profile;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Avatar & Name
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 55,
                          height: 55,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Color(0xff0008080),
                              width: 1,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundImage: CachedNetworkImageProvider(
                              profile?.avatarUrl ??
                                  "https://ui-avatars.com/api/?name=${profile?.fullName ?? 'U'}&background=008080&color=fff",
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Xin chào',
                                  style: TextStyle(
                                    color: Color(0xff008080),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  profile?.fullName ?? 'Người dùng',
                                  style: GoogleFonts.interTight(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              user?.role == 'VOLUNTEER'
                                  ? 'Tình nguyện viên'
                                  : 'Người cần giúp đỡ',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.notifications_outlined,
                        color: primaryColor,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              // Nút SOS dùng ID thật
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 100,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () =>
                        print("Gửi yêu cầu khẩn cấp cho ID: ${user?.id}"),
                    child: Text(
                      'CUỘC GỌI KHẨN CẤP',
                      style: GoogleFonts.interTight(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // Bạn có thể thêm các phần EventCard bên dưới như code cũ của bạn...
              // Padding(
              //   padding: const EdgeInsets.all(20.0),
              //   child: Text(
              //     "ID của bạn: ${user?.id ?? 'N/A'}",
              //     style: TextStyle(color: Colors.grey, fontSize: 10),
              //   ),
              // ),
              const SizedBox(height: 36),

              // chien dich
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sự kiện đang diễn ra',
                          style: GoogleFonts.interTight(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        InkWell(
                          onTap: () {},
                          child: Row(
                            children: [
                              Text(
                                'Xem tất cả',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: primaryColor,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Event Card 1
                    _buildEventCard(
                      icon: Icons.waves,
                      title: 'Beach Cleanup',
                      subtitle: 'Join us for ocean conservation',
                      time: 'Today, 2:00 PM',
                    ),
                    const SizedBox(height: 12),

                    // Event Card 2
                    _buildEventCard(
                      icon: Icons.favorite,
                      title: 'Charity Drive',
                      subtitle: 'Help families in need',
                      time: 'Tomorrow, 9:00 AM',
                    ),
                  ],
                ),
              ),

              // to chuc
              const SizedBox(height: 36),

              // Vinh danh to chuc xa hoi
              Container(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    spacing: 12,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Vinh danh Tổ Chức Xã Hội',
                            style: GoogleFonts.interTight(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),

                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return OrganizationHonor();
                                  },
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Xem tất cả',
                                  style: GoogleFonts.interTight(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff008080),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: Color(0xff008080),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return OrganizationHonor();
                                    },
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  // color: Colors.red,
                                ),
                                width: double.infinity,
                                height: 260,
                                child: SingleChildScrollView(
                                  padding: EdgeInsets.symmetric(vertical: 10.0),
                                  child: Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 11,
                                    runSpacing: 13,
                                    children: dummyVolunteer.map((item) {
                                      return Container(
                                        width: 180,
                                        child: buildOrganizationCard(
                                          Icons.ac_unit,
                                          item.name,
                                          item.campaigns,
                                          item.imageUrl,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Vinh danh Tình nguyện Viên
              Container(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    spacing: 12,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Vinh danh Tình Nguyện Viên',
                            style: GoogleFonts.interTight(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),

                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return VolunteerHonor();
                                  },
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Xem tất cả',
                                  style: GoogleFonts.interTight(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff008080),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: Color(0xff008080),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return VolunteerHonor();
                                    },
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  // color: Colors.red,
                                ),
                                width: double.infinity,
                                height: 260,
                                child: SingleChildScrollView(
                                  padding: EdgeInsets.symmetric(vertical: 10.0),
                                  child: Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 11,
                                    runSpacing: 13,
                                    children: dummyVolunteer.map((item) {
                                      return Container(
                                        width: 180,
                                        child: buildOrganizationCard(
                                          Icons.ac_unit,
                                          item.name,
                                          item.campaigns,
                                          item.imageUrl,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // blog tin tuc
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Blog và Tin tức',
                          style: GoogleFonts.interTight(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),

                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return BlogPage();
                                    },
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Text(
                                    'Xem tất cả',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: primaryColor,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    buildBlogItem(
                      //  thay băng url sau khi dua len cloudinary
                      imageUrl:
                          'https://images.unsplash.com/photo-1600818272779-cfa6145222f0?fit=crop&w=200',
                      title: 'Volunteer Impact Report 2024',
                      desc: 'See how volunteers made a difference this year',
                      time: '2 hours ago',
                    ),
                    const SizedBox(height: 12),

                    buildBlogItem(
                      imageUrl:
                          'https://images.unsplash.com/photo-1600818272779-cfa6145222f0?fit=crop&w=200',
                      title: 'Community Garden Project Launch',
                      desc: 'New initiative to create green spaces',
                      time: '1 day ago',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets để code gọn hơn ---

  Widget _buildEventCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.interTight(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.schedule, color: primaryColor, size: 16),
              const SizedBox(width: 8),
              Text(
                time,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
