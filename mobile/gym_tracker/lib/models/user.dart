class User {
  final int id;
  final String username;
  final String email;
  final String? fullName;
  final String? profilePicture;
  final int? age;
  final double? weight;
  final double? height;
  final String? createdAt;

  const User({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.profilePicture,
    this.age,
    this.weight,
    this.height,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id:             json['id'] as int,
        username:       json['username'] as String,
        email:          json['email'] as String,
        fullName:       json['fullName'] as String?,
        profilePicture: json['profilePicture'] as String?,
        age:            json['age'] as int?,
        weight:         (json['weight'] as num?)?.toDouble(),
        height:         (json['height'] as num?)?.toDouble(),
        createdAt:      json['createdAt'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id':             id,
        'username':       username,
        'email':          email,
        'fullName':       fullName,
        'profilePicture': profilePicture,
        'age':            age,
        'weight':         weight,
        'height':         height,
      };

  User copyWith({
    String? fullName,
    int? age,
    double? weight,
    double? height,
    String? profilePicture,
  }) =>
      User(
        id:             id,
        username:       username,
        email:          email,
        fullName:       fullName ?? this.fullName,
        profilePicture: profilePicture ?? this.profilePicture,
        age:            age ?? this.age,
        weight:         weight ?? this.weight,
        height:         height ?? this.height,
        createdAt:      createdAt,
      );
}
