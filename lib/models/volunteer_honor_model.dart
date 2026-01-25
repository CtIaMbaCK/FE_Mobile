class VolunteerHonorModel {
  final String id;
  final String email;
  final String phoneNumber;
  final VolunteerHonorProfile? volunteerProfile;

  VolunteerHonorModel({
    required this.id,
    required this.email,
    required this.phoneNumber,
    this.volunteerProfile,
  });

  factory VolunteerHonorModel.fromJson(Map<String, dynamic> json) {
    return VolunteerHonorModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      volunteerProfile: json['volunteerProfile'] != null
          ? VolunteerHonorProfile.fromJson(json['volunteerProfile'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phoneNumber': phoneNumber,
      'volunteerProfile': volunteerProfile?.toJson(),
    };
  }
}

class VolunteerHonorProfile {
  final String fullName;
  final String? avatarUrl;
  final int points;
  final List<String>? skills;
  final String? district;

  VolunteerHonorProfile({
    required this.fullName,
    this.avatarUrl,
    required this.points,
    this.skills,
    this.district,
  });

  factory VolunteerHonorProfile.fromJson(Map<String, dynamic> json) {
    return VolunteerHonorProfile(
      fullName: json['fullName'] ?? '',
      avatarUrl: json['avatarUrl'],
      points: json['points'] ?? 0,
      skills: json['skills'] != null
          ? List<String>.from(json['skills'])
          : null,
      district: json['district'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'avatarUrl': avatarUrl,
      'points': points,
      'skills': skills,
      'district': district,
    };
  }
}

class VolunteerListResponse {
  final List<VolunteerHonorModel> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  VolunteerListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory VolunteerListResponse.fromJson(Map<String, dynamic> json) {
    return VolunteerListResponse(
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => VolunteerHonorModel.fromJson(item))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}
