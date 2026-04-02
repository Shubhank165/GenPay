import 'package:flutter/material.dart';

class ContactModel {
  final String id;
  final String name;
  final String phone;
  final String? upiId;
  final Color avatarColor;
  final bool isFavorite;
  final DateTime? lastTransactionDate;
  final double? lastAmount;

  ContactModel({
    required this.id,
    required this.name,
    required this.phone,
    this.upiId,
    required this.avatarColor,
    this.isFavorite = false,
    this.lastTransactionDate,
    this.lastAmount,
  });

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String get maskedPhone {
    if (phone.length >= 10) {
      return '${phone.substring(0, 2)}****${phone.substring(phone.length - 4)}';
    }
    return phone;
  }

  ContactModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? upiId,
    Color? avatarColor,
    bool? isFavorite,
    DateTime? lastTransactionDate,
    double? lastAmount,
  }) {
    return ContactModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      upiId: upiId ?? this.upiId,
      avatarColor: avatarColor ?? this.avatarColor,
      isFavorite: isFavorite ?? this.isFavorite,
      lastTransactionDate: lastTransactionDate ?? this.lastTransactionDate,
      lastAmount: lastAmount ?? this.lastAmount,
    );
  }
}
