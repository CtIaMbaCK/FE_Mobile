import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile/models/certificate_model.dart';
import 'package:mobile/services/certificate_service.dart';
import 'package:mobile/utils/image_download_utils.dart';
import 'package:mobile/views/pages/profile/certificate_viewer_page.dart';
import 'package:intl/intl.dart';

class VolunteerCertificatesPage extends StatefulWidget {
  const VolunteerCertificatesPage({Key? key}) : super(key: key);

  @override
  State<VolunteerCertificatesPage> createState() =>
      _VolunteerCertificatesPageState();
}

class _VolunteerCertificatesPageState
    extends State<VolunteerCertificatesPage> {
  final CertificateService _service = CertificateService();
  List<CertificateModel> _certificates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  Future<void> _loadCertificates() async {
    setState(() => _isLoading = true);
    try {
      print('📜 Loading certificates...');
      final certs = await _service.getMyCertificates();
      print('📥 Loaded ${certs.length} certificates');
      if (mounted) {
        setState(() {
          _certificates = certs;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('❌ Error loading certificates: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _certificates = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải chứng nhận: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFC),
      appBar: AppBar(
        title: const Text('Chứng nhận của tôi'),
        backgroundColor: const Color(0xFF008080),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _certificates.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadCertificates,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _certificates.length,
                    itemBuilder: (context, index) =>
                        _buildCertificateCard(_certificates[index]),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.workspace_premium,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có chứng nhận',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tham gia hoạt động để nhận chứng nhận',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateCard(CertificateModel cert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ảnh chứng nhận
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            child: CachedNetworkImage(
              imageUrl: cert.pdfUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 200,
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 200,
                color: Colors.grey[200],
                child: const Icon(
                  Icons.error,
                  size: 48,
                  color: Colors.grey,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  cert.templateTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Issuer
                Row(
                  children: [
                    const Icon(Icons.business, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Cấp bởi: ${cert.issuerName}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Date
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Ngày cấp: ${DateFormat('dd/MM/yyyy').format(cert.issuedAt)}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),

                if (cert.notes != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    cert.notes!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _viewCertificate(cert),
                        icon: const Icon(Icons.visibility),
                        label: const Text('Xem'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF008080),
                          side: const BorderSide(
                            color: Color(0xFF008080),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _downloadCertificate(cert),
                        icon: const Icon(Icons.download),
                        label: const Text('Lưu'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF008080),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _viewCertificate(CertificateModel cert) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CertificateViewerPage(certificate: cert),
      ),
    );
  }

  Future<void> _downloadCertificate(CertificateModel cert) async {
    await ImageDownloadUtils.saveImageToGallery(
      imageUrl: cert.pdfUrl,
      context: context,
      fileName:
          'certificate_${cert.templateTitle}_${cert.issuedAt.millisecondsSinceEpoch}',
    );
  }
}
