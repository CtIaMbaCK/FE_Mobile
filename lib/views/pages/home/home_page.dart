import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/services/volunteer_service.dart';
import 'package:mobile/services/organization_service.dart';
import 'package:mobile/services/blog_service.dart';
import 'package:mobile/services/emergency_service.dart';
import 'package:mobile/services/campaign_service.dart';
import 'package:mobile/models/volunteer_honor_model.dart';
import 'package:mobile/models/organization_model.dart';
import 'package:mobile/models/blog_model.dart';
import 'package:mobile/models/campaign_model.dart';
import 'package:mobile/views/pages/home/blog_page.dart';
import 'package:mobile/views/pages/home/buildCard.dart';
import 'package:mobile/views/pages/home/organization_honor.dart';
import 'package:mobile/views/pages/home/volunteer_card.dart';
import 'package:mobile/views/pages/home/organization_card.dart';
import 'package:mobile/views/pages/activities/activity_page.dart';
import 'package:mobile/utils/date_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Color primaryColor = const Color(0xFF008080);
  final EmergencyService _emergencyService = EmergencyService();

  List<VolunteerHonorModel> _topVolunteers = [];
  List<OrganizationModel> _topOrganizations = [];
  List<BlogModel> _topBlogs = [];
  List<CampaignModel> _topCampaigns = [];
  bool _isLoadingVolunteers = true;
  bool _isLoadingOrgs = true;
  bool _isLoadingBlogs = true;
  bool _isLoadingCampaigns = true;
  bool _isSendingEmergency = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _loadVolunteers();
    _loadOrganizations();
    _loadBlogs();
    _loadCampaigns();
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

  Future<void> _loadCampaigns() async {
    if (!mounted) return;
    setState(() => _isLoadingCampaigns = true);
    final service = CampaignService();
    final campaigns = await service.getRecommendedCampaigns();
    if (!mounted) return;
    setState(() {
      _topCampaigns = campaigns.take(2).toList(); // Chỉ lấy 2 chiến dịch mới nhất
      _isLoadingCampaigns = false;
    });
  }

  Future<void> _sendEmergencySOS() async {
    if (_isSendingEmergency) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận gửi SOS'),
        content: const Text(
          'Bạn có chắc chắn muốn gửi yêu cầu khẩn cấp không? '
          'Hệ thống sẽ thông báo đến các tình nguyện viên gần bạn.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Gửi SOS'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSendingEmergency = true);

    try {
      await _emergencyService.createEmergency(notes: 'Yêu cầu khẩn cấp từ trang chủ');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã gửi yêu cầu khẩn cấp thành công!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSendingEmergency = false);
      }
    }
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
              // Nút SOS - chỉ hiển thị cho BENEFICIARY
              if (user?.role == 'BENEFICIARY')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 100,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF008080),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      onPressed: _isSendingEmergency ? null : _sendEmergencySOS,
                      child: _isSendingEmergency
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.warning_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'CUỘC GỌI KHẨN CẤP',
                                  style: GoogleFonts.roboto(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),

              if (user?.role == 'BENEFICIARY') const SizedBox(height: 36),

              // Section Chiến dịch - chỉ hiển thị cho VOLUNTEER
              if (user?.role == 'VOLUNTEER')
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
                            onTap: () {
                              // Navigate đến ActivityPage với tab Chiến dịch (index 1)
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ActivityPage(
                                    initialTabIndex: 1,
                                  ),
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
                      const SizedBox(height: 16),

                      // Hiển thị chiến dịch từ API
                      _isLoadingCampaigns
                          ? Center(
                              child: CircularProgressIndicator(
                                color: primaryColor,
                              ),
                            )
                          : _topCampaigns.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Text(
                                      'Chưa có chiến dịch nào',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                )
                              : Column(
                                  children: _topCampaigns.map((campaign) {
                                    return Column(
                                      children: [
                                        _buildCampaignCard(campaign),
                                        if (campaign != _topCampaigns.last)
                                          const SizedBox(height: 12),
                                      ],
                                    );
                                  }).toList(),
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
    return DateTimeUtils.formatRelativeTime(dateTimeStr);
  }

  // --- Helper Widgets để code gọn hơn ---

  String _getDistrictName(String district) {
    return district.replaceAll('_', ' ').replaceAll('QUAN', 'Quận');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildCampaignCard(CampaignModel campaign) {
    final spotsLeft = campaign.maxVolunteers - campaign.currentVolunteers;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to campaign detail
            // TODO: Add navigation to campaign detail page
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover image
              if (campaign.coverImage != null)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      Image.network(
                        campaign.coverImage!,
                        width: double.infinity,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                          ),
                          child: const Icon(
                            Icons.campaign,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      // Badge
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.campaign,
                                size: 14,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'CHIẾN DỊCH',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      campaign.title,
                      style: GoogleFonts.interTight(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    // Location
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getDistrictName(campaign.district),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Info row
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 16,
                            color: spotsLeft > 0 ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${campaign.currentVolunteers}/${campaign.maxVolunteers}',
                            style: TextStyle(
                              fontSize: 12,
                              color: spotsLeft > 0 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            ' TNV',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text(
                            _formatDate(campaign.startDate),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
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
}
