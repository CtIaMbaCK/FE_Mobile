// lib/helper/enum_helpers.dart
// Helper classes để map backend enums sang Vietnamese display names

class SkillHelper {
  static const Map<String, String> displayNames = {
    'TEACHING': 'Giảng dạy',
    'MEDICAL': 'Y tế',
    'PSYCHOLOGICAL': 'Tâm lý',
    'CONSTRUCTION': 'Xây dựng',
    'COOKING': 'Nấu ăn',
    'CHILDCARE': 'Chăm sóc trẻ em',
    'ELDERLY_CARE': 'Chăm sóc người già',
    'DISABILITY_SUPPORT': 'Hỗ trợ người khuyết tật',
    'TRANSLATION': 'Phiên dịch',
    'TECHNOLOGY': 'Công nghệ',
    'LEGAL': 'Pháp lý',
    'FINANCIAL': 'Tài chính',
    'LOGISTICS': 'Hậu cần',
    'OTHER': 'Khác',
  };

  static String getDisplayName(String skill) {
    return displayNames[skill] ?? skill;
  }

  static List<String> getAllSkills() {
    return displayNames.keys.toList();
  }

  static String? getKeyFromDisplayName(String displayName) {
    return displayNames.entries
        .firstWhere(
          (entry) => entry.value == displayName,
          orElse: () => MapEntry('', ''),
        )
        .key;
  }
}

class DistrictHelper {
  static const Map<String, String> displayNames = {
    'QUAN_1': 'Quận 1',
    'QUAN_3': 'Quận 3',
    'QUAN_4': 'Quận 4',
    'QUAN_5': 'Quận 5',
    'QUAN_6': 'Quận 6',
    'QUAN_7': 'Quận 7',
    'QUAN_8': 'Quận 8',
    'QUAN_10': 'Quận 10',
    'QUAN_11': 'Quận 11',
    'QUAN_12': 'Quận 12',
    'GO_VAP': 'Gò Vấp',
    'BINH_THANH': 'Bình Thạnh',
    'TAN_BINH': 'Tân Bình',
    'TAN_PHU': 'Tân Phú',
    'PHU_NHUAN': 'Phú Nhuận',
    'BINH_TAN': 'Bình Tân',
    'THU_DUC': 'Thủ Đức',
    'HOC_MON': 'Hóc Môn',
    'CU_CHI': 'Củ Chi',
    'BINH_CHANH': 'Bình Chánh',
    'NHA_BE': 'Nhà Bè',
    'CAN_GIO': 'Cần Giờ',
  };

  static String getDisplayName(String district) {
    return displayNames[district] ?? district;
  }

  static List<String> getAllDistricts() {
    return displayNames.keys.toList();
  }

  static String? getKeyFromDisplayName(String displayName) {
    return displayNames.entries
        .firstWhere(
          (entry) => entry.value == displayName,
          orElse: () => MapEntry('', ''),
        )
        .key;
  }
}
