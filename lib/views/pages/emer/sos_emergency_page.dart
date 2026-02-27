import 'package:flutter/material.dart';
import 'package:mobile/services/emergency_service.dart';
import 'package:mobile/services/chat/chat_socket_service.dart';

class SosEmergencyPage extends StatefulWidget {
  const SosEmergencyPage({super.key});

  @override
  State<SosEmergencyPage> createState() => _SosEmergencyPageState();
}

class _SosEmergencyPageState extends State<SosEmergencyPage>
    with SingleTickerProviderStateMixin {
  final EmergencyService _emergencyService = EmergencyService();
  final ChatSocketService _socketService = ChatSocketService();

  bool _isLoading = false;
  bool _sosSent = false;
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();

    // Ripple animation - tỏa ra từ nút
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    // Listen for SOS sent confirmation
    _socketService.onSOSSent = (data) {
      if (mounted) {
        setState(() {
          _sosSent = true;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Đã gửi thành công! Admin sẽ liên hệ sớm.'),
            backgroundColor: Color(0xff008080),
            duration: Duration(seconds: 3),
          ),
        );

        // Reset sau 6 giây
        Future.delayed(const Duration(seconds: 6), () {
          if (mounted) {
            setState(() {
              _sosSent = false;
            });
          }
        });
      }
    };
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  Future<void> _sendSOS() async {
    if (_isLoading || _sosSent) return;

    // Hiển thị confirm dialog với màu teal
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.emergency, color: Color(0xff008080), size: 28),
            SizedBox(width: 10),
            Text('Xác nhận gửi yêu cầu'),
          ],
        ),
        content: const Text(
          'Bạn có chắc chắn muốn gửi yêu cầu hỗ trợ khẩn cấp?\n\n'
          'Admin sẽ nhận được thông báo và liên hệ với bạn ngay.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff008080),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Gửi ngay'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Gửi SOS qua Socket.IO (now async)
      await _socketService.sendSOS();

      // Backup: Gửi qua REST API (nếu socket fail)
      await _emergencyService.createEmergency();

      if (!mounted) return;

      setState(() {
        _sosSent = true;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Yêu cầu đã được gửi! Admin sẽ liên hệ với bạn sớm.'),
          backgroundColor: Color(0xff008080),
          duration: Duration(seconds: 4),
        ),
      );

      // Reset sau 6 giây
      Future.delayed(const Duration(seconds: 6), () {
        if (mounted) {
          setState(() {
            _sosSent = false;
          });
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const tealColor = Color(0xff008080);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFC),
      appBar: AppBar(
        title: const Text(
          'Hỗ Trợ Khẩn Cấp',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: tealColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFAFDFD), Color(0xFFE8F6F6)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Tiêu đề
                  const Text(
                    'Hỗ Trợ Khẩn Cấp',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: tealColor,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Mô tả ngắn
                  const Text(
                    'Nhấn nút bên dưới để gửi yêu cầu\nAdmin sẽ liên hệ với bạn ngay lập tức',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xff666666),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 60),

                  // Nút Emergency với ripple effect
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ripple circles - chỉ hiện khi chưa gửi
                      if (!_sosSent && !_isLoading)
                        AnimatedBuilder(
                          animation: _rippleAnimation,
                          builder: (context, child) {
                            return Container(
                              width: 200 + (100 * _rippleAnimation.value),
                              height: 200 + (100 * _rippleAnimation.value),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: tealColor.withValues(
                                    alpha: 0.4 * (1 - _rippleAnimation.value),
                                  ),
                                  width: 3,
                                ),
                              ),
                            );
                          },
                        ),

                      // Nút chính
                      if (!_sosSent)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _isLoading ? null : _sendSOS,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            customBorder: const CircleBorder(),
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: tealColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: tealColor.withValues(alpha: 0.4),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: _isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 5,
                                      ),
                                    )
                                  : const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.emergency,
                                          size: 70,
                                          color: Colors.white,
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'GỬI YÊU CẦU',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),

                      // Trạng thái đã gửi
                      if (_sosSent)
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xff10B981),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withValues(alpha: 0.4),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 70,
                                color: Colors.white,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'ĐÃ GỬI',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Admin sẽ liên hệ sớm',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 60),

                  // Features list - card hợp nhất
                  // Container(
                  //   margin: const EdgeInsets.symmetric(horizontal: 20),
                  //   padding: const EdgeInsets.all(20),
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.circular(16),
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: tealColor.withValues(alpha: 0.08),
                  //         blurRadius: 20,
                  //         offset: const Offset(0, 4),
                  //       ),
                  //     ],
                  //   ),
                  //   child: Column(
                  //     children: [
                  //       _buildFeatureItem(
                  //         Icons.notifications_active,
                  //         'Thông báo ngay lập tức',
                  //       ),
                  //       const SizedBox(height: 16),
                  //       _buildFeatureItem(
                  //         Icons.phone,
                  //         'Admin gọi điện cho bạn',
                  //       ),
                  //       const SizedBox(height: 16),
                  //       _buildFeatureItem(
                  //         Icons.support_agent,
                  //         'Hỗ trợ 24/7',
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  // const SizedBox(height: 24),

                  // Hướng dẫn sử dụng
                  // if (!_sosSent && !_isLoading)
                  //   Container(
                  //     margin: const EdgeInsets.symmetric(horizontal: 20),
                  //     padding: const EdgeInsets.all(16),
                  //     decoration: BoxDecoration(
                  //       color: const Color(0xffFFF9E6),
                  //       borderRadius: BorderRadius.circular(12),
                  //       border: Border.all(
                  //         color: const Color(0xffFFC107),
                  //         width: 1,
                  //       ),
                  //     ),
                  //     child: const Row(
                  //       children: [
                  //         Icon(
                  //           Icons.info_outline,
                  //           color: Color(0xffF59E0B),
                  //           size: 22,
                  //         ),
                  //         SizedBox(width: 12),
                  //         Expanded(
                  //           child: Text(
                  //             'Chỉ sử dụng khi thực sự cần hỗ trợ khẩn cấp',
                  //             style: TextStyle(
                  //               fontSize: 13,
                  //               color: Color(0xff92400E),
                  //               fontWeight: FontWeight.w500,
                  //             ),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildFeatureItem(IconData icon, String text) {
  //   return Row(
  //     children: [
  //       Container(
  //         padding: const EdgeInsets.all(10),
  //         decoration: BoxDecoration(
  //           color: const Color(0xffE0F2F2),
  //           borderRadius: BorderRadius.circular(10),
  //         ),
  //         child: Icon(
  //           icon,
  //           color: const Color(0xff008080),
  //           size: 22,
  //         ),
  //       ),
  //       const SizedBox(width: 14),
  //       Expanded(
  //         child: Text(
  //           text,
  //           style: const TextStyle(
  //             fontSize: 14,
  //             color: Color(0xff333333),
  //             fontWeight: FontWeight.w500,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
