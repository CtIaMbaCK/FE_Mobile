import 'package:flutter/material.dart';
import 'package:mobile/models/request_model.dart';
import 'package:mobile/services/request_service.dart';

class RequestDetailPage extends StatefulWidget {
  final HelpRequestModel request;

  const RequestDetailPage({Key? key, required this.request}) : super(key: key);

  @override
  State<RequestDetailPage> createState() => _RequestDetailPageState();
}

class _RequestDetailPageState extends State<RequestDetailPage> {
  final RequestService _requestService = RequestService();
  bool _isAccepting = false;

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

  Future<void> _acceptRequest() async {
    setState(() => _isAccepting = true);

    try {
      final success = await _requestService.acceptRequest(widget.request.id);

      if (mounted) {
        setState(() => _isAccepting = false);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã chấp nhận yêu cầu thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true để refresh list
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết yêu cầu'),
        backgroundColor: const Color(0xFF008080),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image nếu có
            if (widget.request.activityImages.isNotEmpty)
              Image.network(
                widget.request.activityImages.first,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 50),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề
                  Text(
                    widget.request.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mức độ khẩn cấp
                  _buildInfoRow(
                    Icons.warning_amber_rounded,
                    'Mức độ',
                    widget.request.urgencyLevel == 'CRITICAL'
                        ? 'Khẩn cấp'
                        : 'Bình thường',
                    widget.request.urgencyLevel == 'CRITICAL'
                        ? Colors.red
                        : Colors.green,
                  ),

                  // Loại hoạt động
                  _buildInfoRow(
                    Icons.category,
                    'Loại hoạt động',
                    _getActivityTypeName(widget.request.activityType),
                    Colors.blue,
                  ),

                  // Địa chỉ
                  _buildInfoRow(
                    Icons.location_on,
                    'Địa chỉ',
                    '${widget.request.addressDetail}, ${_getDistrictName(widget.request.district)}',
                    Colors.orange,
                  ),

                  // Thời gian
                  _buildInfoRow(
                    Icons.access_time,
                    'Thời gian',
                    _formatDateTime(
                        widget.request.startDate, widget.request.startTime),
                    Colors.purple,
                  ),

                  // Mô tả
                  if (widget.request.description != null &&
                      widget.request.description!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Mô tả chi tiết',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.request.description!,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Nút chấp nhận
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isAccepting ? null : _acceptRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF008080),
                        disabledBackgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isAccepting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Chấp nhận yêu cầu',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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
