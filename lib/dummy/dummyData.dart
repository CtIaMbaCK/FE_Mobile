const userData = {
  "user1": {"phoneNum": "123", "password": "456"},
  "user2": {"phoneNum": "1233", "password": "4566"},
};

const dummyVolunteerTest = [
  {
    "name": "TestUser",
    "campaigns": "120 chiến dịch",
    "imageUrl":
        "https://www.hollywoodreporter.com/wp-content/uploads/2012/12/img_logo_blue.jpg?w=1440&h=810&crop=1",
  },
  {
    "name": "TestUser",
    "campaigns": "120 chiến dịch",
    "imageUrl":
        "https://www.hollywoodreporter.com/wp-content/uploads/2012/12/img_logo_blue.jpg?w=1440&h=810&crop=1",
  },
  {
    "name": "TestUser",
    "campaigns": "120 chiến dịch",
    "imageUrl":
        "https://www.hollywoodreporter.com/wp-content/uploads/2012/12/img_logo_blue.jpg?w=1440&h=810&crop=1",
  },
  {
    "name": "TestUser",
    "campaigns": "120 chiến dịch",
    "imageUrl":
        "https://www.hollywoodreporter.com/wp-content/uploads/2012/12/img_logo_blue.jpg?w=1440&h=810&crop=1",
  },
  {
    "name": "TestUser",
    "campaigns": "120 chiến dịch",
    "imageUrl":
        "https://www.hollywoodreporter.com/wp-content/uploads/2012/12/img_logo_blue.jpg?w=1440&h=810&crop=1",
  },
];

// 1. Định nghĩa khuôn mẫu (Model)
class Volunteer {
  final String name;
  final String campaigns; // Hoặc 'hours' tùy bạn đặt
  final String imageUrl;

  Volunteer({
    required this.name,
    required this.campaigns,
    required this.imageUrl,
  });
}

// 2. Tạo dữ liệu giả từ khuôn mẫu đó
final List<Volunteer> dummyVolunteer = [
  Volunteer(
    name: "TestUser 1",
    campaigns: "120 chiến dịch",
    imageUrl:
        "https://www.hollywoodreporter.com/wp-content/uploads/2012/12/img_logo_blue.jpg?w=1440&h=810&crop=1",
  ),
  Volunteer(
    name: "TestUser 2",
    campaigns: "50 chiến dịch",
    imageUrl:
        "https://www.hollywoodreporter.com/wp-content/uploads/2012/12/img_logo_blue.jpg?w=1440&h=810&crop=1",
  ),
  Volunteer(
    name: "TestUser 1",
    campaigns: "120 chiến dịch",
    imageUrl:
        "https://www.hollywoodreporter.com/wp-content/uploads/2012/12/img_logo_blue.jpg?w=1440&h=810&crop=1",
  ),
  Volunteer(
    name: "TestUser 2",
    campaigns: "50 chiến dịch",
    imageUrl:
        "https://www.hollywoodreporter.com/wp-content/uploads/2012/12/img_logo_blue.jpg?w=1440&h=810&crop=1",
  ),
  Volunteer(
    name: "TestUser 1",
    campaigns: "120 chiến dịch",
    imageUrl:
        "https://www.hollywoodreporter.com/wp-content/uploads/2012/12/img_logo_blue.jpg?w=1440&h=810&crop=1",
  ),
  Volunteer(
    name: "TestUser 2",
    campaigns: "50 chiến dịch",
    imageUrl:
        "https://www.hollywoodreporter.com/wp-content/uploads/2012/12/img_logo_blue.jpg?w=1440&h=810&crop=1",
  ),
  Volunteer(
    name: "TestUser 1",
    campaigns: "120 chiến dịch",
    imageUrl:
        "https://www.hollywoodreporter.com/wp-content/uploads/2012/12/img_logo_blue.jpg?w=1440&h=810&crop=1",
  ),
  Volunteer(
    name: "TestUser 2",
    campaigns: "50 chiến dịch",
    imageUrl:
        "https://www.hollywoodreporter.com/wp-content/uploads/2012/12/img_logo_blue.jpg?w=1440&h=810&crop=1",
  ),
  // ... copy thêm các item khác
];
