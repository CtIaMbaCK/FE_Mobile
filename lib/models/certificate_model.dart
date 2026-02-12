import 'package:mobile/utils/date_utils.dart';

class CertificateModel {
  final String id;
  final String volunteerId;
  final String? organizationId;  // null = Admin certificate
  final String pdfUrl;  // URL ảnh chứng nhận
  final Map<String, dynamic> certificateData;
  final DateTime issuedAt;
  final String? notes;

  // Computed properties
  String get issuerName {
    if (organizationId == null) return 'Admin';
    return certificateData['organizationName'] ?? 'Tổ chức';
  }

  String get volunteerName => certificateData['volunteerName'] ?? '';
  String get templateTitle => certificateData['templateTitle'] ?? 'Chứng nhận';

  CertificateModel({
    required this.id,
    required this.volunteerId,
    this.organizationId,
    required this.pdfUrl,
    required this.certificateData,
    required this.issuedAt,
    this.notes,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    // Parse certificateData
    Map<String, dynamic> certData = {};

    try {
      // Nếu có certificateData field
      if (json['certificateData'] != null) {
        certData = json['certificateData'] is Map<String, dynamic>
            ? json['certificateData']
            : {};
      }

      // Thêm thông tin từ nested objects nếu có
      if (json['template'] != null) {
        certData['templateTitle'] = json['template']['title'] ?? 'Chứng nhận';
      }

      if (json['organization'] != null) {
        final org = json['organization'];
        if (org['organizationProfiles'] != null) {
          certData['organizationName'] =
              org['organizationProfiles']['organizationName'] ?? 'Tổ chức';
        }
      }

      // Thêm volunteer name từ volunteer object nếu có
      if (json['volunteer'] != null) {
        final volunteer = json['volunteer'];
        if (volunteer['volunteerProfile'] != null) {
          certData['volunteerName'] =
              volunteer['volunteerProfile']['fullName'] ?? '';
        }
      }
    } catch (e) {
      print('❌ Error parsing certificate data: $e');
    }

    return CertificateModel(
      id: json['id'] ?? '',
      volunteerId: json['volunteerId'] ?? '',
      organizationId: json['organizationId'],
      pdfUrl: json['pdfUrl'] ?? '',
      certificateData: certData,
      issuedAt: DateTimeUtils.parseFromApi(json['issuedAt']),
      notes: json['notes'],
    );
  }
}
