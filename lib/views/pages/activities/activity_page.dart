import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/models/request_model.dart';
import 'package:mobile/services/request_service.dart';
import 'package:mobile/views/pages/activities/activity_history.dart';
import 'package:intl/intl.dart';
import 'package:mobile/views/pages/activities/create_activity.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final RequestService _requestService = RequestService();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFC),
      body: SafeArea(
        child: Column(
          children: [
            // --- Header Section ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      bool? created = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NewHelpPage(),
                        ),
                      );
                      if (created == true) setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF008080),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Tạo yêu cầu'),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HistoryActivityPage(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          'Lịch sử hoạt động',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF008080),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: Color(0xFF008080),
                        ),
                      ],
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
                  if (snapshot.hasError)
                    return Center(child: Text("Lỗi: ${snapshot.error}"));

                  final requests = snapshot.data ?? [];
                  if (requests.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_late_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          const Text("Bạn chưa tạo yêu cầu nào."),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => setState(() {}),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      itemCount: requests.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          _buildRequestCard(requests[index]),
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
        statusBgColor = const Color(0xFFFEF3C7);
        statusTextColor = const Color(0xFF8D3100);
        statusLabel = "Chờ duyệt";
        break;
      case 'APPROVED':
        statusBgColor = const Color(0xFFE0F2FE);
        statusTextColor = const Color(0xFF0369A1);
        statusLabel = "Đã duyệt";
        break;
      case 'ONGOING':
        statusBgColor = const Color(0xFFDCFCE7);
        statusTextColor = const Color(0xFF15803D);
        statusLabel = "Đang diễn ra";
        break;
      case 'COMPLETED':
        statusBgColor = const Color(0xFFE0F2F1);
        statusTextColor = const Color(0xFF008080);
        statusLabel = "Hoàn thành";
        break;
      default:
        statusBgColor = Colors.grey[200]!;
        statusTextColor = Colors.black54;
        statusLabel = item.status;
    }

    String formattedDate = DateFormat('dd/MM/yyyy').format(item.createdAt);

    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Trạng thái: ',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusLabel,
                        style: GoogleFonts.inter(
                          color: statusTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  formattedDate,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                item.title,
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Text(
              item.description ?? "Không có mô tả",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.roboto(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),

            // NÚT BẤM DÙNG TOÁN TỬ 3 NGÔI & IF
            item.status == 'PENDING'
                ? Row(
                    children: [
                      // NÚT CHỈNH SỬA
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () async {
                              bool? updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      NewHelpPage(request: item),
                                ),
                              );
                              if (updated == true) setState(() {});
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE0F2FE),
                              foregroundColor: const Color(0xFF0369A1),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Chỉnh sửa',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // NÚT HỦY
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () => _handleDelete(item.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFE4E6),
                              foregroundColor: const Color(0xFFCC4362),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Hủy yêu cầu',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : item.status == 'COMPLETED'
                ? SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () => print('Xem kết quả cho ID: ${item.id}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE0F2F1),
                        foregroundColor: const Color(0xFF008080),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Xem kết quả',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
