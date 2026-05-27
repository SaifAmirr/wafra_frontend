import 'package:flutter/material.dart';

class FoodListing {
  final int? listingId;
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
    this.listingId,
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

  factory FoodListing.fromJson(Map<String, dynamic> json) {
    final cat = (json['category'] as String? ?? '').toLowerCase();
    final (bg, iconColor, icon) = _categoryVisuals(cat);

    String expiresIn = '--:--';
    final rawTime = json['pickup_time'] as String?;
    if (rawTime != null) {
      try {
        final pickup = DateTime.parse(rawTime);
        final diff = pickup.difference(DateTime.now());
        if (diff.isNegative) {
          expiresIn = 'Expired';
        } else {
          final h = diff.inHours;
          final m = diff.inMinutes % 60;
          expiresIn = h > 0 ? '${h}h ${m}m' : '${m}m';
        }
      } catch (_) {}
    }

    final rawTags = json['dietary_tags'];
    final tags = rawTags is List
        ? rawTags.map((e) => e.toString()).toList()
        : <String>[];

    return FoodListing(
      listingId: json['listing_id'] as int?,
      title: json['food_name'] as String? ?? '',
      restaurant: json['restaurant_name'] as String? ?? 'Restaurant',
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['original_price'] as num?)?.toDouble() ?? 0.0,
      discountedPrice: (json['discounted_price'] as num?)?.toDouble() ?? 0.0,
      itemsLeft: (json['quantity'] as num?)?.toInt() ?? 0,
      expiresIn: expiresIn,
      imageBg: bg,
      imageIconColor: iconColor,
      imageIcon: icon,
      category: json['category'] as String? ?? '',
      description: json['description'] as String? ?? '',
      tags: tags,
      restaurantRating:
          (json['restaurant_rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static (Color, Color, IconData) _categoryVisuals(String category) {
    switch (category) {
      case 'bakery':
        return (
          const Color(0xFFFEF3C7),
          const Color(0xFFD97706),
          Icons.bakery_dining
        );
      case 'vegetarian':
      case 'produce':
        return (
          const Color(0xFFDCFCE7),
          const Color(0xFF16A34A),
          Icons.eco
        );
      case 'meals':
      case 'cooked meals':
        return (
          const Color(0xFFFFF7ED),
          const Color(0xFFEA580C),
          Icons.restaurant
        );
      case 'dairy':
        return (
          const Color(0xFFEFF6FF),
          const Color(0xFF3B82F6),
          Icons.water_drop
        );
      case 'beverages':
        return (
          const Color(0xFFF5F3FF),
          const Color(0xFF7C3AED),
          Icons.local_cafe
        );
      default:
        return (
          const Color(0xFFF1F5F9),
          const Color(0xFF94A3B8),
          Icons.fastfood
        );
    }
  }
}
