import 'package:mobile/utils/date_utils.dart';

// Model cho Review (từ NCGD)
class ReviewModel {
  final String id;
  final String activityId;
  final String reviewerId;
  final String targetId;
  final int rating;  // 1-5
  final String? comment;
  final DateTime createdAt;

  // Nested data
  final ReviewerInfo? reviewer;
  final ActivityInfo? activity;

  ReviewModel({
    required this.id,
    required this.activityId,
    required this.reviewerId,
    required this.targetId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.reviewer,
    this.activity,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      activityId: json['activityId'],
      reviewerId: json['reviewerId'],
      targetId: json['targetId'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTimeUtils.parseFromApi(json['createdAt']),
      reviewer: json['reviewer'] != null
          ? ReviewerInfo.fromJson(json['reviewer'])
          : null,
      activity: json['activity'] != null
          ? ActivityInfo.fromJson(json['activity'])
          : null,
    );
  }
}

// Model cho Appreciation (cảm ơn từ NCGD)
class AppreciationModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String activityId;
  final DateTime createdAt;

  final ReviewerInfo? sender;
  final ActivityInfo? activity;

  AppreciationModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.activityId,
    required this.createdAt,
    this.sender,
    this.activity,
  });

  factory AppreciationModel.fromJson(Map<String, dynamic> json) {
    return AppreciationModel(
      id: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      activityId: json['activityId'],
      createdAt: DateTimeUtils.parseFromApi(json['createdAt']),
      sender: json['sender'] != null
          ? ReviewerInfo.fromJson(json['sender'])
          : null,
      activity: json['activity'] != null
          ? ActivityInfo.fromJson(json['activity'])
          : null,
    );
  }
}

// Model cho VolunteerComment (từ TCXH/Admin)
class VolunteerCommentModel {
  final String id;
  final String volunteerId;
  final String? organizationId;  // null = Admin comment
  final String comment;
  final int? rating;  // 1-5, optional
  final DateTime createdAt;
  final DateTime updatedAt;

  final OrganizationInfo? organization;

  String get issuerName {
    if (organizationId == null) return 'Admin';
    return organization?.organizationName ?? 'Tổ chức';
  }

  VolunteerCommentModel({
    required this.id,
    required this.volunteerId,
    this.organizationId,
    required this.comment,
    this.rating,
    required this.createdAt,
    required this.updatedAt,
    this.organization,
  });

  factory VolunteerCommentModel.fromJson(Map<String, dynamic> json) {
    return VolunteerCommentModel(
      id: json['id'],
      volunteerId: json['volunteerId'],
      organizationId: json['organizationId'],
      comment: json['comment'],
      rating: json['rating'],
      createdAt: DateTimeUtils.parseFromApi(json['createdAt']),
      updatedAt: DateTimeUtils.parseFromApi(json['updatedAt']),
      organization: json['organization'] != null
          ? OrganizationInfo.fromJson(json['organization'])
          : null,
    );
  }
}

// Helper models
class ReviewerInfo {
  final String fullName;
  final String? avatarUrl;

  ReviewerInfo({required this.fullName, this.avatarUrl});

  factory ReviewerInfo.fromJson(Map<String, dynamic> json) {
    // API có thể trả về nested profile
    if (json['bficiaryProfile'] != null) {
      return ReviewerInfo(
        fullName: json['bficiaryProfile']['fullName'] ?? 'Người dùng',
        avatarUrl: json['bficiaryProfile']['avatarUrl'],
      );
    }
    return ReviewerInfo(
      fullName: json['fullName'] ?? 'Người dùng',
      avatarUrl: json['avatarUrl'],
    );
  }
}

class ActivityInfo {
  final String id;
  final String title;

  ActivityInfo({required this.id, required this.title});

  factory ActivityInfo.fromJson(Map<String, dynamic> json) {
    return ActivityInfo(
      id: json['id'],
      title: json['title'] ?? 'Hoạt động',
    );
  }
}

class OrganizationInfo {
  final String organizationName;
  final String? avatarUrl;

  OrganizationInfo({required this.organizationName, this.avatarUrl});

  factory OrganizationInfo.fromJson(Map<String, dynamic> json) {
    if (json['organizationProfiles'] != null) {
      return OrganizationInfo(
        organizationName: json['organizationProfiles']['organizationName'] ?? 'Tổ chức',
        avatarUrl: json['organizationProfiles']['avatarUrl'],
      );
    }
    return OrganizationInfo(
      organizationName: json['organizationName'] ?? 'Tổ chức',
      avatarUrl: json['avatarUrl'],
    );
  }
}
