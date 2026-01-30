class OrganizationModel {
  final String id;
  final String email;
  final String phoneNumber;
  final String status;
  final OrganizationProfile? organizationProfiles;

  OrganizationModel({
    required this.id,
    required this.email,
    required this.phoneNumber,
    required this.status,
    this.organizationProfiles,
  });

  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    return OrganizationModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      status: json['status'] ?? '',
      organizationProfiles: json['organizationProfiles'] != null
          ? OrganizationProfile.fromJson(json['organizationProfiles'])
          : null,
    );
  }

  // Factory method cho top organizations từ public API
  factory OrganizationModel.fromTopOrgJson(Map<String, dynamic> json) {
    return OrganizationModel(
      id: json['organizationId'] ?? '',
      email: '',
      phoneNumber: '',
      status: 'ACTIVE',
      organizationProfiles: OrganizationProfile(
        organizationName: json['organizationName'] ?? '',
        avatarUrl: json['avatarUrl'],
        district: null,
        addressDetail: json['description'],
        representativeName: null,
        establishedYear: null,
        totalCampaigns: json['completedCampaigns'],
        totalVolunteers: null,
        createdAt: null,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phoneNumber': phoneNumber,
      'status': status,
      'organizationProfiles': organizationProfiles?.toJson(),
    };
  }
}

class OrganizationProfile {
  final String organizationName;
  final String? avatarUrl;
  final String? district;
  final String? addressDetail;
  final String? representativeName;
  final String? establishedYear;
  final int? totalCampaigns;
  final int? totalVolunteers;
  final String? createdAt;

  OrganizationProfile({
    required this.organizationName,
    this.avatarUrl,
    this.district,
    this.addressDetail,
    this.representativeName,
    this.establishedYear,
    this.totalCampaigns,
    this.totalVolunteers,
    this.createdAt,
  });

  // Helper để lấy địa chỉ đầy đủ
  String get fullAddress {
    if (addressDetail != null && district != null) {
      return '$addressDetail, $district';
    }
    return addressDetail ?? district ?? 'Chưa có địa chỉ';
  }

  factory OrganizationProfile.fromJson(Map<String, dynamic> json) {
    return OrganizationProfile(
      organizationName: json['organizationName'] ?? '',
      avatarUrl: json['avatarUrl'],
      district: json['district'],
      addressDetail: json['addressDetail'],
      representativeName: json['representativeName'],
      establishedYear: json['establishedYear'],
      totalCampaigns: json['totalCampaigns'],
      totalVolunteers: json['totalVolunteers'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'organizationName': organizationName,
      'avatarUrl': avatarUrl,
      'district': district,
      'addressDetail': addressDetail,
      'representativeName': representativeName,
      'establishedYear': establishedYear,
      'totalCampaigns': totalCampaigns,
      'totalVolunteers': totalVolunteers,
      'createdAt': createdAt,
    };
  }
}

class OrganizationListResponse {
  final List<OrganizationModel> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  OrganizationListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory OrganizationListResponse.fromJson(Map<String, dynamic> json) {
    return OrganizationListResponse(
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrganizationModel.fromJson(item))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}
