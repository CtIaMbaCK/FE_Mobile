import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
// Đã xóa import flutter_secure_storage vì không cần dùng cho Guest mode

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Marker> _markers = [];
  bool _isLoading = true;

  // Key Frontend của bạn (Giữ nguyên)
  final String goongMapKey = '95JXepdUwibvGT1stRhr2GSoErDtjdoediB2Ht8X';
  final String apiKey = 'XSBSNMzkfiqioOMvxfkxPAM5KuPz5CqNBmdB7ycv';
  @override
  void initState() {
    super.initState();
    _fetchMapLocations();
  }

  Future<void> _fetchMapLocations() async {
    // 👇 1. URL Ngrok của bạn (Lấy từ hình ảnh bạn gửi)

    const String baseUrl =
        'https://frettiest-ariella-unnationally.ngrok-free.dev';

    // 👇 Ghép vào API path
    const String apiUrl = '$baseUrl/api/v1/request/map-locations';

    try {
      print("Đang gọi API: $apiUrl");

      // 👇 2. GỌI API TRỰC TIẾP (Bỏ Header Authorization)
      // Vì Backend đã mở Public nên không cần gửi Token nữa
      final response = await http.get(Uri.parse(apiUrl));

      print("Kết quả Server trả về: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<Marker> loadedMarkers = [];

        for (var item in data) {
          if (item['latitude'] != null && item['longitude'] != null) {
            double lat = (item['latitude'] as num).toDouble();
            double lng = (item['longitude'] as num).toDouble();

            // Phân loại màu sắc
            Color markerColor = Colors.red;
            if (item['activityType'] == 'FOOD') markerColor = Colors.orange;
            if (item['activityType'] == 'MEDICAL') markerColor = Colors.blue;

            loadedMarkers.add(
              Marker(
                point: LatLng(lat, lng),
                width: 45,
                height: 45,
                child: GestureDetector(
                  onTap: () {
                    _showShortInfo(context, item);
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(blurRadius: 5, color: Colors.black26),
                          ],
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: markerColor,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        }

        if (mounted) {
          setState(() {
            _markers = loadedMarkers;
            _isLoading = false;
          });
          print("Đã load được ${_markers.length} địa điểm");
        }
      } else {
        print('Lỗi server: ${response.statusCode} - ${response.body}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Lỗi kết nối: $e');
      setState(() => _isLoading = false);
    }
  }

  // Popup thông tin
  void _showShortInfo(BuildContext context, dynamic item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        height: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item['title'] ?? 'Cần giúp đỡ',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(),
            Text("Loại hỗ trợ: ${item['activityType'] ?? 'Khác'}"),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  print("Người dùng muốn xem chi tiết ID: ${item['id']}");
                  // Sau này điều hướng sang trang Đăng nhập hoặc Chi tiết tại đây
                },
                child: const Text("Xem chi tiết"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bản đồ cứu trợ')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(10.7769, 106.7009), // HCM
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tiles.goong.io/assets/goong_map_web/{z}/{x}/{y}.png?api_key=$apiKey',
                  additionalOptions: {'apiKey': goongMapKey},
                  // tileProvider: FMTCStore('goong').getTileProvider(),
                ),
                MarkerLayer(markers: _markers),
              ],
            ),
    );
  }
}
