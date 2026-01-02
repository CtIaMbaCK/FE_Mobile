// lib/views/pages/activities/activity_history.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/models/request_model.dart';
import 'package:mobile/services/request_service.dart';
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
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F4F8),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF15161E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Lịch sử hoạt động',
          style: GoogleFonts.readexPro(
            color: const Color(0xFF15161E),
            fontSize: 20,
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFF008080),
                labelColor: const Color(0xFF008080),
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'Tất cả'),
                  Tab(text: 'Hoàn thành'),
                  Tab(text: 'Từ chối'),
                ],
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
        statusBg = const Color(0xFFFEF3C7);
        statusText = const Color(0xFF8D3100);
        label = "Chờ duyệt";
        break;
      case 'APPROVED':
        statusBg = const Color(0xFFE0F2FE);
        statusText = const Color(0xFF0369A1);
        label = "Đã duyệt";
        break;
      case 'ONGOING':
        statusBg = const Color(0xFFDCFCE7);
        statusText = const Color(0xFF15803D);
        label = "Đang diễn ra";
        break;
      case 'COMPLETED':
        statusBg = const Color(0xFFE0F2F1);
        statusText = const Color(0xFF008080);
        label = "Hoàn thành";
        break;
      case 'REJECTED':
        statusBg = const Color(0xFFFFE4E6);
        statusText = const Color(0xFFCC4362);
        label = "Từ chối";
        break;
      default:
        statusBg = Colors.grey[200]!;
        statusText = Colors.black54;
        label = item.status;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      color: statusText,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  DateFormat('dd/MM/yyyy').format(item.createdAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.title,
              style: GoogleFonts.interTight(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.description ?? "Không có mô tả",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF57636C)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: () => print('ID: ${item.id}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF008080).withOpacity(0.1),
                  foregroundColor: const Color(0xFF008080),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Xem chi tiết',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
