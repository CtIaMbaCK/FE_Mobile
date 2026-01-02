// lib/models/user_model.dart

class UserModel {
  final String id;
  final String email;
  final String phoneNumber;
  final String role; // "VOLUNTEER" hoặc "BENEFICIARY"
  final String status;
  
  // Thông tin chi tiết nằm trong này
  final dynamic profile; 

  UserModel({
    required this.id,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.status,
    this.profile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String role = json['role'];
    
    return UserModel(
      id: json['id'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      role: role,
      status: json['status'],
      // Nếu role là VOLUNTEER thì map vào VolunteerProfile, ngược lại map vào Beneficiary
      profile: role == 'VOLUNTEER' 
          ? (json['volunteerProfile'] != null ? VolunteerProfile.fromJson(json['volunteerProfile']) : null)
          : (json['bficiaryProfile'] != null ? BeneficiaryProfile.fromJson(json['bficiaryProfile']) : null),
    );
  }
}

// 1. Profile dành cho Tình nguyện viên
class VolunteerProfile {
  final String fullName;
  final String? avatarUrl;
  final int experienceYears;
  final int totalThanks;
  final String? bio;

  VolunteerProfile({
    required this.fullName,
    this.avatarUrl,
    required this.experienceYears,
    required this.totalThanks,
    this.bio,
  });

  factory VolunteerProfile.fromJson(Map<String, dynamic> json) {
    return VolunteerProfile(
      fullName: json['fullName'] ?? "TNV ẩn danh",
      avatarUrl: json['avatarUrl'],
      experienceYears: json['experienceYears'] ?? 0,
      totalThanks: json['totalThanks'] ?? 0,
      bio: json['bio'],
    );
  }
}

// 2. Profile dành cho Người cần giúp đỡ (Beneficiary)
class BeneficiaryProfile {
  final String fullName;
  final String? avatarUrl;
  final String vulnerabilityType;
  final String? situationDescription;
  final List<String> proofFiles;

  BeneficiaryProfile({
    required this.fullName,
    this.avatarUrl,
    required this.vulnerabilityType,
    this.situationDescription,
    required this.proofFiles,
  });

  factory BeneficiaryProfile.fromJson(Map<String, dynamic> json) {
    return BeneficiaryProfile(
      fullName: json['fullName'] ?? "Người dùng",
      avatarUrl: json['avatarUrl'],
      vulnerabilityType: json['vulnerabilityType'] ?? "OTHER",
      situationDescription: json['situationDescription'],
      proofFiles: json['proofFiles'] != null ? List<String>.from(json['proofFiles']) : [],
    );
  }
}