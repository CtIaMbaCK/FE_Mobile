import 'package:mobile/utils/date_utils.dart';

class HelpRequestModel {
  final String id;
  final String requesterId;
  final String? volunteerId;
  final DateTime? acceptedAt;
  final String activityType;
  final String title;
  final String? description;
  final String urgencyLevel;
  final String district;
  final String addressDetail;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime startTime;
  final DateTime endTime;
  final String recurrence;
  final String status;
  final List<String> activityImages;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;
  final DateTime? doneAt;
  final List<String> proofImages;
  final String? completionNotes;

  // Thông tin thêm của NCGD (Trả về từ getRequestDetail)
  final Map<String, dynamic>? requester;

  HelpRequestModel({
    required this.id,
    required this.requesterId,
    this.volunteerId,
    this.acceptedAt,
    required this.activityType,
    required this.title,
    this.description,
    required this.urgencyLevel,
    required this.district,
    required this.addressDetail,
    required this.startDate,
    this.endDate,
    required this.startTime,
    required this.endTime,
    required this.recurrence,
    required this.status,
    required this.activityImages,
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.doneAt,
    required this.proofImages,
    this.completionNotes,
    this.requester,
  });

  factory HelpRequestModel.fromJson(Map<String, dynamic> json) {
    // Hàm helper để parse DateTime an toàn, tránh crash app nếu data lỗi
    DateTime safeParse(dynamic value) {
      if (value == null) return DateTime.now();
      try {
        return DateTimeUtils.parseFromApi(value.toString());
      } catch (e) {
        return DateTime.now();
      }
    }

    return HelpRequestModel(
      id: json['id']?.toString() ?? '',
      requesterId: json['requesterId']?.toString() ?? '',
      volunteerId: json['volunteerId']?.toString(),
      acceptedAt: json['acceptedAt'] != null
          ? DateTimeUtils.parseFromApi(json['acceptedAt'])
          : null,
      activityType: json['activityType']?.toString() ?? 'OTHER',
      title: json['title']?.toString() ?? 'Không tiêu đề',
      description: json['description']?.toString(),
      urgencyLevel: json['urgencyLevel']?.toString() ?? 'STANDARD',
      district: json['district']?.toString() ?? '',
      addressDetail: json['addressDetail']?.toString() ?? '',

      // Sử dụng safeParse cho các trường bắt buộc để không bao giờ bị crash
      startDate: safeParse(json['startDate']),
      endDate: json['endDate'] != null
          ? DateTimeUtils.parseFromApi(json['endDate'])
          : null,
      startTime: safeParse(json['startTime']),
      endTime: safeParse(json['endTime']),

      recurrence: json['recurrence']?.toString() ?? 'NONE',
      status: json['status']?.toString() ?? 'PENDING',

      // Ép kiểu List an toàn
      activityImages:
          (json['activityImages'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],

      createdAt: safeParse(json['createdAt']),

      // Ép kiểu số thực an toàn
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,

      doneAt: json['doneAt'] != null
          ? DateTimeUtils.parseFromApi(json['doneAt'])
          : null,
      proofImages:
          (json['proofImages'] as List?)?.map((e) => e.toString()).toList() ??
          [],
      completionNotes: json['completionNotes']?.toString(),
      requester: json['requester'] != null
          ? json['requester'] as Map<String, dynamic>
          : null,
    );
  }
}
