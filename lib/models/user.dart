class User {
  const User({
    required this.id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.phoneCountryCode,
    this.phoneDialCode,
    this.token,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email; // Email is required for auth
  final String? fullName; // Full name (optional, set during complete signup)
  final String? phoneNumber; // National significant number without dial code
  final String? phoneCountryCode; // ISO 3166-1 alpha-2 (e.g., IL)
  final String? phoneDialCode; // E.g., +972
  final String? token; // JWT token from API
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Computed properties
  String get displayName => fullName?.trim().isNotEmpty == true ? fullName! : email.split('@')[0];
  String? get fullPhoneNumber => (phoneDialCode != null && phoneNumber != null) 
      ? '$phoneDialCode$phoneNumber' 
      : null;
  
  // Check if profile is complete
  bool get isProfileComplete => fullName != null && phoneNumber != null;

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? phoneCountryCode,
    String? phoneDialCode,
    String? token,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      phoneCountryCode: phoneCountryCode ?? this.phoneCountryCode,
      phoneDialCode: phoneDialCode ?? this.phoneDialCode,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'phoneCountryCode': phoneCountryCode,
      'phoneDialCode': phoneDialCode,
      'token': token,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['name']?.toString() ?? json['fullName']?.toString() ?? json['full_name']?.toString(),
      phoneNumber: json['phoneNumber']?.toString() ?? json['phone_number']?.toString(),
      phoneCountryCode: json['phoneCountryCode']?.toString() ?? json['phone_country_code']?.toString(),
      phoneDialCode: json['phoneDialCode']?.toString() ?? json['phone_dial_code']?.toString(),
      token: json['token']?.toString(),
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'])
          : (json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt'])
          : (json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User(id: $id, email: $email, fullName: $fullName, phone: $fullPhoneNumber)';
  }
}
