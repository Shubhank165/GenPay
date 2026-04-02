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
}
