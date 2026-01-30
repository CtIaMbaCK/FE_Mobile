import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/models/request_model.dart';
import 'package:mobile/services/request_service.dart';
import 'package:mobile/views/pages/activities/request_detail_page.dart';

class MapRequestsPage extends StatefulWidget {
  const MapRequestsPage({Key? key}) : super(key: key);

  @override
  State<MapRequestsPage> createState() => _MapRequestsPageState();
}

class _MapRequestsPageState extends State<MapRequestsPage>
    with WidgetsBindingObserver {
  GoogleMapController? _mapController;
  final RequestService _requestService = RequestService();

  Set<Marker> _markers = {};
  List<HelpRequestModel> _requests = [];
  bool _isLoading = true;
  Timer? _autoRefreshTimer;
  DateTime? _lastRefreshTime;

  // Vị trí mặc định: TP. Hồ Chí Minh
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(10.762622, 106.660172),
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadRequests();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // App quay lại foreground → Kiểm tra và refresh nếu cần
      _checkAndRefresh();
    } else if (state == AppLifecycleState.paused) {
      // App vào background → Dừng auto refresh để tiết kiệm pin
      _autoRefreshTimer?.cancel();
    }
  }

  /// Auto refresh mỗi 30 giây
  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _loadRequests(showLoading: false),
    );
  }

  /// Kiểm tra và refresh nếu quá lâu không update
  void _checkAndRefresh() {
    if (_lastRefreshTime == null ||
        DateTime.now().difference(_lastRefreshTime!) >
            const Duration(minutes: 2)) {
      _loadRequests();
      _startAutoRefresh(); // Restart timer khi app resume
    }
  }

  Future<void> _loadRequests({bool showLoading = true}) async {
    if (showLoading) {
      setState(() => _isLoading = true);
    }

    try {
      final requests = await _requestService.getPendingRequests();

      // Lọc chỉ lấy những request có tọa độ
      final validRequests = requests
          .where((r) => r.latitude != null && r.longitude != null)
          .toList();

      print('=== DEBUG MAP ===');
      print('Total requests from API: ${requests.length}');
      print('Valid requests (có tọa độ): ${validRequests.length}');

      // Tạo markers
      final markers = <Marker>{};
      for (var request in validRequests) {
        print(
            'Adding marker: ${request.id} - ${request.title} - (${request.latitude}, ${request.longitude})');
        markers.add(
          Marker(
            markerId: MarkerId(request.id),
            position: LatLng(request.latitude!, request.longitude!),
            onTap: () => _onMarkerTapped(request),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              request.urgencyLevel == 'CRITICAL'
                  ? BitmapDescriptor.hueRed
                  : BitmapDescriptor.hueOrange,
            ),
            infoWindow: InfoWindow(
              title: request.title,
              snippet: request.urgencyLevel == 'CRITICAL'
                  ? '🚨 Khẩn cấp - Nhấn để xem'
                  : 'Nhấn để xem chi tiết',
            ),
          ),
        );
      }

      print('Total markers created: ${markers.length}');
      print('==================');

      if (mounted) {
        setState(() {
          _requests = validRequests;
          _markers = markers;
          _isLoading = false;
          _lastRefreshTime = DateTime.now();
        });

        // Hiển thị toast nếu có yêu cầu mới (chỉ khi background refresh)
        if (!showLoading && validRequests.length != _requests.length) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Có ${validRequests.length} yêu cầu mới'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.blue,
            ),
          );
        }
      }
    } catch (e) {
      print('Lỗi load requests: $e');
      if (mounted) {
        setState(() => _isLoading = false);

        // Chỉ hiển thị error nếu là manual refresh
        if (showLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không thể tải dữ liệu: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  void _onMarkerTapped(HelpRequestModel request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestDetailPage(
          request: request,
          isVolunteerView: false, // Chưa nhận, đang xem từ map
        ),
      ),
    ).then((value) {
      if (value == true) {
        _loadRequests(); // Reload map khi accept request
      }
    });
  }

  String _formatRefreshTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
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
                    _mapController = controller;
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
                          'Có ${_markers.length} yêu cầu đang chờ',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Last refresh time
                Positioned(
                  bottom: 80,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _lastRefreshTime != null
                          ? 'Cập nhật: ${_formatRefreshTime(_lastRefreshTime!)}'
                          : 'Đang tải...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
