import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:mobile/models/request_model.dart';
import 'package:mobile/services/request_service.dart';
import 'package:mobile/views/pages/activities/complete_request_page.dart';

class RequestDetailPage extends StatefulWidget {
  final HelpRequestModel request;
  final bool isVolunteerView; // TNV đã nhận hay đang xem để accept

  const RequestDetailPage({
    Key? key,
    required this.request,
    this.isVolunteerView = false,
  }) : super(key: key);

  @override
  State<RequestDetailPage> createState() => _RequestDetailPageState();
}

class _RequestDetailPageState extends State<RequestDetailPage> {
  final RequestService _requestService = RequestService();
  bool _isAccepting = false;
  late HelpRequestModel _currentRequest;

  @override
  void initState() {
    super.initState();
    _currentRequest = widget.request;
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
    return district
        .replaceAll('_', ' ')
        .replaceAll('QUAN', 'Quận')
        .replaceAll('HUYEN', 'Huyện')
        .replaceAll('TP', 'TP.');
  }

  String _getStatusText(String status) {
    const statusMap = {
      'PENDING': 'Chờ duyệt',
      'APPROVED': 'Đã duyệt',
      'ONGOING': 'Đang thực hiện',
      'COMPLETED': 'Đã hoàn thành',
      'CANCELLED': 'Đã hủy',
    };
    return statusMap[status] ?? status;
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
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  String _getRecurrenceText(String recurrence) {
    const map = {
      'NONE': 'Không lặp lại',
      'DAILY': 'Hàng ngày',
      'WEEKLY': 'Hàng tuần',
      'CUSTOM': 'Tùy chỉnh',
    };
    return map[recurrence] ?? recurrence;
  }

  Future<void> _acceptRequest() async {
    setState(() => _isAccepting = true);

    try {
      final success = await _requestService.acceptRequest(_currentRequest.id);

      if (mounted) {
        setState(() => _isAccepting = false);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã chấp nhận yêu cầu thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể chấp nhận yêu cầu!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAccepting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navigateToComplete() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompleteRequestPage(
          requestId: _currentRequest.id,
          requestTitle: _currentRequest.title,
        ),
      ),
    );

    if (result == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // App Bar với hình ảnh
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF008080),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.zero,
              background: _currentRequest.activityImages.isNotEmpty
                  ? PageView.builder(
                      itemCount: _currentRequest.activityImages.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: _currentRequest.activityImages[index],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[300],
                                child: const Center(child: CircularProgressIndicator()),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.image, size: 50, color: Colors.grey),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.3),
                                    Colors.transparent,
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.6),
                                  ],
                                  stops: const [0.0, 0.3, 0.7, 1.0],
                                ),
                              ),
                            ),
                            if (_currentRequest.activityImages.length > 1)
                              Positioned(
                                bottom: 20,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    _currentRequest.activityImages.length,
                                    (i) => Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 3),
                                      width: i == index ? 24 : 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: i == index ? Colors.white : Colors.white.withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    )
                  : Container(
                      color: const Color(0xFF008080),
                      child: const Icon(Icons.image, size: 80, color: Colors.white),
                    ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                // Header với title và status (màu #008080)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF008080),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(_currentRequest.status),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getStatusText(_currentRequest.status),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        _currentRequest.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.3,
                        ),
                      ),

                      // Description
                      if (_currentRequest.description != null && _currentRequest.description!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          _currentRequest.description!,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withValues(alpha: 0.95),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Info Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildInfoCard(
                        icon: Icons.category_outlined,
                        iconColor: const Color(0xFF008080),
                        title: 'Loại hoạt động',
                        value: _getActivityTypeName(_currentRequest.activityType),
                      ),
                      _buildInfoCard(
                        icon: Icons.location_on_outlined,
                        iconColor: Colors.orange,
                        title: 'Địa chỉ',
                        value: '${_currentRequest.addressDetail}\n${_getDistrictName(_currentRequest.district)}',
                      ),
                      _buildInfoCard(
                        icon: Icons.calendar_today_outlined,
                        iconColor: Colors.blue,
                        title: 'Thời gian thực hiện',
                        value: 'Từ ${_formatDate(_currentRequest.startDate)} đến ${_formatDate(_currentRequest.endDate ?? _currentRequest.startDate)}',
                        subtitle: '${_formatTime(_currentRequest.startTime)} - ${_formatTime(_currentRequest.endTime)}',
                      ),
                      _buildInfoCard(
                        icon: Icons.repeat_outlined,
                        iconColor: Colors.purple,
                        title: 'Lặp lại',
                        value: _getRecurrenceText(_currentRequest.recurrence),
                      ),
                      _buildInfoCard(
                        icon: Icons.priority_high_outlined,
                        iconColor: _currentRequest.urgencyLevel == 'CRITICAL' ? Colors.red : Colors.green,
                        title: 'Mức độ khẩn cấp',
                        value: _currentRequest.urgencyLevel == 'CRITICAL' ? 'Khẩn cấp' : 'Bình thường',
                      ),

                      // Proof Images
                      if (_currentRequest.status == 'COMPLETED' && _currentRequest.proofImages.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(20),
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
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text('Ảnh minh chứng hoàn thành', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemCount: _currentRequest.proofImages.length,
                                itemBuilder: (context, index) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: CachedNetworkImage(
                                      imageUrl: _currentRequest.proofImages[index],
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(color: Colors.grey[200], child: const Center(child: CircularProgressIndicator())),
                                      errorWidget: (context, url, error) => Container(color: Colors.grey[200], child: const Icon(Icons.error)),
                                    ),
                                  );
                                },
                              ),
                              if (_currentRequest.completionNotes != null && _currentRequest.completionNotes!.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Ghi chú:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
                                      const SizedBox(height: 4),
                                      Text(_currentRequest.completionNotes!, style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.4)),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],

                      if (_currentRequest.doneAt != null)
                        _buildInfoCard(
                          icon: Icons.event_available_outlined,
                          iconColor: Colors.green,
                          title: 'Hoàn thành lúc',
                          value: DateFormat('dd/MM/yyyy HH:mm').format(_currentRequest.doneAt!),
                        ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    String? subtitle,
  }) {
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.4)),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildBottomButton() {
    if (_currentRequest.volunteerId == null && _currentRequest.status == 'APPROVED') {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _isAccepting ? null : _acceptRequest,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF008080),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: _isAccepting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(Icons.check_circle_outline, size: 24), SizedBox(width: 8), Text('Chấp nhận yêu cầu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))],
                  ),
          ),
        ),
      );
    }

    if (widget.isVolunteerView && _currentRequest.status == 'ONGOING') {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _navigateToComplete,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.task_alt, size: 24), SizedBox(width: 8), Text('Hoàn thành yêu cầu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))],
            ),
          ),
        ),
      );
    }

    return null;
  }
}
