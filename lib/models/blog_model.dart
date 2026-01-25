class BlogModel {
  final String id;
  final String title;
  final String? content;
  final String? coverImage;
  final String createdAt;
  final String? updatedAt;
  final OrganizationInfo? organization;

  BlogModel({
    required this.id,
    required this.title,
    this.content,
    this.coverImage,
    required this.createdAt,
    this.updatedAt,
    this.organization,
  });

  factory BlogModel.fromJson(Map<String, dynamic> json) {
    return BlogModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'],
      coverImage: json['coverImage'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'],
      organization: json['organization'] != null
          ? OrganizationInfo.fromJson(json['organization'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'coverImage': coverImage,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'organization': organization?.toJson(),
    };
  }
}

class OrganizationInfo {
  final String? organizationName;
  final String? avatarUrl;

  OrganizationInfo({
    this.organizationName,
    this.avatarUrl,
  });

  factory OrganizationInfo.fromJson(Map<String, dynamic> json) {
    final profiles = json['organizationProfiles'];
    return OrganizationInfo(
      organizationName: profiles?['organizationName'],
      avatarUrl: profiles?['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'organizationProfiles': {
        'organizationName': organizationName,
        'avatarUrl': avatarUrl,
      },
    };
  }
}

class BlogListResponse {
  final List<BlogModel> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  BlogListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory BlogListResponse.fromJson(Map<String, dynamic> json) {
    return BlogListResponse(
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => BlogModel.fromJson(item))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}
