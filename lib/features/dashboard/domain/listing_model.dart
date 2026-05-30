enum ListingStatus { active, pending, reserved, completed }

class RestaurantListing {
  final int listingId;
  final String name;
  final String category;
  final int quantity;
  final ListingStatus status;
  final String timeDetail;
  final String listedAgo;
  final int reservationCount;
  final DateTime? pickupTime;
  final String location;
  final List<String> dietaryTags;

  const RestaurantListing({
    required this.listingId,
    required this.name,
    required this.category,
    required this.quantity,
    required this.status,
    required this.timeDetail,
    required this.listedAgo,
    this.reservationCount = 0,
    this.pickupTime,
    this.location = '',
    this.dietaryTags = const [],
  });
}

RestaurantListing restaurantListingFromJson(Map<String, dynamic> j) {
  final rawStatus = (j['status'] as String?) ?? 'available';
  final ListingStatus status;
  switch (rawStatus) {
    case 'available':
      status = ListingStatus.active;
      break;
    case 'reserved':
      status = ListingStatus.reserved;
      break;
    case 'completed':
      status = ListingStatus.completed;
      break;
    default:
      status = ListingStatus.pending;
  }

  final rawTime = j['pickup_time'] as String?;
  DateTime? pickupTime;
  String timeDetail = '';
  if (rawTime != null) {
    try {
      final dt = DateTime.parse(rawTime);
      pickupTime = dt;
      final diff = dt.difference(DateTime.now());
      timeDetail = diff.isNegative
            ? 'Pickup time passed'
            : 'Expires in ${diff.inHours}h ${diff.inMinutes % 60}m';
      if (status == ListingStatus.reserved) {
        timeDetail = 'Driver arriving soon';
      } else if (status == ListingStatus.completed) {
        timeDetail = 'Picked up';
      }
    } catch (_) {}
  }

  String listedAgo = '';
  final rawCreated = j['created_at'] as String?;
  if (rawCreated != null) {
    try {
      final created = DateTime.parse(rawCreated);
      final diff = DateTime.now().difference(created);
      if (diff.inMinutes < 60) {
        listedAgo = '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        listedAgo = '${diff.inHours}h ago';
      } else {
        listedAgo = '${diff.inDays}d ago';
      }
    } catch (_) {}
  }

  return RestaurantListing(
    listingId: j['listing_id'] as int? ?? 0,
    name: j['food_name'] as String? ?? '',
    category: j['category'] as String? ?? '',
    quantity: j['quantity'] as int? ?? 0,
    status: status,
    timeDetail: timeDetail,
    listedAgo: listedAgo,
    reservationCount: j['reservation_count'] as int? ?? 0,
    pickupTime: pickupTime,
    location: j['location'] as String? ?? '',
    dietaryTags: (j['dietary_tags'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [],
  );
}
