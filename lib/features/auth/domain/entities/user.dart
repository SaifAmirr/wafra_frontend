class User {
  final String? role;
  final String? verificationStatus;

  const User({this.role, this.verificationStatus});

  factory User.fromJson(Map<String, dynamic> json) => User(
        role: json['role'] as String?,
        verificationStatus: json['verification_status'] as String?,
      );
}
