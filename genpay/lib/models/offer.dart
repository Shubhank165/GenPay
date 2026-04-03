import 'package:flutter/material.dart';

class OfferModel {
  final String id;
  final String title;
  final String description;
  final String? discountText;
  final String? couponCode;
  final DateTime validTill;
  final String category;
  final List<Color> gradientColors;
  final IconData icon;
  final String? termsAndConditions;

  OfferModel({
    required this.id,
    required this.title,
    required this.description,
    this.discountText,
    this.couponCode,
    required this.validTill,
    required this.category,
    required this.gradientColors,
    required this.icon,
    this.termsAndConditions,
  });

  bool get isExpired => validTill.isBefore(DateTime.now());

  factory OfferModel.fromBackendJson(Map<String, dynamic> json) {
    final category = (json['category'] ?? 'general').toString();

    List<Color> gradient;
    IconData icon;
    switch (category.toLowerCase()) {
      case 'travel':
        gradient = [const Color(0xFF9C27B0), const Color(0xFFE040FB)];
        icon = Icons.flight;
        break;
      case 'bills':
        gradient = [const Color(0xFFFFC107), const Color(0xFFFF9800)];
        icon = Icons.receipt_long;
        break;
      case 'recharge':
        gradient = [const Color(0xFF2196F3), const Color(0xFF00BCD4)];
        icon = Icons.phone_android;
        break;
      default:
        gradient = [const Color(0xFFFF6B35), const Color(0xFFFF9800)];
        icon = Icons.local_offer;
    }

    final validTillRaw = json['valid_till'];
    final discountType = (json['discount_type'] ?? '').toString();
    final discountValue = ((json['discount_value'] ?? 0) as num).toDouble();

    String? discountText;
    if (discountType == 'percentage') {
      discountText = '${discountValue.toInt()}% OFF';
    } else if (discountType == 'flat') {
      discountText = 'Rs ${discountValue.toInt()} OFF';
    }

    return OfferModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      discountText: discountText,
      couponCode: json['coupon_code']?.toString(),
      validTill: validTillRaw != null ? DateTime.parse(validTillRaw.toString()) : DateTime.now(),
      category: category,
      gradientColors: gradient,
      icon: icon,
    );
  }
}
