import 'package:flutter/material.dart';
import 'package:mobile/models/campaign_model.dart';
import 'package:mobile/models/request_model.dart';
import 'package:mobile/services/campaign_service.dart';
import 'package:mobile/services/request_service.dart';
import 'package:mobile/views/pages/activities/campaign_detail_page.dart';
import 'package:mobile/views/pages/activities/request_detail_page.dart';

class RegisteredActivitiesPage extends StatefulWidget {
  const RegisteredActivitiesPage({super.key});

  @override
  State<RegisteredActivitiesPage> createState() =>
      _RegisteredActivitiesPageState();
}

class _RegisteredActivitiesPageState extends State<RegisteredActivitiesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final RequestService _requestService = RequestService();
  final CampaignService _campaignService = CampaignService();

  List<HelpRequestModel> _acceptedRequests = [];
  List<CampaignRegistrationModel> _registeredCampaigns = [];
  bool _isLoadingRequests = false;
  bool _isLoadingCampaigns = false;
  bool _hasChanges = false; // Flag để track có thay đổi không

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAcceptedRequests();
    _loadRegisteredCampaigns();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAcceptedRequests() async {
    setState(() => _isLoadingRequests = true);
    try {
      final requests = await _requestService.getVolunteerRequests();
      if (mounted) {
        setState(() {
          _acceptedRequests = requests;
          _isLoadingRequests = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingRequests = false);
      }
    }
  }

  Future<void> _loadRegisteredCampaigns() async {
    setState(() => _isLoadingCampaigns = true);
    try {
      final campaigns = await _campaignService.getMyRegistrations();
      if (mounted) {
        setState(() {
          _registeredCampaigns = campaigns;
          _isLoadingCampaigns = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCampaigns = false);
      }
    }
  }

  void _onRequestCardPressed(HelpRequestModel request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestDetailPage(request: request),
      ),
    );
  }

  void _onCampaignCardPressed(CampaignModel campaign) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CampaignDetailPage(campaign: campaign),
      ),
    );
  }

  Future<void> _cancelCampaignRegistration(String campaignId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận hủy đăng ký'),
        content: const Text('Bạn có chắc chắn muốn hủy đăng ký chiến dịch này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hủy đăng ký'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _campaignService.cancelRegistration(campaignId);
      if (mounted) {
        if (success) {
          setState(() => _hasChanges = true); // Đánh dấu có thay đổi
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã hủy đăng ký thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          _loadRegisteredCampaigns(); // Reload list trong trang này
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể hủy đăng ký. Vui lòng thử lại.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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

  String _getStatusText(String status) {
    const statuses = {
      'PENDING': 'Chờ xử lý',
      'APPROVED': 'Đã duyệt',
      'ONGOING': 'Đang thực hiện',
      'COMPLETED': 'Hoàn thành',
      'CANCELLED': 'Đã hủy',
      'REJECTED': 'Từ chối',
      'REGISTERED': 'Đã đăng ký',
      'ATTENDED': 'Đã tham gia',
    };
    return statuses[status] ?? status;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'APPROVED':
        return Colors.blue;
      case 'ONGOING':
        return Colors.purple;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
      case 'REJECTED':
        return Colors.red;
      case 'REGISTERED':
        return Colors.teal;
      case 'ATTENDED':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && _hasChanges) {
          // Khi back, return true nếu có thay đổi để refresh trang cha
          Future.microtask(() {
            if (mounted && Navigator.canPop(context)) {
              Navigator.of(context).pop(true);
            }
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FCFC),
        appBar: AppBar(
          title: const Text('Các hoạt động đã đăng ký'),
          backgroundColor: const Color(0xFF008080),
        ),
      body: Column(
        children: [
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
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Yêu cầu đã nhận'),
                  Tab(text: 'Chiến dịch đã đăng ký'),
                ],
              ),
            ),
          ),

          // TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Accepted Requests
                _buildAcceptedRequestsList(),

                // Tab 2: Registered Campaigns
                _buildRegisteredCampaignsList(),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildAcceptedRequestsList() {
    if (_isLoadingRequests) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_acceptedRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chưa nhận yêu cầu nào',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAcceptedRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _acceptedRequests.length,
        itemBuilder: (context, index) {
          final request = _acceptedRequests[index];
          return _buildRequestCard(request);
        },
      ),
    );
  }

  Widget _buildRegisteredCampaignsList() {
    if (_isLoadingCampaigns) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_registeredCampaigns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.campaign, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chưa đăng ký chiến dịch nào',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRegisteredCampaigns,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _registeredCampaigns.length,
        itemBuilder: (context, index) {
          final registration = _registeredCampaigns[index];
          return _buildCampaignRegistrationCard(registration);
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
              // Status + Urgency
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(request.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(request.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (request.urgencyLevel == 'CRITICAL') ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'KHẨN CẤP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),

              // Title
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

  Widget _buildCampaignRegistrationCard(
      CampaignRegistrationModel registration) {
    final campaign = registration.campaign;
    if (campaign == null) {
      return const SizedBox.shrink();
    }

    final spotsLeft = campaign.maxVolunteers - campaign.currentVolunteers;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover image
          if (campaign.coverImage != null)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
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
                // Status tag
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(registration.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(registration.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Đăng ký: ${_formatDate(registration.registeredAt)}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Title
                InkWell(
                  onTap: () => _onCampaignCardPressed(campaign),
                  child: Text(
                    campaign.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
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
                          campaign.organization!.organizationName ??
                              'Tổ chức xã hội',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                    const Icon(Icons.location_on,
                        size: 16, color: Colors.orange),
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
                    const Icon(Icons.calendar_today,
                        size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _formatDate(campaign.startDate),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),

                // Notes if any
                if (registration.notes != null &&
                    registration.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.note, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Ghi chú: ${registration.notes}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Cancel button - only show if status is REGISTERED
                if (registration.status == 'REGISTERED')
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _cancelCampaignRegistration(campaign.id),
                      icon: const Icon(Icons.cancel, size: 18),
                      label: const Text('Hủy đăng ký'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
