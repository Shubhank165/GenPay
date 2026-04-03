class UserModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String upiId;
  final bool isKycVerified;
  final double walletBalance;
  final String? profileImageUrl;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.upiId,
    this.isKycVerified = false,
    this.walletBalance = 0.0,
    this.profileImageUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? upiId,
    bool? isKycVerified,
    double? walletBalance,
    String? profileImageUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      upiId: upiId ?? this.upiId,
      isKycVerified: isKycVerified ?? this.isKycVerified,
      walletBalance: walletBalance ?? this.walletBalance,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'upiId': upiId,
      'isKycVerified': isKycVerified,
      'walletBalance': walletBalance,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      upiId: json['upiId'],
      isKycVerified: json['isKycVerified'] ?? false,
      walletBalance: (json['walletBalance'] ?? 0).toDouble(),
      profileImageUrl: json['profileImageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  factory UserModel.fromBackendJson(Map<String, dynamic> json) {
    final createdRaw = json['created_at'] ?? json['createdAt'];
    return UserModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      upiId: (json['upi_id'] ?? json['upiId'] ?? '').toString(),
      isKycVerified: (json['kyc_status'] ?? '').toString().toLowerCase() == 'verified',
      walletBalance: ((json['wallet_balance'] ?? json['walletBalance'] ?? 0) as num).toDouble(),
      createdAt: createdRaw != null ? DateTime.parse(createdRaw.toString()) : DateTime.now(),
    );
  }
}
