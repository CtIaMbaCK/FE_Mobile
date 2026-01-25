import 'package:flutter/material.dart';
import 'package:mobile/models/campaign_model.dart';
import 'package:mobile/services/campaign_service.dart';

class CampaignDetailPage extends StatefulWidget {
  final CampaignModel campaign;

  const CampaignDetailPage({Key? key, required this.campaign})
      : super(key: key);

  @override
  State<CampaignDetailPage> createState() => _CampaignDetailPageState();
}

class _CampaignDetailPageState extends State<CampaignDetailPage> {
  final CampaignService _campaignService = CampaignService();
  final TextEditingController _notesController = TextEditingController();
  bool _isRegistering = false;

  String _getDistrictName(String district) {
    return district.replaceAll('_', ' ').replaceAll('QUAN', 'Quận');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _registerCampaign() async {
    setState(() => _isRegistering = true);

    try {
      final success = await _campaignService.registerCampaign(
        widget.campaign.id,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (mounted) {
        setState(() => _isRegistering = false);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng ký tham gia chiến dịch thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true để refresh list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể đăng ký! Có thể đã hết chỗ hoặc bạn đã đăng ký rồi.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRegistering = false);
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
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spotsLeft = widget.campaign.maxVolunteers - widget.campaign.currentVolunteers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết chiến dịch'),
        backgroundColor: const Color(0xFF008080),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            if (widget.campaign.coverImage != null)
              Image.network(
                widget.campaign.coverImage!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.campaign, size: 50),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề
                  Text(
                    widget.campaign.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Tổ chức
                  if (widget.campaign.organization != null)
                    Row(
                      children: [
                        const Icon(Icons.business, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          widget.campaign.organization!.organizationName ?? 'Tổ chức xã hội',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),

                  // Thông tin chi tiết
                  _buildInfoRow(
                    Icons.location_on,
                    'Địa điểm',
                    '${widget.campaign.addressDetail}, ${_getDistrictName(widget.campaign.district)}',
                    Colors.orange,
                  ),

                  _buildInfoRow(
                    Icons.calendar_today,
                    'Thời gian',
                    '${_formatDate(widget.campaign.startDate)}${widget.campaign.endDate != null ? ' - ${_formatDate(widget.campaign.endDate!)}' : ''}',
                    Colors.blue,
                  ),

                  _buildInfoRow(
                    Icons.people,
                    'Tình nguyện viên',
                    '${widget.campaign.currentVolunteers}/${widget.campaign.maxVolunteers} người (còn $spotsLeft chỗ)',
                    spotsLeft > 0 ? Colors.green : Colors.red,
                  ),

                  // Mục tiêu
                  if (widget.campaign.goal != null &&
                      widget.campaign.goal!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Mục tiêu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.campaign.goal!,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],

                  // Mô tả
                  if (widget.campaign.description != null &&
                      widget.campaign.description!.isNotEmpty) ...[
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
                      widget.campaign.description!,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Ghi chú khi đăng ký
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Ghi chú (không bắt buộc)',
                      hintText: 'Bạn có muốn gửi ghi chú gì không?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Nút đăng ký
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (_isRegistering || spotsLeft <= 0)
                          ? null
                          : _registerCampaign,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF008080),
                        disabledBackgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isRegistering
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              spotsLeft <= 0 ? 'Đã hết chỗ' : 'Đăng ký tham gia',
                              style: const TextStyle(
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
