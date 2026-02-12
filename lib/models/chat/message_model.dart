import 'package:mobile/utils/date_utils.dart';

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final MessageSenderModel? sender;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    this.sender,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      conversationId: json['conversationId'],
      senderId: json['senderId'],
      content: json['content'],
      isRead: json['isRead'],
      readAt: json['readAt'] != null ? DateTimeUtils.parseFromApi(json['readAt']) : null,
      createdAt: DateTimeUtils.parseFromApi(json['createdAt']),
      sender: json['sender'] != null
          ? MessageSenderModel.fromJson(json['sender'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'content': content,
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'sender': sender?.toJson(),
    };
  }

  // Copy with method cho optimistic updates
  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? content,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
    MessageSenderModel? sender,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      sender: sender ?? this.sender,
    );
  }
}

class MessageSenderModel {
  final String id;
  final String role;
  final VolunteerProfileData? volunteerProfile;
  final BeneficiaryProfileData? bficiaryProfile;
  final OrganizationProfileData? organizationProfiles;

  MessageSenderModel({
    required this.id,
    required this.role,
    this.volunteerProfile,
    this.bficiaryProfile,
    this.organizationProfiles,
  });

  factory MessageSenderModel.fromJson(Map<String, dynamic> json) {
    return MessageSenderModel(
      id: json['id'],
      role: json['role'],
      volunteerProfile: json['volunteerProfile'] != null
          ? VolunteerProfileData.fromJson(json['volunteerProfile'])
          : null,
      bficiaryProfile: json['bficiaryProfile'] != null
          ? BeneficiaryProfileData.fromJson(json['bficiaryProfile'])
          : null,
      organizationProfiles: json['organizationProfiles'] != null
          ? OrganizationProfileData.fromJson(json['organizationProfiles'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'volunteerProfile': volunteerProfile?.toJson(),
      'bficiaryProfile': bficiaryProfile?.toJson(),
      'organizationProfiles': organizationProfiles?.toJson(),
    };
  }

  String get displayName {
    if (role == 'VOLUNTEER') {
      return volunteerProfile?.fullName ?? 'Tình nguyện viên';
    } else if (role == 'BENEFICIARY') {
      return bficiaryProfile?.fullName ?? 'Người cần giúp đỡ';
    } else if (role == 'ORGANIZATION') {
      return organizationProfiles?.organizationName ?? 'Tổ chức';
    }
    return 'Admin';
  }

  String? get avatarUrl {
    if (role == 'VOLUNTEER') {
      return volunteerProfile?.avatarUrl;
    } else if (role == 'BENEFICIARY') {
      return bficiaryProfile?.avatarUrl;
    } else if (role == 'ORGANIZATION') {
      return organizationProfiles?.avatarUrl;
    }
    return null;
  }
}

class VolunteerProfileData {
  final String? fullName;
  final String? avatarUrl;

  VolunteerProfileData({this.fullName, this.avatarUrl});

  factory VolunteerProfileData.fromJson(Map<String, dynamic> json) {
    return VolunteerProfileData(
      fullName: json['fullName'],
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'avatarUrl': avatarUrl,
    };
  }
}

class BeneficiaryProfileData {
  final String? fullName;
  final String? avatarUrl;

  BeneficiaryProfileData({this.fullName, this.avatarUrl});

  factory BeneficiaryProfileData.fromJson(Map<String, dynamic> json) {
    return BeneficiaryProfileData(
      fullName: json['fullName'],
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'avatarUrl': avatarUrl,
    };
  }
}

class OrganizationProfileData {
  final String? organizationName;
  final String? avatarUrl;

  OrganizationProfileData({this.organizationName, this.avatarUrl});

  factory OrganizationProfileData.fromJson(Map<String, dynamic> json) {
    return OrganizationProfileData(
      organizationName: json['organizationName'],
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'organizationName': organizationName,
      'avatarUrl': avatarUrl,
    };
  }
}
