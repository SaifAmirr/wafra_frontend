import 'package:flutter/material.dart';
import '../../domain/entities/food_listing.dart';

class ListingsRemoteDataSource {
  // Returns static data for now; replace getListings() body with an API call
  // when the backend endpoint is ready.
  List<FoodListing> getListings() => _staticListings;
}

const _staticListings = [
  FoodListing(
    title: 'Assorted Pastries Box',
    restaurant: 'Artisan Bakery',
    distance: 0.4,
    originalPrice: 21.00,
    discountedPrice: 6.50,
    itemsLeft: 8,
    expiresIn: '15:00',
    imageBg: Color(0xFFFEF3C7),
    imageIconColor: Color(0xFFD97706),
    imageIcon: Icons.bakery_dining,
    category: 'Bakery',
    description:
        'A hand-picked selection of our daily surplus artisan pastries. Typically includes 2–3 croissants, a fruit danish, and sourdough muffins. Perfect for breakfast or an afternoon treat. All items are baked fresh this morning.',
    tags: ['Vegetarian', 'Contains Nuts'],
    restaurantRating: 4.8,
  ),
  FoodListing(
    title: 'Fresh Garden Salad',
    restaurant: 'Green Cafe',
    distance: 0.7,
    originalPrice: 14.50,
    discountedPrice: 4.00,
    itemsLeft: 3,
    expiresIn: '08:30',
    imageBg: Color(0xFFDCFCE7),
    imageIconColor: Color(0xFF16A34A),
    imageIcon: Icons.eco,
    category: 'Vegetarian',
    description:
        'A generous portion of freshly prepared garden salad with seasonal vegetables, cherry tomatoes, cucumber, and house vinaigrette. Made this morning and perfect for a light lunch.',
    tags: ['Vegetarian', 'Vegan', 'Gluten-Free'],
    restaurantRating: 4.5,
  ),
  FoodListing(
    title: 'Daily Surplus Meals',
    restaurant: 'City Food Hub',
    distance: 1.2,
    originalPrice: 18.00,
    discountedPrice: 0.00,
    itemsLeft: 12,
    expiresIn: '45:00',
    imageBg: Color(0xFFFFF7ED),
    imageIconColor: Color(0xFFEA580C),
    imageIcon: Icons.restaurant,
    category: 'Meals',
    description:
        "Mixed surplus meals from today's service. Contents vary daily but always include a main dish, a side, and bread. Great value for individuals and families looking to reduce food waste.",
    tags: ['Contains Gluten', 'May contain dairy'],
    restaurantRating: 4.2,
  ),
];
