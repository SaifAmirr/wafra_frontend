class User {
  final int? userId;
  final String? email;
  final String? role;
  final String? verificationStatus;
  final bool? isEmailVerified;

  const User({
    this.userId,
    this.email,
    this.role,
    this.verificationStatus,
    this.isEmailVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        userId: json['user_id'] as int?,
        email: json['email'] as String?,
        role: json['role'] as String?,
        verificationStatus: json['verification_status'] as String?,
        isEmailVerified: json['email_verified'] as bool? ??
            json['is_email_verified'] as bool?,
      );
}
