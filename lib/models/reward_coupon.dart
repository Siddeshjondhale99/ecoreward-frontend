class RewardCoupon {
  final int id;
  final String title;
  final String description;
  final int pointsRequired;
  final String iconType;

  RewardCoupon({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsRequired,
    required this.iconType,
  });

  factory RewardCoupon.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String;
    String iconType = 'stars';
    if (name.toLowerCase().contains('property')) {
      iconType = 'property';
    } else if (name.toLowerCase().contains('electricity')) {
      iconType = 'electricity';
    } else if (name.toLowerCase().contains('water')) {
      iconType = 'water';
    }

    return RewardCoupon(
      id: json['id'],
      title: name,
      description: 'Redeem this for $name rewards!',
      pointsRequired: json['points_required'],
      iconType: iconType,
    );
  }
}
