import 'package:flutter/material.dart';
import 'package:mobile/models/campaign_model.dart';
import 'package:mobile/models/request_model.dart';
import 'package:mobile/services/campaign_service.dart';
import 'package:mobile/services/request_service.dart';
import 'package:mobile/views/pages/activities/campaign_detail_page.dart';
import 'package:mobile/views/pages/activities/registered_activities_page.dart';
import 'package:mobile/views/pages/activities/request_detail_page.dart';

class VolunteerActivityPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const VolunteerActivityPage({super.key, required this.userData});

  @override
  State<VolunteerActivityPage> createState() => _VolunteerActivityPageState();
}

class _VolunteerActivityPageState extends State<VolunteerActivityPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final RequestService _requestService = RequestService();
  final CampaignService _campaignService = CampaignService();

  List<HelpRequestModel> _requests = [];
  List<CampaignModel> _campaigns = [];
  bool _isLoadingRequests = false;
  bool _isLoadingCampaigns = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRequests();
    _loadCampaigns();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoadingRequests = true);
    try {
      final requests = await _requestService.getPendingRequests();
      if (mounted) {
        setState(() {
          _requests = requests;
          _isLoadingRequests = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingRequests = false);
      }
    }
  }

  Future<void> _loadCampaigns() async {
    setState(() => _isLoadingCampaigns = true);
    try {
      final campaigns = await _campaignService.getRecommendedCampaigns();
      if (mounted) {
        setState(() {
          _campaigns = campaigns;
          _isLoadingCampaigns = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCampaigns = false);
      }
    }
  }

  void _onRegisteredActivitiesPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegisteredActivitiesPage(),
      ),
    ).then((value) {
      if (value == true) {
        _loadRequests();
        _loadCampaigns();
      }
    });
  }

  void _onRequestCardPressed(HelpRequestModel request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestDetailPage(request: request),
      ),
    ).then((value) {
      if (value == true) {
        _loadRequests();
      }
    });
  }

  void _onCampaignCardPressed(CampaignModel campaign) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CampaignDetailPage(campaign: campaign),
      ),
    ).then((value) {
      if (value == true) {
        _loadCampaigns();
      }
    });
  }

  String _getActivityTypeName(String type) {
    const types = {
      'EDUCATION': 'Giáo dục',
      'MEDICAL': 'Y tế',
      'HOUSE_WORK': 'Công việc nhà',
      'TRANSPORT': 'Đi lại',
      'FOOD': 'Thực phẩm',
      'SHELTER': 'Nhà ở',
      'OTHER': 'Khác',
    };
    return types[type] ?? type;
  }

  String _getDistrictName(String district) {
    return district.replaceAll('_', ' ').replaceAll('QUAN', 'Quận');
  }

  String _formatDateTime(DateTime date, DateTime time) {
    return '${date.day}/${date.month}/${date.year} - ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFC),
      body: SafeArea(
        child: Column(
          children: [
            // Nút "Hoạt động đã đăng ký"
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _onRegisteredActivitiesPressed,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF8FCFC),
                    foregroundColor: const Color(0xFF008080),
                    side: const BorderSide(color: Color(0xFF008080)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Các hoạt động đã đăng ký',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // TabBar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: const Color(0xFF008080),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF004B4B),
                  labelStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: const [
                    Tab(text: 'Yêu cầu trợ giúp'),
                    Tab(text: 'Chiến dịch'),
                  ],
                ),
              ),
            ),

            // TabBarView
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Help Requests
                  _buildRequestsList(),

                  // Tab 2: Campaigns
                  _buildCampaignsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList() {
    if (_isLoadingRequests) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chưa có yêu cầu nào',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final request = _requests[index];
          return _buildRequestCard(request);
        },
      ),
    );
  }

  Widget _buildCampaignsList() {
    if (_isLoadingCampaigns) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_campaigns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.campaign, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chưa có chiến dịch nào',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCampaigns,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _campaigns.length,
        itemBuilder: (context, index) {
          final campaign = _campaigns[index];
          return _buildCampaignCard(campaign);
        },
      ),
    );
  }

  Widget _buildRequestCard(HelpRequestModel request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _onRequestCardPressed(request),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tag + Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: request.urgencyLevel == 'CRITICAL'
                          ? Colors.red
                          : const Color(0xFF008080),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      request.urgencyLevel == 'CRITICAL'
                          ? 'KHẨN CẤP'
                          : 'YÊU CẦU',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Text(
                request.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              // Location
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.orange),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${request.addressDetail}, ${_getDistrictName(request.district)}',
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Info row
              Row(
                children: [
                  const Icon(Icons.category, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    _getActivityTypeName(request.activityType),
                    style: const TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.schedule, size: 16, color: Colors.purple),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(request.startDate, request.startTime),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCampaignCard(CampaignModel campaign) {
    final spotsLeft = campaign.maxVolunteers - campaign.currentVolunteers;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _onCampaignCardPressed(campaign),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            if (campaign.coverImage != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  campaign.coverImage!,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: const Icon(Icons.campaign, size: 50),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'CHIẾN DỊCH',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    campaign.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Organization
                  if (campaign.organization != null)
                    Row(
                      children: [
                        const Icon(Icons.business, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            campaign.organization!.organizationName ?? 'Tổ chức xã hội',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),

                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.orange),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${campaign.addressDetail}, ${_getDistrictName(campaign.district)}',
                          style: const TextStyle(fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Info row
                  Row(
                    children: [
                      const Icon(Icons.people, size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        '${campaign.currentVolunteers}/${campaign.maxVolunteers} TNV (còn $spotsLeft chỗ)',
                        style: TextStyle(
                          fontSize: 12,
                          color: spotsLeft > 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _formatDate(campaign.startDate),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
