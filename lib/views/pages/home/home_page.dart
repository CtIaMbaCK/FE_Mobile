import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/services/volunteer_service.dart';
import 'package:mobile/services/organization_service.dart';
import 'package:mobile/services/blog_service.dart';
import 'package:mobile/models/volunteer_honor_model.dart';
import 'package:mobile/models/organization_model.dart';
import 'package:mobile/models/blog_model.dart';
import 'package:mobile/views/pages/home/blog_page.dart';
import 'package:mobile/views/pages/home/buildCard.dart';
import 'package:mobile/views/pages/home/organization_honor.dart';
import 'package:mobile/views/pages/home/volunteer_card.dart';
import 'package:mobile/views/pages/home/organization_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Color primaryColor = const Color(0xFF008080);

  List<VolunteerHonorModel> _topVolunteers = [];
  List<OrganizationModel> _topOrganizations = [];
  List<BlogModel> _topBlogs = [];
  bool _isLoadingVolunteers = true;
  bool _isLoadingOrgs = true;
  bool _isLoadingBlogs = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _loadVolunteers();
    _loadOrganizations();
    _loadBlogs();
  }

  Future<void> _loadVolunteers() async {
    if (!mounted) return;
    setState(() => _isLoadingVolunteers = true);
    final service = VolunteerService();
    final volunteers = await service.getTopVolunteers(limit: 3);
    if (!mounted) return;
    setState(() {
      _topVolunteers = volunteers;
      _isLoadingVolunteers = false;
    });
  }

  Future<void> _loadOrganizations() async {
    if (!mounted) return;
    setState(() => _isLoadingOrgs = true);
    final service = OrganizationService();
    final orgs = await service.getTopOrganizations(limit: 5);
    if (!mounted) return;
    setState(() {
      _topOrganizations = orgs;
      _isLoadingOrgs = false;
    });
  }

  Future<void> _loadBlogs() async {
    if (!mounted) return;
    setState(() => _isLoadingBlogs = true);
    final service = BlogService();
    final blogs = await service.getTopBlogs(limit: 2);
    if (!mounted) return;
    setState(() {
      _topBlogs = blogs;
      _isLoadingBlogs = false;
    });
  }

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
                        width: double.infinity,
                        height: 300,
                        child: _isLoadingOrgs
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: primaryColor,
                                ),
                              )
                            : _topOrganizations.isEmpty
                                ? Center(
                                    child: Text(
                                      'Chưa có dữ liệu',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: _topOrganizations.length,
                                    itemBuilder: (context, index) {
                                      final org = _topOrganizations[index];
                                      return InkWell(
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
                                        child: buildOrganizationHonorCard(org),
                                      );
                                    },
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
                      Text(
                        'Vinh danh Tình Nguyện Viên',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      Container(
                        width: double.infinity,
                        height: 290,
                        child: _isLoadingVolunteers
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: primaryColor,
                                ),
                              )
                            : _topVolunteers.isEmpty
                                ? Center(
                                    child: Text(
                                      'Chưa có dữ liệu',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: _topVolunteers.length,
                                    itemBuilder: (context, index) {
                                      final volunteer = _topVolunteers[index];
                                      return buildVolunteerHonorCard(
                                        volunteer,
                                        rank: index + 1,
                                      );
                                    },
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

                    _isLoadingBlogs
                        ? Center(
                            child: CircularProgressIndicator(
                              color: primaryColor,
                            ),
                          )
                        : _topBlogs.isEmpty
                            ? Center(
                                child: Text(
                                  'Chưa có dữ liệu',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : Column(
                                children: _topBlogs.map((blog) {
                                  return Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          // Navigate to blog detail (chưa có page)
                                          // Navigator.push(context, MaterialPageRoute(
                                          //   builder: (context) => BlogDetailPage(blogId: blog.id),
                                          // ));
                                        },
                                        child: buildBlogItem(
                                          imageUrl: blog.coverImage ??
                                              'https://images.unsplash.com/photo-1600818272779-cfa6145222f0?fit=crop&w=200',
                                          title: blog.title,
                                          desc: blog.content != null && blog.content!.length > 100
                                              ? '${blog.content!.substring(0, 100)}...'
                                              : blog.content ?? 'Chưa có mô tả',
                                          time: _formatTime(blog.createdAt),
                                        ),
                                      ),
                                      if (blog != _topBlogs.last)
                                        const SizedBox(height: 12),
                                    ],
                                  );
                                }).toList(),
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

  // --- Helper Methods ---

  String _formatTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} phút trước';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} giờ trước';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} ngày trước';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return 'Vừa xong';
    }
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
