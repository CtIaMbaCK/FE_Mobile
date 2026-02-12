import 'package:mobile/utils/date_utils.dart';

class CampaignModel {
  final String id;
  final String organizationId;
  final String status;
  final String title;
  final String? description;
  final String? goal;
  final String district;
  final String addressDetail;
  final DateTime startDate;
  final DateTime? endDate;
  final String? coverImage;
  final List<String> images;
  final int targetVolunteers;
  final int maxVolunteers;
  final int currentVolunteers;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Organization info
  final OrganizationInfo? organization;
  final int? registrationsCount;

  CampaignModel({
    required this.id,
    required this.organizationId,
    required this.status,
    required this.title,
    this.description,
    this.goal,
    required this.district,
    required this.addressDetail,
    required this.startDate,
    this.endDate,
    this.coverImage,
    required this.images,
    required this.targetVolunteers,
    required this.maxVolunteers,
    required this.currentVolunteers,
    required this.createdAt,
    required this.updatedAt,
    this.organization,
    this.registrationsCount,
  });

  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    DateTime safeParse(dynamic value) {
      if (value == null) return DateTime.now();
      try {
        return DateTimeUtils.parseFromApi(value.toString());
      } catch (e) {
        return DateTime.now();
      }
    }

    return CampaignModel(
      id: json['id']?.toString() ?? '',
      organizationId: json['organizationId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      title: json['title']?.toString() ?? 'Không có tiêu đề',
      description: json['description']?.toString(),
      goal: json['goal']?.toString(),
      district: json['district']?.toString() ?? '',
      addressDetail: json['addressDetail']?.toString() ?? '',
      startDate: safeParse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
      coverImage: json['coverImage']?.toString(),
      images: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
      targetVolunteers: json['targetVolunteers'] ?? 0,
      maxVolunteers: json['maxVolunteers'] ?? 0,
      currentVolunteers: json['currentVolunteers'] ?? 0,
      createdAt: safeParse(json['createdAt']),
      updatedAt: safeParse(json['updatedAt']),
      organization: json['organization'] != null
          ? OrganizationInfo.fromJson(json['organization'])
          : null,
      registrationsCount: json['_count']?['registrations'],
    );
  }
}

class OrganizationInfo {
  final String id;
  final String email;
  final String? organizationName;
  final String? avatarUrl;

  OrganizationInfo({
    required this.id,
    required this.email,
    this.organizationName,
    this.avatarUrl,
  });

  factory OrganizationInfo.fromJson(Map<String, dynamic> json) {
    return OrganizationInfo(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      organizationName: json['organizationProfiles']?['organizationName']?.toString(),
      avatarUrl: json['organizationProfiles']?['avatarUrl']?.toString(),
    );
  }
}

class CampaignRegistrationModel {
  final String id;
  final String campaignId;
  final String volunteerId;
  final String status;
  final DateTime registeredAt;
  final String? notes;
  final CampaignModel? campaign;

  CampaignRegistrationModel({
    required this.id,
    required this.campaignId,
    required this.volunteerId,
    required this.status,
    required this.registeredAt,
    this.notes,
    this.campaign,
  });

  factory CampaignRegistrationModel.fromJson(Map<String, dynamic> json) {
    return CampaignRegistrationModel(
      id: json['id']?.toString() ?? '',
      campaignId: json['campaignId']?.toString() ?? '',
      volunteerId: json['volunteerId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'REGISTERED',
      registeredAt: json['registeredAt'] != null
          ? DateTimeUtils.parseFromApi(json['registeredAt'])
          : DateTime.now(),
      notes: json['notes']?.toString(),
      campaign: json['campaign'] != null
          ? CampaignModel.fromJson(json['campaign'])
          : null,
    );
  }
}
