import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile/models/feedback_model.dart';
import 'package:mobile/services/feedback_service.dart';
import 'package:mobile/utils/date_utils.dart';

class VolunteerFeedbacksPage extends StatefulWidget {
  const VolunteerFeedbacksPage({Key? key}) : super(key: key);

  @override
  State<VolunteerFeedbacksPage> createState() => _VolunteerFeedbacksPageState();
}

class _VolunteerFeedbacksPageState extends State<VolunteerFeedbacksPage>
    with SingleTickerProviderStateMixin {
  final FeedbackService _service = FeedbackService();
  TabController? _tabController;

  List<ReviewModel> _reviews = [];
  List<AppreciationModel> _appreciations = [];
  List<VolunteerCommentModel> _comments = [];

  bool _isLoadingReviews = true;
  bool _isLoadingAppreciations = true;
  bool _isLoadingComments = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    _loadReviews();
    _loadAppreciations();
    _loadComments();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoadingReviews = true);
    final data = await _service.getMyReviews();
    if (mounted) {
      setState(() {
        _reviews = data;
        _isLoadingReviews = false;
      });
    }
  }

  Future<void> _loadAppreciations() async {
    setState(() => _isLoadingAppreciations = true);
    final data = await _service.getMyAppreciations();
    if (mounted) {
      setState(() {
        _appreciations = data;
        _isLoadingAppreciations = false;
      });
    }
  }

  Future<void> _loadComments() async {
    setState(() => _isLoadingComments = true);
    final data = await _service.getMyComments();
    if (mounted) {
      setState(() {
        _comments = data;
        _isLoadingComments = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFC),
      appBar: AppBar(
        title: const Text('Đánh giá & Nhận xét'),
        backgroundColor: const Color(0xFF008080),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF008080),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF008080),
              indicatorWeight: 3,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, size: 16),
                      const SizedBox(width: 4),
                      const Text('Đánh giá'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.favorite, size: 16),
                      const SizedBox(width: 4),
                      const Text('Cảm ơn'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.chat_bubble, size: 16),
                      const SizedBox(width: 4),
                      const Text('Nhận xét'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReviewsTab(),
                _buildAppreciationsTab(),
                _buildCommentsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tab 1: Reviews
  Widget _buildReviewsTab() {
    if (_isLoadingReviews) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reviews.isEmpty) {
      return _buildEmptyState(
        icon: Icons.star_border,
        title: 'Chưa có đánh giá',
        subtitle: 'Bạn chưa nhận được đánh giá nào',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReviews,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _reviews.length,
        itemBuilder: (context, index) => _buildReviewCard(_reviews[index]),
      ),
    );
  }

  // Tab 2: Appreciations
  Widget _buildAppreciationsTab() {
    if (_isLoadingAppreciations) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_appreciations.isEmpty) {
      return _buildEmptyState(
        icon: Icons.favorite_border,
        title: 'Chưa có lời cảm ơn',
        subtitle: 'Bạn chưa nhận được lời cảm ơn nào',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAppreciations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _appreciations.length,
        itemBuilder: (context, index) =>
            _buildAppreciationCard(_appreciations[index]),
      ),
    );
  }

  // Tab 3: Comments
  Widget _buildCommentsTab() {
    if (_isLoadingComments) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_comments.isEmpty) {
      return _buildEmptyState(
        icon: Icons.chat_bubble_outline,
        title: 'Chưa có nhận xét',
        subtitle: 'Bạn chưa nhận được nhận xét từ TCXH/Admin',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadComments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _comments.length,
        itemBuilder: (context, index) => _buildCommentCard(_comments[index]),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // Review Card - với rating stars
  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar + Name
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: review.reviewer?.avatarUrl != null
                    ? CachedNetworkImageProvider(review.reviewer!.avatarUrl!)
                    : null,
                child: review.reviewer?.avatarUrl == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewer?.fullName ?? 'Người dùng',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    if (review.activity != null)
                      Text(
                        review.activity!.title,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Rating stars
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < review.rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 20,
              );
            }),
          ),

          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment!,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],

          const SizedBox(height: 8),
          Text(
            DateTimeUtils.formatRelativeTime(review.createdAt.toIso8601String()),
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Appreciation Card - lời cảm ơn
  Widget _buildAppreciationCard(AppreciationModel appreciation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.pink[100]!, width: 2),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: appreciation.sender?.avatarUrl != null
                ? CachedNetworkImageProvider(appreciation.sender!.avatarUrl!)
                : null,
            child: appreciation.sender?.avatarUrl == null
                ? const Icon(Icons.person)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.pink, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${appreciation.sender?.fullName ?? 'Người dùng'} đã cảm ơn bạn',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (appreciation.activity != null)
                  Text(
                    'Hoạt động: ${appreciation.activity!.title}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Text(
                  DateTimeUtils.formatRelativeTime(
                      appreciation.createdAt.toIso8601String()),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Comment Card - từ TCXH/Admin
  Widget _buildCommentCard(VolunteerCommentModel comment) {
    final isAdmin = comment.organizationId == null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAdmin
              ? Colors.orange[100]! // Admin = orange
              : const Color(0xFF008080).withValues(alpha: 0.3), // TCXH = teal
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isAdmin
                      ? Colors.orange[50]
                      : const Color(0xFF008080).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  comment.issuerName,
                  style: TextStyle(
                    color: isAdmin ? Colors.orange[700] : const Color(0xFF008080),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              if (comment.rating != null)
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < comment.rating!
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 18,
                    );
                  }),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Comment text
          Text(
            comment.comment,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 8),
          Text(
            DateTimeUtils.formatRelativeTime(
                comment.createdAt.toIso8601String()),
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
