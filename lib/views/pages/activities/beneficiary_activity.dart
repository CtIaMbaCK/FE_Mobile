import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/models/request_model.dart';
import 'package:mobile/services/request_service.dart';
import 'package:mobile/services/appreciation_service.dart';
import 'package:mobile/views/pages/activities/activity_history.dart';
import 'package:mobile/views/pages/activities/request_result_page.dart';
import 'package:mobile/views/pages/activities/request_detail_page.dart';
import 'package:intl/intl.dart';
import 'package:mobile/views/pages/activities/create_activity.dart';

class BeneficiaryActivityPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const BeneficiaryActivityPage({super.key, required this.userData});

  @override
  State<BeneficiaryActivityPage> createState() =>
      _BeneficiaryActivityPageState();
}

class _BeneficiaryActivityPageState extends State<BeneficiaryActivityPage> {
  final RequestService _requestService = RequestService();
  final AppreciationService _appreciationService = AppreciationService();

  // Hàm xử lý khi nhấn Hủy yêu cầu
  void _handleDelete(String id) async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Xác nhận"),
            content: const Text("Bạn có chắc chắn muốn hủy yêu cầu này không?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Đóng"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Đồng ý",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      // Giả sử API delete bài đăng là deleteRequest
      // bool success = await _requestService.deleteRequest(id);
      // if (success) setState(() {});
      print("Đã thực hiện lệnh hủy cho ID: $id");
    }
  }

  // Hàm gửi lời cảm ơn
  Future<void> _sendAppreciation(HelpRequestModel request) async {
    if (request.volunteerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy thông tin tình nguyện viên!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await _appreciationService.sendAppreciation(
      request.id,
      request.volunteerId!,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã gửi lời cảm ơn đến tình nguyện viên!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {}); // Refresh để update UI
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể gửi lời cảm ơn. Có thể bạn đã gửi rồi.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  // Hàm xem kết quả và đánh giá
  void _viewResult(HelpRequestModel request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestResultPage(request: request),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // --- Header Section ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        bool? created = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NewHelpPage(),
                          ),
                        );
                        if (created == true) setState(() {});
                      },
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      label: const Text(
                        'Tạo yêu cầu mới',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF008080),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HistoryActivityPage(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF008080).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.history,
                          color: Color(0xFF008080),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- List Section dùng FutureBuilder ---
            Expanded(
              child: FutureBuilder<List<HelpRequestModel>>(
                future: _requestService.getRequesterRequests(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF008080),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Lỗi: ${snapshot.error}",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final requests = snapshot.data ?? [];
                  if (requests.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF008080).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.assignment_outlined,
                              size: 64,
                              color: const Color(0xFF008080).withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Bạn chưa tạo yêu cầu nào",
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Hãy tạo yêu cầu đầu tiên của bạn",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Sắp xếp requests theo thứ tự: ONGOING > PENDING > APPROVED > REJECTED > COMPLETED
                  final sortedRequests = List<HelpRequestModel>.from(requests);
                  sortedRequests.sort((a, b) {
                    const statusOrder = {
                      'ONGOING': 1,
                      'PENDING': 2,
                      'APPROVED': 3,
                      'REJECTED': 4,
                      'COMPLETED': 5,
                    };
                    final orderA = statusOrder[a.status] ?? 6;
                    final orderB = statusOrder[b.status] ?? 6;
                    return orderA.compareTo(orderB);
                  });

                  return RefreshIndicator(
                    onRefresh: () async => setState(() {}),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: sortedRequests.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) =>
                          _buildRequestCard(sortedRequests[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(HelpRequestModel item) {
    Color statusBgColor;
    Color statusTextColor;
    String statusLabel;

    switch (item.status) {
      case 'PENDING':
        statusBgColor = Colors.orange;
        statusTextColor = Colors.white;
        statusLabel = "Chờ duyệt";
        break;
      case 'APPROVED':
        statusBgColor = Colors.blue;
        statusTextColor = Colors.white;
        statusLabel = "Đã duyệt";
        break;
      case 'ONGOING':
        statusBgColor = Colors.purple;
        statusTextColor = Colors.white;
        statusLabel = "Đang thực hiện";
        break;
      case 'COMPLETED':
        statusBgColor = Colors.green;
        statusTextColor = Colors.white;
        statusLabel = "Hoàn thành";
        break;
      default:
        statusBgColor = Colors.grey;
        statusTextColor = Colors.white;
        statusLabel = item.status;
    }

    String formattedDate = DateFormat('dd/MM/yyyy').format(item.createdAt);

    return Container(
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
            // Status badge and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: GoogleFonts.roboto(
                      color: statusTextColor,
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
                      formattedDate,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
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
              item.title,
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),

            // Description
            if (item.description != null && item.description!.isNotEmpty)
              Text(
                item.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            const SizedBox(height: 16),

            // Date range info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "${DateFormat('dd/MM/yyyy').format(item.startDate)} - ${item.endDate != null ? DateFormat('dd/MM/yyyy').format(item.endDate!) : '---'}",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action buttons
            if (item.status == 'PENDING')
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            bool? updated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NewHelpPage(request: item),
                              ),
                            );
                            if (updated == true) setState(() {});
                          },
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text(
                            'Chỉnh sửa',
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _handleDelete(item.id),
                          icon: const Icon(Icons.cancel_outlined, size: 18),
                          label: const Text(
                            'Hủy',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(
                              color: Colors.red,
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
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RequestDetailPage(request: item),
                          ),
                        );
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
                ],
              )
            else if (item.status == 'COMPLETED')
              Column(
                children: [
                  // Nút Xem kết quả
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _viewResult(item),
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      label: const Text(
                        'Xem kết quả',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF008080),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Nút Cảm ơn
                  FutureBuilder<bool>(
                    future: _appreciationService.hasAppreciated(item.id),
                    builder: (context, snapshot) {
                      final hasAppreciated = snapshot.data ?? false;

                      if (hasAppreciated) {
                        return const SizedBox.shrink(); // Ẩn nút nếu đã gửi
                      }

                      return SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _sendAppreciation(item),
                          icon: const Icon(Icons.favorite_border, size: 18),
                          label: const Text(
                            'Gửi lời cảm ơn',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.pink,
                            side: const BorderSide(
                              color: Colors.pink,
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              )
            else
              // Nút Xem chi tiết cho các status khác (APPROVED, ONGOING, REJECTED)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RequestDetailPage(request: item),
                      ),
                    );
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
          ],
        ),
      ),
    );
  }
}
