import 'package:flutter/material.dart';
import 'package:mobile/models/request_model.dart';
import 'package:mobile/services/request_service.dart';
import 'package:mobile/views/pages/activities/request_detail_page.dart';
import 'package:mobile/views/pages/activities/request_result_page.dart';
import 'package:intl/intl.dart';

class VolunteerActivityHistoryPage extends StatefulWidget {
  const VolunteerActivityHistoryPage({Key? key}) : super(key: key);

  @override
  State<VolunteerActivityHistoryPage> createState() =>
      _VolunteerActivityHistoryPageState();
}

class _VolunteerActivityHistoryPageState
    extends State<VolunteerActivityHistoryPage> {
  final RequestService _requestService = RequestService();
  List<HelpRequestModel> _myActivities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() => _isLoading = true);

    try {
      print('📡 Fetching volunteer activities...');

      // Gọi API lấy danh sách hoạt động của volunteer
      final activities = await _requestService.getVolunteerRequests();
      print('📥 Received ${activities.length} activities');

      // Sắp xếp theo ngày tạo: MỚI NHẤT trước
      activities.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (mounted) {
        setState(() {
          _myActivities = activities;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('❌ Error loading activities: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _myActivities = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải lịch sử: $e'),
            backgroundColor: Colors.red,
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
        title: const Text('Lịch sử hoạt động'),
        backgroundColor: const Color(0xFF008080),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myActivities.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadActivities,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _myActivities.length,
                    itemBuilder: (context, index) =>
                        _buildActivityCard(_myActivities[index]),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có hoạt động nào',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy tham gia hoạt động tình nguyện',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(HelpRequestModel activity) {
    Color statusBg;
    Color statusText;
    String label;

    switch (activity.status) {
      case 'APPROVED':
        statusBg = Colors.blue;
        statusText = Colors.white;
        label = 'Đã nhận';
        break;
      case 'ONGOING':
        statusBg = Colors.purple;
        statusText = Colors.white;
        label = 'Đang thực hiện';
        break;
      case 'COMPLETED':
        statusBg = Colors.green;
        statusText = Colors.white;
        label = 'Hoàn thành';
        break;
      default:
        statusBg = Colors.grey;
        statusText = Colors.white;
        label = activity.status;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Status badge + Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: statusText,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd/MM/yyyy').format(activity.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Title
            Text(
              activity.title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 12),

            // Description
            if (activity.description != null &&
                activity.description!.isNotEmpty)
              Text(
                activity.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),

            const SizedBox(height: 16),

            // Action button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  if (activity.status == 'COMPLETED') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RequestResultPage(request: activity),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RequestDetailPage(request: activity),
                      ),
                    );
                  }
                },
                icon: Icon(
                  activity.status == 'COMPLETED'
                      ? Icons.visibility_outlined
                      : Icons.info_outline,
                  size: 18,
                ),
                label: Text(
                  activity.status == 'COMPLETED'
                      ? 'Xem kết quả'
                      : 'Xem chi tiết',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF008080),
                  side: const BorderSide(
                    color: Color(0xFF008080),
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
