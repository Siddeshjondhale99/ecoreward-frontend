class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String rfid;
  int points;
  final String? address;
  final String? wardNo;
  final String? houseNo;
  final String? profilePhoto;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.rfid,
    this.points = 0,
    this.address,
    this.wardNo,
    this.houseNo,
    this.profilePhoto,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      rfid: json['rfid_id'] ?? '',
      points: json['points'] ?? 0,
      address: json['address'],
      wardNo: json['ward_no'],
      houseNo: json['house_no'],
      profilePhoto: json['profile_photo'],
    );
  }
}
