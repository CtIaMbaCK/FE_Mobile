// lib/views/pages/activities/activity_history.dart
import 'package:flutter/material.dart';
import 'package:mobile/models/request_model.dart';
import 'package:mobile/services/request_service.dart';
import 'package:mobile/views/pages/activities/request_result_page.dart';
import 'package:mobile/views/pages/activities/request_detail_page.dart';
import 'package:intl/intl.dart';

class HistoryActivityPage extends StatefulWidget {
  const HistoryActivityPage({super.key});

  @override
  State<HistoryActivityPage> createState() => _HistoryActivityPageState();
}

class _HistoryActivityPageState extends State<HistoryActivityPage>
    with SingleTickerProviderStateMixin {
  final RequestService _requestService = RequestService();
  final TextEditingController _searchController = TextEditingController();
  TabController? _tabController;
  String _currentSearch = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController!.addListener(() {
      if (!_tabController!.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String? _getStatusByTab(int index) {
    if (index == 1) return 'COMPLETED';
    if (index == 2) return 'REJECTED';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_tabController == null) return const Scaffold();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF008080),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Lịch sử hoạt động',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- Search Bar ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onSubmitted: (val) => setState(() => _currentSearch = val),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm tiêu đề...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _currentSearch.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _currentSearch = "");
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // --- Tab Bar ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: const Color(0xFF008080),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF008080).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[700],
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Tất cả'),
                    Tab(text: 'Hoàn thành'),
                    Tab(text: 'Từ chối'),
                  ],
                ),
              ),
            ),

            // --- List Content ---
            Expanded(
              child: FutureBuilder<List<HelpRequestModel>>(
                future: _requestService.getAllRequests(
                  search: _currentSearch,
                  status: _getStatusByTab(_tabController!.index),
                ),
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

                  final items = snapshot.data ?? [];
                  if (items.isEmpty)
                    return const Center(child: Text("Không có dữ liệu"));

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _buildRequestCard(items[index]),
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
    Color statusBg;
    Color statusText;
    String label;

    switch (item.status) {
      case 'PENDING':
        statusBg = Colors.orange;
        statusText = Colors.white;
        label = "Chờ duyệt";
        break;
      case 'APPROVED':
        statusBg = Colors.blue;
        statusText = Colors.white;
        label = "Đã duyệt";
        break;
      case 'ONGOING':
        statusBg = Colors.purple;
        statusText = Colors.white;
        label = "Đang thực hiện";
        break;
      case 'COMPLETED':
        statusBg = Colors.green;
        statusText = Colors.white;
        label = "Hoàn thành";
        break;
      case 'REJECTED':
        statusBg = Colors.red;
        statusText = Colors.white;
        label = "Từ chối";
        break;
      default:
        statusBg = Colors.grey;
        statusText = Colors.white;
        label = item.status;
    }

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
                      DateFormat('dd/MM/yyyy').format(item.createdAt),
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
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
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
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Nếu là COMPLETED, xem kết quả với form đánh giá
                  // Các status khác xem chi tiết thông tin request
                  if (item.status == 'COMPLETED') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RequestResultPage(request: item),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RequestDetailPage(request: item),
                      ),
                    );
                  }
                },
                icon: Icon(
                  item.status == 'COMPLETED'
                    ? Icons.visibility_outlined
                    : Icons.info_outline,
                  size: 18,
                ),
                label: Text(
                  item.status == 'COMPLETED' ? 'Xem kết quả' : 'Xem chi tiết',
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
