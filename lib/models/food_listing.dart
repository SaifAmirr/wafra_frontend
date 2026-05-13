import 'package:flutter/material.dart';

class FoodListing {
  final String title;
  final String restaurant;
  final double distance;
  final double originalPrice;
  final double discountedPrice;
  final int itemsLeft;
  final String expiresIn;
  final Color imageBg;
  final Color imageIconColor;
  final IconData imageIcon;
  final String category;
  final String description;
  final List<String> tags;
  final double restaurantRating;

  const FoodListing({
    required this.title,
    required this.restaurant,
    required this.distance,
    required this.originalPrice,
    required this.discountedPrice,
    required this.itemsLeft,
    required this.expiresIn,
    required this.imageBg,
    required this.imageIconColor,
    required this.imageIcon,
    required this.category,
    required this.description,
    required this.tags,
    required this.restaurantRating,
  });
}
