import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/models/request_model.dart';
import 'package:mobile/services/request_service.dart';

class MapRequestsPage extends StatefulWidget {
  const MapRequestsPage({Key? key}) : super(key: key);

  @override
  State<MapRequestsPage> createState() => _MapRequestsPageState();
}

class _MapRequestsPageState extends State<MapRequestsPage> {
  final Completer<GoogleMapController> _controller = Completer();
  final RequestService _requestService = RequestService();

  Set<Marker> _markers = {};
  List<HelpRequestModel> _requests = [];
  bool _isLoading = true;

  // Vị trí mặc định: TP. Hồ Chí Minh
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(10.762622, 106.660172),
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);

    try {
      final requests = await _requestService.getPendingRequests();

      // Lọc chỉ lấy những request có tọa độ
      final validRequests = requests
          .where((r) => r.latitude != null && r.longitude != null)
          .toList();

      // Tạo markers
      final markers = <Marker>{};
      for (var request in validRequests) {
        markers.add(
          Marker(
            markerId: MarkerId(request.id),
            position: LatLng(request.latitude!, request.longitude!),
            onTap: () => _onMarkerTapped(request),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
            infoWindow: InfoWindow(
              title: request.title,
              snippet: 'Nhấn để xem chi tiết',
            ),
          ),
        );
      }

      setState(() {
        _requests = validRequests;
        _markers = markers;
        _isLoading = false;
      });
    } catch (e) {
      print('Lỗi load requests: $e');
      setState(() => _isLoading = false);
    }
  }

  void _onMarkerTapped(HelpRequestModel request) {
    _showRequestDetail(request);
  }

  void _showRequestDetail(HelpRequestModel request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildRequestDetailSheet(request),
    );
  }

  Widget _buildRequestDetailSheet(HelpRequestModel request) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              // Thanh kéo
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Tiêu đề
              Text(
                request.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Mức độ khẩn cấp
              _buildInfoRow(
                Icons.warning_amber_rounded,
                'Mức độ',
                request.urgencyLevel == 'CRITICAL' ? 'Khẩn cấp' : 'Bình thường',
                request.urgencyLevel == 'CRITICAL' ? Colors.red : Colors.green,
              ),

              // Loại hoạt động
              _buildInfoRow(
                Icons.category,
                'Loại hoạt động',
                _getActivityTypeName(request.activityType),
                Colors.blue,
              ),

              // Địa chỉ
              _buildInfoRow(
                Icons.location_on,
                'Địa chỉ',
                '${request.addressDetail}, ${_getDistrictName(request.district)}',
                Colors.orange,
              ),

              // Thời gian
              _buildInfoRow(
                Icons.access_time,
                'Thời gian',
                _formatDateTime(request.startDate, request.startTime),
                Colors.purple,
              ),

              // Mô tả
              if (request.description != null && request.description!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Mô tả',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  request.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Nút chấp nhận
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _acceptRequest(request),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
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
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptRequest(HelpRequestModel request) async {
    // Đóng bottom sheet
    Navigator.pop(context);

    // Hiển thị loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final success = await _requestService.acceptRequest(request.id);

      // Đóng loading dialog
      if (mounted) Navigator.pop(context);

      if (success) {
        // Hiển thị thông báo thành công
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã chấp nhận yêu cầu thành công!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Reload danh sách để xóa request đã accept khỏi map
        await _loadRequests();
      } else {
        // Hiển thị lỗi
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể chấp nhận yêu cầu. Vui lòng thử lại!'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      // Đóng loading dialog nếu còn mở
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bản đồ yêu cầu trợ giúp'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRequests,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: _initialPosition,
                  markers: _markers,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  compassEnabled: true,
                ),

                // Thông tin số lượng yêu cầu
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Có ${_requests.length} yêu cầu đang chờ',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
