import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/views/widgets/modern_ui_widgets.dart';
import 'settings_page.dart';
import 'volunteer_activity_history_page.dart';
import 'volunteer_certificates_page.dart';

class VolunteerProfileView extends StatefulWidget {
  final Map<String, dynamic> userData;

  const VolunteerProfileView({super.key, required this.userData});

  @override
  State<VolunteerProfileView> createState() => _VolunteerProfileViewState();
}

class _VolunteerProfileViewState extends State<VolunteerProfileView>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  late Map<String, dynamic> _userData;
  bool _isRefreshing = false;
  late AnimationController _animationController;

  // Cache cho avatar để refresh
  String? _cachedAvatarUrl;
  String? _cachedFullName;
  int? _cachedPoints;
  int? _cachedTotalThanks;
  String? _cachedBio;

  @override
  void initState() {
    super.initState();
    _userData = widget.userData;
    _updateCachedData();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animationController.forward();
  }

  void _updateCachedData() {
    _cachedFullName = _userData['fullName'];
    _cachedAvatarUrl = _userData['avatarUrl'];
    final profile = _userData['volunteerProfile'] ?? {};
    _cachedBio = profile['bio'];
    _cachedPoints = profile['points'];
    _cachedTotalThanks = profile['totalThanks'];
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refreshProfile() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);

    try {
      final data = await _authService.getMyProfile();
      if (data != null && mounted) {
        setState(() {
          _userData = data;
          _updateCachedData(); // ← Cập nhật cache mới
          _isRefreshing = false;
        });

        // Reset animation
        _animationController.reset();
        _animationController.forward();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã cập nhật thông tin mới nhất'),
              backgroundColor: Color(0xFF008080),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRefreshing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải dữ liệu: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFC),
      appBar: AppBar(
        title: Text(
          'Hồ sơ của tôi',
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF008080),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF008080)),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(userData: _userData),
                ),
              );

              // Nếu có cập nhật từ settings, refresh lại
              if (result == true && mounted) {
                _refreshProfile();
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        color: const Color(0xFF008080),
        backgroundColor: Colors.white,
        displacement: 40,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            children: [
              const SizedBox(height: 32),

              // Avatar Section với animation - Dùng cached data
              StaggeredListItem(
                index: 0,
                child: _buildAvatarSection(_cachedAvatarUrl),
              ),

              const SizedBox(height: 32),

              // Name & Bio Card - Dùng cached data
              StaggeredListItem(
                index: 1,
                child: _buildNameBioCard(
                  _cachedFullName ?? 'Tình nguyện viên',
                  _cachedBio ?? 'Chưa có giới thiệu',
                ),
              ),

              const SizedBox(height: 24),

              // Achievement Cards - Dùng cached data
              StaggeredListItem(
                index: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      // Điểm tình nguyện Card
                      Expanded(
                        child: _buildAchievementCard(
                          icon: Icons.emoji_events,
                          iconColor: const Color(0xFFFFA000),
                          iconBackground: Colors.amber[50]!,
                          value: (_cachedPoints ?? 0).toString(),
                          label: 'Điểm tình nguyện',
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Lượt cảm ơn Card
                      Expanded(
                        child: _buildAchievementCard(
                          icon: Icons.favorite,
                          iconColor: const Color(0xFFE91E63),
                          iconBackground: Colors.pink[50]!,
                          value: (_cachedTotalThanks ?? 0).toString(),
                          label: 'Lượt cảm ơn',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Navigation Cards
              StaggeredListItem(
                index: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildNavigationCard(
                        icon: Icons.history,
                        iconColor: const Color(0xFF2196F3),
                        iconBackground: Colors.blue[50]!,
                        title: 'Lịch sử hoạt động',
                        subtitle: 'Xem các hoạt động đã tham gia',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const VolunteerActivityHistoryPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildNavigationCard(
                        icon: Icons.workspace_premium,
                        iconColor: const Color(0xFFFFA000),
                        iconBackground: Colors.amber[50]!,
                        title: 'Chứng nhận',
                        subtitle: 'Xem và lưu chứng nhận của bạn',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const VolunteerCertificatesPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // Avatar Section với border, shadow và cached image
  Widget _buildAvatarSection(String? avatarUrl) {
    return FadeTransition(
      opacity: _animationController,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF008080).withOpacity(0.2),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF008080),
                width: 3,
              ),
              color: Colors.white,
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFFE0F2F1),
              backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                  ? CachedNetworkImageProvider(avatarUrl)
                  : null,
              child: (avatarUrl == null || avatarUrl.isEmpty)
                  ? const Icon(
                      Icons.person_outline,
                      size: 60,
                      color: Color(0xFF008080),
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  // Name & Bio Card với glassmorphism
  Widget _buildNameBioCard(String fullName, String bio) {
    return GlassMorphismCard(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      backgroundColor: Colors.white.withOpacity(0.95),
      blur: 15,
      child: Column(
        children: [
          Text(
            fullName,
            style: GoogleFonts.roboto(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF008080).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.volunteer_activism,
                  size: 16,
                  color: Color(0xFF008080),
                ),
                const SizedBox(width: 6),
                Text(
                  'Tình nguyện viên',
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF008080),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FCFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF008080).withOpacity(0.1),
              ),
            ),
            child: Text(
              bio,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Achievement Card với glassmorphism và animation
  Widget _buildAchievementCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String value,
    required String label,
  }) {
    return GlassMorphismCard(
      padding: const EdgeInsets.all(20),
      backgroundColor: Colors.white.withOpacity(0.95),
      blur: 15,
      child: Column(
        children: [
          // Icon tròn với background màu pastel
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 32,
              color: iconColor,
            ),
          ),

          const SizedBox(height: 16),

          // Số liệu lớn với animation
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: int.tryParse(value) ?? 0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, child) {
              return Text(
                animatedValue.toString(),
                style: GoogleFonts.roboto(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: -1,
                ),
              );
            },
          ),

          const SizedBox(height: 6),

          // Label nhỏ
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Navigation Card - để navigate đến các trang mới
  Widget _buildNavigationCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GlassMorphismCard(
      padding: EdgeInsets.zero,
      backgroundColor: Colors.white.withValues(alpha: 0.95),
      blur: 15,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
