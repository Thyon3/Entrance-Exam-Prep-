class AppUser {
  AppUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.stream,
    this.gradeLevel,
    this.status,
    this.profileImage,
    this.phoneNumber,
    this.isEmailVerified,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? stream;
  final String? gradeLevel;
  final String? status;
  final String? profileImage;
  final String? phoneNumber;
  final bool? isEmailVerified;

  String get fullName => '$firstName $lastName'.trim();

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      email: json['email']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      role: json['role']?.toString() ?? 'student',
      stream: json['stream']?.toString(),
      gradeLevel: json['gradeLevel']?.toString(),
      status: json['status']?.toString(),
      profileImage: json['profileImage']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      isEmailVerified: json['isEmailVerified'] as bool?,
    );
  }
}

class AuthResult {
  AuthResult({required this.token, required this.user, this.verificationRequired});
  final String token;
  final AppUser user;
  final bool? verificationRequired;

  factory AuthResult.fromEnvelope(dynamic raw) {
    if (raw is Map<String, dynamic> && raw.containsKey('user')) {
      return AuthResult(
        token: raw['token']?.toString() ?? '',
        user: AppUser.fromJson(Map<String, dynamic>.from(raw['user'] as Map)),
        verificationRequired: raw['verificationRequired'] as bool?,
      );
    }
    return AuthResult(
      token: raw['token']?.toString() ?? '',
      user: AppUser.fromJson(Map<String, dynamic>.from(raw as Map)),
    );
  }
}
