import 'package:flutter/material.dart';
import 'package:mobile/models/request_model.dart';
import 'package:mobile/services/request_service.dart';
import 'package:mobile/services/feedback_service.dart';
import 'package:mobile/views/pages/activities/request_detail_page.dart';
import 'package:intl/intl.dart';

import 'package:mobile/services/appreciation_service.dart';

class BeneficiaryActivityHistoryPage extends StatefulWidget {
  const BeneficiaryActivityHistoryPage({Key? key}) : super(key: key);

  @override
  State<BeneficiaryActivityHistoryPage> createState() =>
      _BeneficiaryActivityHistoryPageState();
}

class _BeneficiaryActivityHistoryPageState
    extends State<BeneficiaryActivityHistoryPage> {
  final RequestService _requestService = RequestService();
  final FeedbackService _feedbackService = FeedbackService();
  final AppreciationService _appreciationService = AppreciationService();
  List<HelpRequestModel> _myRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() => _isLoading = true);

    try {
      print('📡 Fetching beneficiary requests...');

      // Gọi API lấy danh sách yêu cầu của NCGD
      final requests = await _requestService.getRequesterRequests();
      print('📥 Received ${requests.length} requests');

      // Sắp xếp theo ngày tạo: MỚI NHẤT trước
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (mounted) {
        setState(() {
          _myRequests = requests;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('❌ Error loading activities: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _myRequests = [];
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
          : _myRequests.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadActivities,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _myRequests.length,
                itemBuilder: (context, index) =>
                    _buildActivityCard(_myRequests[index]),
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Chưa có yêu cầu nào',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tạo yêu cầu giúp đỡ để bắt đầu',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(HelpRequestModel request) {
    Color statusBg;
    Color statusText;
    String label;

    switch (request.status) {
      case 'PENDING':
        statusBg = Colors.orange;
        statusText = Colors.white;
        label = 'Chờ duyệt';
        break;
      case 'APPROVED':
        statusBg = Colors.blue;
        statusText = Colors.white;
        label = 'Đã duyệt';
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
      case 'REJECTED':
        statusBg = Colors.red;
        statusText = Colors.white;
        label = 'Từ chối';
        break;
      case 'CANCELLED':
        statusBg = Colors.grey;
        statusText = Colors.white;
        label = 'Đã hủy';
        break;
      default:
        statusBg = Colors.grey;
        statusText = Colors.white;
        label = request.status;
    }

    // Chỉ hiện nút "Gửi lời cảm ơn" khi COMPLETED và có volunteerId
    final canSendAppreciation =
        request.status == 'COMPLETED' && request.volunteerId != null;

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
                      DateFormat('dd/MM/yyyy').format(request.createdAt),
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
              request.title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 12),

            // Description
            if (request.description != null && request.description!.isNotEmpty)
              Text(
                request.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RequestDetailPage(request: request),
                        ),
                      ).then(
                        (_) => _loadActivities(),
                      ); // Refresh sau khi quay lại
                    },
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: const Text(
                      'Xem chi tiết',
                      style: TextStyle(
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
                if (canSendAppreciation) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: FutureBuilder<bool>(
                      future: _appreciationService.hasAppreciated(request.id),
                      builder: (context, snapshot) {
                        final hasAppreciated = snapshot.data ?? false;

                        if (hasAppreciated) {
                          return const SizedBox.shrink(); // Ẩn nút nếu đã cảm ơn xong
                        }

                        return ElevatedButton.icon(
                          onPressed: () => _sendAppreciation(request),
                          icon: const Icon(Icons.favorite, size: 18),
                          label: const Text(
                            'Cảm ơn',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendAppreciation(HelpRequestModel request) async {
    if (request.volunteerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy tình nguyện viên'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final success = await _feedbackService.sendAppreciation(
        activityId: request.id,
        receiverId: request.volunteerId!,
      );

      if (!mounted) return;

      Navigator.pop(context); // Đóng loading

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Đã gửi lời cảm ơn đến tình nguyện viên'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể gửi lời cảm ơn. Vui lòng thử lại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Đóng loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
